// Test doubles only — not part of production lib.
// Moved out of lib/ per docs/engineering/复杂度收敛约定.md

import 'package:scolvpet_mobile/features/breeding/breeding_models.dart';
import 'package:scolvpet_mobile/features/breeding/breeding_repository.dart';

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
      matingBaselineAt: baselineAt,
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

