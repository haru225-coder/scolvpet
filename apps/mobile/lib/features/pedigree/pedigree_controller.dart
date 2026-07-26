import 'package:flutter/foundation.dart';

import '../i2/i2_models.dart';
import 'pedigree_models.dart';
import 'pedigree_repository.dart';

/// Creates a minimal pedigree stub hamster and returns it as a node.
typedef PedigreeStubFactory =
    Future<PedigreeNode> Function({
      required String name,
      required String sex,
      required String relationLabel,
    });

class PedigreeController extends ChangeNotifier {
  PedigreeController({required this.repository});

  final PedigreeRepository repository;

  I2AsyncState<PedigreeGraph> graphState = const I2AsyncState.idle();
  List<List<PedigreeTreeSlot>> generations = const [];
  int requestedGenerations = 3;
  String? hamsterId;
  String? lastMessage;
  bool assigning = false;

  Future<void> load(String id, {int generationsDepth = 3}) async {
    hamsterId = id;
    requestedGenerations = generationsDepth;
    graphState = const I2AsyncState.loading();
    generations = const [];
    notifyListeners();
    try {
      final graph = await repository.getPedigree(
        id,
        generations: generationsDepth + 1,
      );
      graphState = I2AsyncState.data(graph);
      generations = buildAncestorGenerations(
        graph,
        generations: generationsDepth,
      );
    } catch (error) {
      graphState = I2AsyncState.error(pedigreeErrorMessage(error));
    }
    notifyListeners();
  }

  Future<void> retry() async {
    final id = hamsterId;
    if (id == null) return;
    await load(id, generationsDepth: requestedGenerations);
  }

  /// Fill or replace [slot] with [parentId].
  ///
  /// When replacing an existing parent, [correctionReason] is required.
  Future<bool> fillSlot({
    required PedigreeTreeSlot slot,
    required String parentId,
    required PedigreeStubFactory createStub,
    String? correctionReason,
  }) async {
    final rootId = hamsterId;
    if (rootId == null) {
      lastMessage = '谱系未加载';
      notifyListeners();
      return false;
    }
    final target = pedigreeFillTargetForSlot(slot);
    if (target == null) {
      lastMessage = '当前位置不能填入父母';
      notifyListeners();
      return false;
    }
    if (parentId == rootId) {
      lastMessage = '不能把自己填成自己的祖先';
      notifyListeners();
      return false;
    }

    assigning = true;
    lastMessage = null;
    notifyListeners();

    try {
      var graph =
          graphState.data ??
          await repository.getPedigree(
            rootId,
            generations: requestedGenerations + 1,
          );

      var childId = rootId;
      for (var i = 0; i < target.pathToChild.length; i++) {
        final hop = target.pathToChild[i];
        final existing = pedigreeParentIdOf(
          graph,
          childId: childId,
          role: hop,
        );
        if (existing != null) {
          childId = existing;
          continue;
        }
        final prefix = target.pathToChild.sublist(0, i + 1);
        final label = pedigreeRelationshipLabel(prefix);
        final sex = hop == 'sire' ? 'male' : 'female';
        final stub = await createStub(
          name: label,
          sex: sex,
          relationLabel: label,
        );
        if (stub.id == parentId) {
          lastMessage = '中间代与目标祖先不能是同一只';
          assigning = false;
          notifyListeners();
          return false;
        }
        await repository.createParentage(
          childHamsterId: childId,
          parentHamsterId: stub.id,
          role: hop,
        );
        graph = await repository.getPedigree(
          rootId,
          generations: requestedGenerations + 1,
        );
        childId = stub.id;
      }

      final already = pedigreeParentIdOf(
        graph,
        childId: childId,
        role: target.role,
      );
      if (already != null) {
        if (already == parentId) {
          lastMessage = '已是该位置的祖先';
          assigning = false;
          await load(rootId, generationsDepth: requestedGenerations);
          return true;
        }
        final reason = correctionReason?.trim() ?? '';
        if (reason.isEmpty) {
          lastMessage = '替换${target.label}必须填写纠错原因';
          assigning = false;
          notifyListeners();
          return false;
        }
        await repository.createParentage(
          childHamsterId: childId,
          parentHamsterId: parentId,
          role: target.role,
          correctionReason: reason,
        );
        lastMessage = '已替换${target.label}';
      } else {
        await repository.createParentage(
          childHamsterId: childId,
          parentHamsterId: parentId,
          role: target.role,
        );
        lastMessage = '已填入${target.label}';
      }
      assigning = false;
      await load(rootId, generationsDepth: requestedGenerations);
      return true;
    } catch (error) {
      lastMessage = pedigreeErrorMessage(error);
      assigning = false;
      notifyListeners();
      return false;
    }
  }

  /// Remove the parent edge for [slot] (must already be filled).
  Future<bool> endSlot({
    required PedigreeTreeSlot slot,
    required String correctionReason,
  }) async {
    final rootId = hamsterId;
    if (rootId == null) {
      lastMessage = '谱系未加载';
      notifyListeners();
      return false;
    }
    final target = pedigreeFillTargetForSlot(slot);
    if (target == null || slot.node == null) {
      lastMessage = '当前位置没有可解除的父母';
      notifyListeners();
      return false;
    }
    final reason = correctionReason.trim();
    if (reason.isEmpty) {
      lastMessage = '解除关系必须填写纠错原因';
      notifyListeners();
      return false;
    }

    assigning = true;
    lastMessage = null;
    notifyListeners();

    try {
      final graph =
          graphState.data ??
          await repository.getPedigree(
            rootId,
            generations: requestedGenerations + 1,
          );

      // Resolve child of this edge by walking path.
      var childId = rootId;
      for (final hop in target.pathToChild) {
        final next = pedigreeParentIdOf(graph, childId: childId, role: hop);
        if (next == null) {
          lastMessage = '中间代缺失，无法解除';
          assigning = false;
          notifyListeners();
          return false;
        }
        childId = next;
      }

      await repository.endParentage(
        childHamsterId: childId,
        role: target.role,
        correctionReason: reason,
      );
      lastMessage = '已解除${target.label}';
      assigning = false;
      await load(rootId, generationsDepth: requestedGenerations);
      return true;
    } catch (error) {
      lastMessage = pedigreeErrorMessage(error);
      assigning = false;
      notifyListeners();
      return false;
    }
  }
}
