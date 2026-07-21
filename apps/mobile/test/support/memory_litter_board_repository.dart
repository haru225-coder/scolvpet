// Test doubles only — not part of production lib.
// Moved out of lib/ per docs/engineering/复杂度收敛约定.md

import 'package:scolvpet_mobile/features/litter/litter_board_models.dart';
import 'package:scolvpet_mobile/features/litter/litter_board_repository.dart';

class MemoryLitterBoardRepository implements LitterBoardRepository {
  MemoryLitterBoardRepository({List<LitterBoard>? seed})
    : _litters = [...?seed];

  final List<LitterBoard> _litters;
  int _seq = 0;

  /// Helper for tests / confirm-birth handoff.
  LitterBoard seedNursingLitter({
    required int pupCount,
    String? enclosureId,
    String? code,
  }) {
    final id = 'litter-${_seq++}';
    final pups = List<LitterPup>.generate(
      pupCount,
      (i) => LitterPup(
        id: '$id-pup-$i',
        temporaryCode: 'P${(i + 1).toString().padLeft(2, '0')}',
        outcomeStatus: 'alive',
      ),
    );
    final board = LitterBoard(
      id: id,
      code: code ?? 'L-$_seq',
      state: 'nursing',
      version: 1,
      bornAt: DateTime.now().toUtc(),
      initialAliveCount: pupCount,
      currentManagedCount: pupCount,
      enclosureId: enclosureId ?? 'enc-1',
      pups: pups,
    );
    _litters.insert(0, board);
    return board;
  }

  LitterBoard _require(String id) => _litters.firstWhere(
    (l) => l.id == id,
    orElse: () => throw const LitterBoardRepositoryException('窝次不存在'),
  );

  void _replace(LitterBoard board) {
    final i = _litters.indexWhere((l) => l.id == board.id);
    if (i < 0) throw const LitterBoardRepositoryException('窝次不存在');
    _litters[i] = board;
  }

  @override
  Future<List<LitterBoard>> listLitters() async =>
      List<LitterBoard>.from(_litters);

  @override
  Future<LitterBoard> getLitter(String litterId) async => _require(litterId);

  @override
  Future<LitterBoard> wean({
    required String litterId,
    required int version,
    DateTime? weanedAt,
  }) async {
    final litter = _require(litterId);
    if (litter.version != version) {
      throw const LitterBoardRepositoryException('版本冲突，请刷新后重试');
    }
    final action = nextLitterAction(litter.state);
    if (action != LitterBoardAction.wean) {
      throw LitterBoardRepositoryException('当前状态 ${litter.state} 不能断奶');
    }
    final pups = litter.pups
        .map((p) => p.isAlive ? p.copyWith(weaned: true) : p)
        .toList();
    final next = litter.copyWith(
      state: 'sexing_due',
      version: litter.version + 1,
      pups: pups,
    );
    _replace(next);
    return next;
  }

  @override
  Future<LitterBoard> sexAndSeparate({
    required String litterId,
    required int version,
    required List<LitterPupSeparation> assignments,
    DateTime? separatedAt,
  }) async {
    final litter = _require(litterId);
    if (litter.version != version) {
      throw const LitterBoardRepositoryException('版本冲突，请刷新后重试');
    }
    if (nextLitterAction(litter.state) != LitterBoardAction.sexAndSeparate) {
      throw LitterBoardRepositoryException('当前状态 ${litter.state} 不能分性分笼');
    }
    final aliveIds = litter.alivePups.map((p) => p.id).toSet();
    final assignmentIds = assignments.map((a) => a.pupIdentityId).toSet();
    if (assignments.length != assignmentIds.length ||
        aliveIds.length != assignmentIds.length ||
        !aliveIds.containsAll(assignmentIds)) {
      throw const LitterBoardRepositoryException('请为每只存活幼崽完成一次分性与分笼');
    }
    final confirmedSexesByEnclosure = <String, Set<String>>{};
    for (final assignment in assignments) {
      if (assignment.destinationEnclosureId.trim().isEmpty) {
        throw const LitterBoardRepositoryException('每只幼崽都需要选择目标笼盒');
      }
      if (assignment.sex != 'male' &&
          assignment.sex != 'female' &&
          assignment.sex != 'unknown') {
        throw const LitterBoardRepositoryException('幼崽性别选项无效');
      }
      if (assignment.sex != 'unknown') {
        confirmedSexesByEnclosure
            .putIfAbsent(assignment.destinationEnclosureId, () => <String>{})
            .add(assignment.sex);
      }
    }
    if (confirmedSexesByEnclosure.values.any((sexes) => sexes.length > 1)) {
      throw const LitterBoardRepositoryException('同一笼盒不能混合已确认的公母幼崽');
    }
    final byPup = {
      for (final assignment in assignments)
        assignment.pupIdentityId: assignment,
    };
    final pups = litter.pups.map((p) {
      if (!p.isAlive) return p;
      final assignment = byPup[p.id]!;
      return p.copyWith(
        sex: assignment.sex,
        sexAssigned: assignment.sex != 'unknown',
        destinationEnclosureId: assignment.destinationEnclosureId,
      );
    }).toList();
    final next = litter.copyWith(
      state: 'individualizing',
      version: litter.version + 1,
      pups: pups,
    );
    _replace(next);
    return next;
  }

  @override
  Future<LitterBoard> individualize({
    required String litterId,
    required int version,
    required List<LitterPupProfileDraft> profiles,
    DateTime? individualizedAt,
  }) async {
    final litter = _require(litterId);
    if (litter.version != version) {
      throw const LitterBoardRepositoryException('版本冲突，请刷新后重试');
    }
    if (nextLitterAction(litter.state) != LitterBoardAction.individualize) {
      throw LitterBoardRepositoryException('当前状态 ${litter.state} 不能个体化');
    }
    final incomplete = litter.alivePups.any(
      (p) => !p.weaned || !p.sexAssigned || p.sex == null || p.sex == 'unknown',
    );
    if (incomplete) {
      throw const LitterBoardRepositoryException('仍有幼崽未断奶或未分性');
    }
    final aliveIds = litter.alivePups.map((p) => p.id).toSet();
    final profileIds = profiles.map((p) => p.pupIdentityId).toSet();
    if (profiles.length != profileIds.length ||
        aliveIds.length != profileIds.length ||
        !aliveIds.containsAll(profileIds)) {
      throw const LitterBoardRepositoryException('请为每只存活幼崽填写建档编号');
    }
    final codes = profiles.map((p) => p.internalCode.trim()).toList();
    if (codes.any((code) => code.isEmpty)) {
      throw const LitterBoardRepositoryException('建档编号不能为空');
    }
    if (codes.toSet().length != codes.length) {
      throw const LitterBoardRepositoryException('同一窝内的建档编号不能重复');
    }
    final profilesByPup = {
      for (final profile in profiles) profile.pupIdentityId: profile,
    };
    final pups = litter.pups.map((p) {
      if (!p.isAlive) return p;
      final profile = profilesByPup[p.id]!;
      return p.copyWith(
        individualized: true,
        hamsterId: 'hamster-${profile.internalCode.trim()}',
      );
    }).toList();
    final next = litter.copyWith(
      state: 'closed',
      version: litter.version + 1,
      currentManagedCount: 0,
      pups: pups,
    );
    _replace(next);
    return next;
  }
}
