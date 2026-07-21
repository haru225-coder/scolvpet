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
    final litterWeaned =
        litter.state.value != 'newborn' &&
        litter.state.value != 'nursing' &&
        litter.state.value != 'weaning_due';
    return data.map((pup) => _mapPup(pup, litterWeaned: litterWeaned)).toList();
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
    final items = board.alivePups.where((p) => eligibleIds.contains(p.id)).map((
      p,
    ) {
      final profile = profileByPup[p.id]!;
      final name = profile.name?.trim();
      return api.IndividualizeLitterRequestItemsInner(
        pupIdentityId: p.id,
        internalCode: profile.internalCode.trim(),
        name: name == null || name.isEmpty ? null : name,
      );
    }).toList();
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
