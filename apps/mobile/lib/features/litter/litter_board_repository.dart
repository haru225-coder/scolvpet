import 'package:dio/dio.dart';
import 'package:scolvpet_api/scolvpet_api.dart' as api;
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
import '../../core/api_error.dart';
import 'litter_board_models.dart';

abstract interface class LitterBoardRepository {
  Future<List<LitterBoard>> listLitters();

  Future<LitterBoard> getLitter(String litterId);

  Future<LitterBoard> wean({
    required String litterId,
    required int version,
    DateTime? weanedAt,
  });

  Future<LitterBoard> sexAndSeparate({
    required String litterId,
    required int version,
    required List<LitterPupSeparation> assignments,
    DateTime? separatedAt,
  });

  Future<LitterBoard> individualize({
    required String litterId,
    required int version,
    required List<LitterPupProfileDraft> profiles,
    DateTime? individualizedAt,
  });
}

class LitterBoardRepositoryException implements Exception {
  const LitterBoardRepositoryException(this.message);
  final String message;
  @override
  String toString() => message;
}

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
            .putIfAbsent(
              assignment.destinationEnclosureId,
              () => <String>{},
            )
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

class DefaultApiLitterBoardRepository implements LitterBoardRepository {
  DefaultApiLitterBoardRepository({required this.client});

  final ApiClient client;
  final _uuid = const Uuid();

  api.DefaultApi get _api => client.api;
  String _key() => 'lt-${_uuid.v4()}';
  String _etag(int version) => '"$version"';

  LitterBoard _mapLitter(api.Litter litter, List<LitterPup> pups) {
    return LitterBoard(
      id: litter.id,
      code: litter.code,
      state: litter.state.value,
      version: litter.version,
      bornAt: litter.bornAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      initialAliveCount: litter.initialAliveCount,
      currentManagedCount: litter.currentManagedCount,
      enclosureId: litter.enclosureId ?? '',
      sireId: litter.sireId,
      damId: litter.damId,
      pups: pups,
    );
  }

  LitterPup _mapPup(api.PupIdentity pup, {required bool litterWeaned}) {
    final sex = pup.sex.value;
    return LitterPup(
      id: pup.id,
      temporaryCode: pup.temporaryCode,
      outcomeStatus: pup.outcomeStatus.value,
      sex: sex,
      weaned: litterWeaned,
      sexAssigned: sex != 'unknown',
      individualized: pup.hamsterId != null,
      hamsterId: pup.hamsterId,
      destinationEnclosureId: pup.currentEnclosureId,
    );
  }

  Future<List<LitterPup>> _loadPupsForLitter(api.Litter litter) async {
    final response = await _api.listPupIdentities(
      litterId: litter.id,
      limit: 100,
    );
    final data = response.data?.data ?? const <api.PupIdentity>[];
    final litterWeaned = litter.state.value != 'newborn' &&
        litter.state.value != 'nursing' &&
        litter.state.value != 'weaning_due';
    return data
        .map((pup) => _mapPup(pup, litterWeaned: litterWeaned))
        .toList();
  }

  @override
  Future<List<LitterBoard>> listLitters() async {
    final response = await _api.listLitters(limit: 50);
    final litters = response.data?.data ?? const <api.Litter>[];
    // 每窝幼崽互不依赖，并行加载避免 50 窝时串行等待 50 次网络往返；
    // Future.wait 保留输入顺序，列表排序和用户看到的顺序不变。
    return Future.wait(
      litters.map((litter) async {
        final pups = await _loadPupsForLitter(litter);
        return _mapLitter(litter, pups);
      }),
    );
  }

  @override
  Future<LitterBoard> getLitter(String litterId) async {
    // list filter fallback: fetch list and find
    final all = await listLitters();
    return all.firstWhere(
      (l) => l.id == litterId,
      orElse: () => throw const LitterBoardRepositoryException('窝次不存在'),
    );
  }

  @override
  Future<LitterBoard> wean({
    required String litterId,
    required int version,
    DateTime? weanedAt,
  }) async {
    final board = await getLitter(litterId);
    final items = board.alivePups
        .map(
          (p) => api.WeanLitterRequestItemsInner(
            pupIdentityId: p.id,
            outcomeStatus: api.PupOutcomeStatus.alive,
            destinationEnclosureId: board.enclosureId.isEmpty
                ? null
                : board.enclosureId,
          ),
        )
        .toList();
    if (items.isEmpty) {
      throw const LitterBoardRepositoryException('没有可断奶的活仔');
    }
    await _api.weanLitter(
      litterId: litterId,
      idempotencyKey: _key(),
      ifMatch: _etag(version),
      weanLitterRequest: api.WeanLitterRequest(
        weanedAt: weanedAt ?? DateTime.now().toUtc(),
        timezone: 'Asia/Shanghai',
        items: items,
      ),
    );
    return getLitter(litterId);
  }

  @override
  Future<LitterBoard> sexAndSeparate({
    required String litterId,
    required int version,
    required List<LitterPupSeparation> assignments,
    DateTime? separatedAt,
  }) async {
    final items = assignments.map((assignment) {
      final sex = api.Sex.values.firstWhere(
        (value) => value.value == assignment.sex,
        orElse: () => api.Sex.unknown,
      );
      return api.SexAndSeparateRequestItemsInner(
        pupIdentityId: assignment.pupIdentityId,
        sex: sex,
        destinationEnclosureId: assignment.destinationEnclosureId,
        requiresRecheck: assignment.requiresRecheck || sex == api.Sex.unknown,
      );
    }).toList();
    if (items.isEmpty) {
      throw const LitterBoardRepositoryException('没有可分性的活仔');
    }
    await _api.sexAndSeparateLitter(
      litterId: litterId,
      idempotencyKey: _key(),
      ifMatch: _etag(version),
      sexAndSeparateRequest: api.SexAndSeparateRequest(
        separatedAt: separatedAt ?? DateTime.now().toUtc(),
        timezone: 'Asia/Shanghai',
        items: items,
      ),
    );
    return getLitter(litterId);
  }

  @override
  Future<LitterBoard> individualize({
    required String litterId,
    required int version,
    required List<LitterPupProfileDraft> profiles,
    DateTime? individualizedAt,
  }) async {
    final eligibility = await _api.getLitterIndividualizationEligibility(
      litterId: litterId,
    );
    final data = eligibility.data!.data;
    if (!data.canIndividualize) {
      throw LitterBoardRepositoryException(
        data.blockers.isEmpty
            ? '当前不可个体化'
            : data.blockers.map((b) => b.message).join('；'),
      );
    }
    final board = await getLitter(litterId);
    final eligibleIds = data.eligiblePupIdentityIds.toSet();
    final profileByPup = {
      for (final profile in profiles) profile.pupIdentityId: profile,
    };
    final missing = eligibleIds.where((id) => !profileByPup.containsKey(id));
    if (missing.isNotEmpty || profileByPup.length != eligibleIds.length) {
      throw const LitterBoardRepositoryException('请为每只可建档幼崽填写编号');
    }
    final items = board.alivePups
        .where((p) => eligibleIds.contains(p.id))
        .map((p) {
          final profile = profileByPup[p.id]!;
          final name = profile.name?.trim();
          return api.IndividualizeLitterRequestItemsInner(
            pupIdentityId: p.id,
            internalCode: profile.internalCode.trim(),
            name: name == null || name.isEmpty ? null : name,
          );
        })
        .toList();
    if (items.isEmpty) {
      throw const LitterBoardRepositoryException('没有可个体化的幼崽');
    }
    await _api.individualizeLitter(
      litterId: litterId,
      idempotencyKey: _key(),
      ifMatch: _etag(version),
      individualizeLitterRequest: api.IndividualizeLitterRequest(
        individualizedAt: individualizedAt ?? DateTime.now().toUtc(),
        timezone: 'Asia/Shanghai',
        eligibleSetToken: data.eligibleSetToken,
        items: items,
      ),
    );
    return getLitter(litterId);
  }
}

String litterBoardErrorMessage(Object error) => apiErrorMessage(
  error,
  fallback: '请求失败',
  mapLocal: (e) => e is LitterBoardRepositoryException ? e.message : null,
  mapDio: (e) {
    if (e.type == DioExceptionType.connectionError) return '网络不可用，请稍后重试';
    return '请求失败（${e.response?.statusCode ?? e.type.name}）';
  },
);
