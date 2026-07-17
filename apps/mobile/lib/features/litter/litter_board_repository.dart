import 'package:dio/dio.dart';
import 'package:scolvpet_api/scolvpet_api.dart' as api;
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
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
    required String maleEnclosureId,
    required String femaleEnclosureId,
    DateTime? separatedAt,
  });

  Future<LitterBoard> individualize({
    required String litterId,
    required int version,
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
    required String maleEnclosureId,
    required String femaleEnclosureId,
    DateTime? separatedAt,
  }) async {
    final litter = _require(litterId);
    if (litter.version != version) {
      throw const LitterBoardRepositoryException('版本冲突，请刷新后重试');
    }
    if (nextLitterAction(litter.state) != LitterBoardAction.sexAndSeparate) {
      throw LitterBoardRepositoryException('当前状态 ${litter.state} 不能分性分笼');
    }
    var male = true;
    final pups = litter.pups.map((p) {
      if (!p.isAlive) return p;
      final sex = male ? 'male' : 'female';
      male = !male;
      return p.copyWith(
        sex: sex,
        sexAssigned: true,
        destinationEnclosureId: sex == 'male'
            ? maleEnclosureId
            : femaleEnclosureId,
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
    final pups = litter.pups.map((p) {
      if (!p.isAlive) return p;
      return p.copyWith(
        individualized: true,
        hamsterId: 'hamster-from-${p.id}',
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

  LitterPup _mapPup(api.PupIdentity pup) {
    final sex = pup.sex.value;
    return LitterPup(
      id: pup.id,
      temporaryCode: pup.temporaryCode,
      outcomeStatus: pup.outcomeStatus.value,
      sex: sex,
      weaned: false,
      sexAssigned: sex != 'unknown',
      individualized: pup.hamsterId != null,
      hamsterId: pup.hamsterId,
      destinationEnclosureId: pup.currentEnclosureId,
    );
  }

  Future<List<LitterPup>> _loadPups(String litterId) async {
    final response = await _api.listPupIdentities(litterId: litterId, limit: 100);
    final data = response.data?.data ?? const <api.PupIdentity>[];
    return data.map(_mapPup).toList();
  }

  @override
  Future<List<LitterBoard>> listLitters() async {
    final response = await _api.listLitters(limit: 50);
    final litters = response.data?.data ?? const <api.Litter>[];
    final boards = <LitterBoard>[];
    for (final litter in litters) {
      final pups = await _loadPups(litter.id);
      boards.add(_mapLitter(litter, pups));
    }
    return boards;
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
    required String maleEnclosureId,
    required String femaleEnclosureId,
    DateTime? separatedAt,
  }) async {
    final board = await getLitter(litterId);
    var male = true;
    final items = board.alivePups.map((p) {
      final sex = male ? api.Sex.male : api.Sex.female;
      male = !male;
      return api.SexAndSeparateRequestItemsInner(
        pupIdentityId: p.id,
        sex: sex,
        destinationEnclosureId: sex == api.Sex.male
            ? maleEnclosureId
            : femaleEnclosureId,
        requiresRecheck: false,
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
    final items = board.alivePups
        .where((p) => eligibleIds.contains(p.id))
        .map(
          (p) => api.IndividualizeLitterRequestItemsInner(
            pupIdentityId: p.id,
            internalCode: p.temporaryCode,
          ),
        )
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

String litterBoardErrorMessage(Object error) {
  if (error is LitterBoardRepositoryException) return error.message;
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['error'] is Map) {
      final msg = (data['error'] as Map)['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    if (error.type == DioExceptionType.connectionError) {
      return '网络不可用，请稍后重试';
    }
    return '请求失败（${error.response?.statusCode ?? error.type.name}）';
  }
  return error.toString();
}
