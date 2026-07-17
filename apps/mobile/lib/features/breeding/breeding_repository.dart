import 'package:dio/dio.dart';
import 'package:scolvpet_api/scolvpet_api.dart' as api;
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
import 'breeding_models.dart';

abstract interface class BreedingRepository {
  Future<List<BreedingPlan>> listPlans();

  Future<BreedingPlan> createPlan(CreateBreedingPlanInput input);

  Future<BreedingPlan> publishPlan({
    required String planId,
    required int version,
    required DateTime plannedPairingAt,
    required String pairingEnclosureId,
    String timezone = 'Asia/Shanghai',
  });

  Future<({BreedingPlan plan, PairingAttempt attempt})> startPairing({
    required String planId,
    required int version,
    required String enclosureId,
    required DateTime startedAt,
    String timezone = 'Asia/Shanghai',
  });

  Future<({BreedingPlan plan, PairingAttempt attempt})> separatePairing({
    required String planId,
    required String attemptId,
    required int planVersion,
    required int attemptVersion,
    required DateTime separatedAt,
    required String result,
    required String sireDestinationEnclosureId,
    required String damDestinationEnclosureId,
    String timezone = 'Asia/Shanghai',
  });

  Future<BreedingPlan> startGestation({
    required String planId,
    required int version,
    required String pairingAttemptId,
    required String result,
    required DateTime baselineAt,
    String timezone = 'Asia/Shanghai',
  });

  Future<({BreedingPlan plan, String? litterId})> confirmBirth({
    required String planId,
    required int version,
    required DateTime bornAt,
    required String enclosureId,
    required int initialAliveCount,
    int initialOtherCount = 0,
    String timezone = 'Asia/Shanghai',
  });
}

class BreedingRepositoryException implements Exception {
  const BreedingRepositoryException(this.message);
  final String message;

  @override
  String toString() => message;
}

class MemoryBreedingRepository implements BreedingRepository {
  MemoryBreedingRepository({List<BreedingPlan>? seed}) : _plans = [...?seed];

  final List<BreedingPlan> _plans;
  final Map<String, PairingAttempt> _attempts = {};
  int _seq = 0;

  List<BreedingPlan> get plans => List.unmodifiable(_plans);

  BreedingPlan _require(String id) => _plans.firstWhere(
    (p) => p.id == id,
    orElse: () {
      throw const BreedingRepositoryException('计划不存在');
    },
  );

  void _replace(BreedingPlan plan) {
    final i = _plans.indexWhere((p) => p.id == plan.id);
    if (i < 0) throw const BreedingRepositoryException('计划不存在');
    _plans[i] = plan;
  }

  @override
  Future<List<BreedingPlan>> listPlans() async =>
      List<BreedingPlan>.from(_plans);

  @override
  Future<BreedingPlan> createPlan(CreateBreedingPlanInput input) async {
    if (input.sireId == input.damId) {
      throw const BreedingRepositoryException('父母不能是同一只仓鼠');
    }
    final plan = BreedingPlan(
      id: 'plan-${_seq++}',
      sireId: input.sireId,
      damId: input.damId,
      ruleVersionId: input.ruleVersionId,
      state: 'draft',
      version: 1,
      name: input.name,
      notes: input.notes,
    );
    _plans.insert(0, plan);
    return plan;
  }

  @override
  Future<BreedingPlan> publishPlan({
    required String planId,
    required int version,
    required DateTime plannedPairingAt,
    required String pairingEnclosureId,
    String timezone = 'Asia/Shanghai',
  }) async {
    final plan = _require(planId);
    if (plan.version != version) {
      throw const BreedingRepositoryException('版本冲突，请刷新后重试');
    }
    if (plan.state != 'draft') {
      throw BreedingRepositoryException('当前状态 ${plan.state} 不能发布');
    }
    final next = plan.copyWith(
      state: 'pair_ready',
      version: plan.version + 1,
      plannedPairingAt: plannedPairingAt,
    );
    _replace(next);
    return next;
  }

  @override
  Future<({BreedingPlan plan, PairingAttempt attempt})> startPairing({
    required String planId,
    required int version,
    required String enclosureId,
    required DateTime startedAt,
    String timezone = 'Asia/Shanghai',
  }) async {
    final plan = _require(planId);
    if (plan.version != version) {
      throw const BreedingRepositoryException('版本冲突，请刷新后重试');
    }
    if (plan.state != 'pair_ready') {
      throw BreedingRepositoryException('当前状态 ${plan.state} 不能开始配对');
    }
    final attempt = PairingAttempt(
      id: 'attempt-${_seq++}',
      breedingPlanId: planId,
      enclosureId: enclosureId,
      status: 'active',
      version: 1,
      startedAt: startedAt,
    );
    _attempts[attempt.id] = attempt;
    final next = plan.copyWith(
      state: 'pairing',
      version: plan.version + 1,
      activePairingAttemptId: attempt.id,
    );
    _replace(next);
    return (plan: next, attempt: attempt);
  }

  @override
  Future<({BreedingPlan plan, PairingAttempt attempt})> separatePairing({
    required String planId,
    required String attemptId,
    required int planVersion,
    required int attemptVersion,
    required DateTime separatedAt,
    required String result,
    required String sireDestinationEnclosureId,
    required String damDestinationEnclosureId,
    String timezone = 'Asia/Shanghai',
  }) async {
    final plan = _require(planId);
    if (plan.version != planVersion) {
      throw const BreedingRepositoryException('版本冲突，请刷新后重试');
    }
    if (plan.state != 'pairing') {
      throw BreedingRepositoryException('当前状态 ${plan.state} 不能分笼');
    }
    final attempt = _attempts[attemptId];
    if (attempt == null || attempt.version != attemptVersion) {
      throw const BreedingRepositoryException('配对记录版本冲突');
    }
    final nextAttempt = PairingAttempt(
      id: attempt.id,
      breedingPlanId: attempt.breedingPlanId,
      enclosureId: attempt.enclosureId,
      status: 'separated',
      version: attempt.version + 1,
      startedAt: attempt.startedAt,
      separatedAt: separatedAt,
      result: result,
    );
    _attempts[attemptId] = nextAttempt;
    final next = plan.copyWith(state: 'post_pair', version: plan.version + 1);
    _replace(next);
    return (plan: next, attempt: nextAttempt);
  }

  @override
  Future<BreedingPlan> startGestation({
    required String planId,
    required int version,
    required String pairingAttemptId,
    required String result,
    required DateTime baselineAt,
    String timezone = 'Asia/Shanghai',
  }) async {
    final plan = _require(planId);
    if (plan.version != version) {
      throw const BreedingRepositoryException('版本冲突，请刷新后重试');
    }
    if (plan.state != 'post_pair') {
      throw BreedingRepositoryException('当前状态 ${plan.state} 不能进入孕期');
    }
    final next = plan.copyWith(
      state: 'gestation',
      version: plan.version + 1,
      expectedBirthStart: baselineAt.add(const Duration(days: 16)),
      expectedBirthEnd: baselineAt.add(const Duration(days: 18)),
    );
    _replace(next);
    return next;
  }

  @override
  Future<({BreedingPlan plan, String? litterId})> confirmBirth({
    required String planId,
    required int version,
    required DateTime bornAt,
    required String enclosureId,
    required int initialAliveCount,
    int initialOtherCount = 0,
    String timezone = 'Asia/Shanghai',
  }) async {
    final plan = _require(planId);
    if (plan.version != version) {
      throw const BreedingRepositoryException('版本冲突，请刷新后重试');
    }
    if (plan.state != 'gestation') {
      throw BreedingRepositoryException('当前状态 ${plan.state} 不能确认产仔');
    }
    if (initialAliveCount <= 0) {
      final next = plan.copyWith(
        state: 'no_litter_outcome',
        version: plan.version + 1,
        actualBirthAt: bornAt,
      );
      _replace(next);
      return (plan: next, litterId: null);
    }
    final litterId = 'litter-${_seq++}';
    final next = plan.copyWith(
      state: 'litter_nursing',
      version: plan.version + 1,
      actualBirthAt: bornAt,
      litterId: litterId,
    );
    _replace(next);
    return (plan: next, litterId: litterId);
  }
}

class DefaultApiBreedingRepository implements BreedingRepository {
  DefaultApiBreedingRepository({required this.client});

  final ApiClient client;
  final _uuid = const Uuid();

  api.DefaultApi get _api => client.api;

  String _key() => 'br-${_uuid.v4()}';
  String _etag(int version) => '"$version"';

  BreedingPlan _plan(api.BreedingPlan src) =>
      BreedingPlan.fromJson(src.toJson());

  PairingAttempt _attempt(api.PairingAttempt src) =>
      PairingAttempt.fromJson(src.toJson());

  api.PairingResult _pairingResult(String value) =>
      api.PairingResult.values.firstWhere(
        (e) => e.value == value,
        orElse: () => api.PairingResult.effective,
      );

  api.StartGestationRequestResultEnum _gestationResult(String value) =>
      api.StartGestationRequestResultEnum.values.firstWhere(
        (e) => e.value == value,
        orElse: () => api.StartGestationRequestResultEnum.effective,
      );

  @override
  Future<List<BreedingPlan>> listPlans() async {
    final response = await _api.listBreedingPlans(limit: 50);
    final data = response.data?.data ?? const <api.BreedingPlan>[];
    return data.map(_plan).toList();
  }

  @override
  Future<BreedingPlan> createPlan(CreateBreedingPlanInput input) async {
    final response = await _api.createBreedingPlan(
      idempotencyKey: _key(),
      breedingPlanCreateRequest: api.BreedingPlanCreateRequest(
        sireId: input.sireId,
        damId: input.damId,
        ruleVersionId: input.ruleVersionId,
        name: input.name,
        notes: input.notes,
      ),
    );
    return _plan(response.data!.data);
  }

  @override
  Future<BreedingPlan> publishPlan({
    required String planId,
    required int version,
    required DateTime plannedPairingAt,
    required String pairingEnclosureId,
    String timezone = 'Asia/Shanghai',
  }) async {
    final response = await _api.publishBreedingPlan(
      planId: planId,
      idempotencyKey: _key(),
      ifMatch: _etag(version),
      publishBreedingPlanRequest: api.PublishBreedingPlanRequest(
        plannedPairingAt: plannedPairingAt,
        pairingEnclosureId: pairingEnclosureId,
        timezone: timezone,
      ),
    );
    return _plan(response.data!.data.breedingPlan);
  }

  @override
  Future<({BreedingPlan plan, PairingAttempt attempt})> startPairing({
    required String planId,
    required int version,
    required String enclosureId,
    required DateTime startedAt,
    String timezone = 'Asia/Shanghai',
  }) async {
    final response = await _api.startPairing(
      planId: planId,
      idempotencyKey: _key(),
      ifMatch: _etag(version),
      startPairingRequest: api.StartPairingRequest(
        enclosureId: enclosureId,
        startedAt: startedAt,
        timezone: timezone,
      ),
    );
    final data = response.data!.data;
    return (plan: _plan(data.breedingPlan), attempt: _attempt(data.pairingAttempt));
  }

  @override
  Future<({BreedingPlan plan, PairingAttempt attempt})> separatePairing({
    required String planId,
    required String attemptId,
    required int planVersion,
    required int attemptVersion,
    required DateTime separatedAt,
    required String result,
    required String sireDestinationEnclosureId,
    required String damDestinationEnclosureId,
    String timezone = 'Asia/Shanghai',
  }) async {
    final response = await _api.separatePairing(
      attemptId: attemptId,
      idempotencyKey: _key(),
      ifMatch: _etag(attemptVersion),
      separatePairingRequest: api.SeparatePairingRequest(
        endedAt: separatedAt,
        separatedAt: separatedAt,
        result: _pairingResult(result),
        sireDestinationEnclosureId: sireDestinationEnclosureId,
        damDestinationEnclosureId: damDestinationEnclosureId,
        safetyStop: false,
        timezone: timezone,
      ),
    );
    final data = response.data!.data;
    return (plan: _plan(data.breedingPlan), attempt: _attempt(data.pairingAttempt));
  }

  @override
  Future<BreedingPlan> startGestation({
    required String planId,
    required int version,
    required String pairingAttemptId,
    required String result,
    required DateTime baselineAt,
    String timezone = 'Asia/Shanghai',
  }) async {
    final response = await _api.startGestationMonitoring(
      planId: planId,
      idempotencyKey: _key(),
      ifMatch: _etag(version),
      startGestationRequest: api.StartGestationRequest(
        pairingAttemptId: pairingAttemptId,
        result: _gestationResult(result),
        baselineAt: baselineAt,
        timezone: timezone,
      ),
    );
    return _plan(response.data!.data.breedingPlan);
  }

  @override
  Future<({BreedingPlan plan, String? litterId})> confirmBirth({
    required String planId,
    required int version,
    required DateTime bornAt,
    required String enclosureId,
    required int initialAliveCount,
    int initialOtherCount = 0,
    String timezone = 'Asia/Shanghai',
  }) async {
    final response = await _api.confirmBirth(
      planId: planId,
      idempotencyKey: _key(),
      ifMatch: _etag(version),
      confirmBirthRequest: api.ConfirmBirthRequest(
        bornAt: bornAt,
        enclosureId: initialAliveCount > 0 ? enclosureId : null,
        initialAliveCount: initialAliveCount,
        initialOtherCount: initialOtherCount,
        damCondition: api.DamCondition(
          status: api.DamConditionStatusEnum.stable,
        ),
        outcomeReason: initialAliveCount > 0
            ? 'live_pups_observed'
            : 'no_live_pups',
        timezone: timezone,
      ),
    );
    final data = response.data!.data;
    return (plan: _plan(data.breedingPlan), litterId: data.litter.id);
  }
}

String breedingErrorMessage(Object error) {
  if (error is BreedingRepositoryException) return error.message;
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
