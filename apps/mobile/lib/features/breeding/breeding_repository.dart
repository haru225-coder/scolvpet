import 'package:dio/dio.dart';
import 'package:scolvpet_api/scolvpet_api.dart' as api;
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
import '../../core/api_error.dart';
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
    // Parse with local flexible models. Generated BreedingPlan rejects empty
    // kinship_check: {} (HTTP 200) which surfaces as “请求失败（200）”.
    final response = await client.dio.get<Map<String, dynamic>>(
      '/breeding-plans',
      queryParameters: const {'limit': 50},
    );
    final raw = response.data?['data'];
    if (raw is! List) return const <BreedingPlan>[];
    return raw
        .whereType<Map>()
        .map((e) => BreedingPlan.fromJson(Map<String, dynamic>.from(e)))
        .toList();
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
    return (
      plan: _plan(data.breedingPlan),
      attempt: _attempt(data.pairingAttempt),
    );
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
    return (
      plan: _plan(data.breedingPlan),
      attempt: _attempt(data.pairingAttempt),
    );
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

String breedingErrorMessage(Object error) => apiErrorMessage(
  error,
  fallback: '请求失败',
  nonDioFallback: '繁育操作暂时未完成，请稍后重试',
  mapLocal: (e) => e is BreedingRepositoryException ? e.message : null,
  mapDio: (e) {
    if (e.type == DioExceptionType.connectionError) return '网络不可用，请稍后重试';
    final code = e.response?.statusCode;
    // Generated codecs throw DioException even on 2xx when JSON shape mismatches.
    if (code != null && code >= 200 && code < 300) {
      return '繁育数据格式异常，请稍后重试或联系支持';
    }
    return '请求失败（${code ?? e.type.name}）';
  },
);
