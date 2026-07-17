import 'package:flutter/foundation.dart';

import '../i2/i2_models.dart';
import 'breeding_models.dart';
import 'breeding_repository.dart';

class BreedingController extends ChangeNotifier {
  BreedingController({required this.repository});

  final BreedingRepository repository;

  I2AsyncState<List<BreedingPlan>> listState = const I2AsyncState.idle();
  I2AsyncState<void> actionState = const I2AsyncState.idle();
  BreedingPlan? selected;
  PairingAttempt? activeAttempt;
  String? lastMessage;

  Future<void> refresh() async {
    listState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final plans = await repository.listPlans();
      listState = plans.isEmpty
          ? const I2AsyncState.empty(message: '还没有繁育计划')
          : I2AsyncState.data(plans);
      if (selected != null) {
        selected = plans.cast<BreedingPlan?>().firstWhere(
          (p) => p?.id == selected!.id,
          orElse: () => selected,
        );
      }
    } catch (error) {
      listState = I2AsyncState.error(breedingErrorMessage(error));
    }
    notifyListeners();
  }

  void select(BreedingPlan? plan) {
    selected = plan;
    if (plan?.activePairingAttemptId == null) {
      activeAttempt = null;
    }
    notifyListeners();
  }

  Future<bool> createPlan(CreateBreedingPlanInput input) async {
    return _run(() async {
      final plan = await repository.createPlan(input);
      selected = plan;
      lastMessage = '已创建草稿计划';
      await refresh();
      select(plan);
    });
  }

  Future<bool> advanceHappyPath({
    required String enclosureId,
    String sireDestinationEnclosureId = '',
    String damDestinationEnclosureId = '',
    int livePups = 4,
  }) async {
    final plan = selected;
    if (plan == null) {
      lastMessage = '请先选择计划';
      notifyListeners();
      return false;
    }
    final now = DateTime.now().toUtc();
    final sireDest = sireDestinationEnclosureId.isEmpty
        ? enclosureId
        : sireDestinationEnclosureId;
    final damDest = damDestinationEnclosureId.isEmpty
        ? enclosureId
        : damDestinationEnclosureId;

    return _run(() async {
      switch (plan.state) {
        case 'draft':
          selected = await repository.publishPlan(
            planId: plan.id,
            version: plan.version,
            plannedPairingAt: now,
            pairingEnclosureId: enclosureId,
          );
          lastMessage = '计划已发布，可开始配对';
        case 'pair_ready':
          final result = await repository.startPairing(
            planId: plan.id,
            version: plan.version,
            enclosureId: enclosureId,
            startedAt: now,
          );
          selected = result.plan;
          activeAttempt = result.attempt;
          lastMessage = '配对已开始，请观察后分笼';
        case 'pairing':
          final attemptId =
              activeAttempt?.id ?? plan.activePairingAttemptId ?? '';
          if (attemptId.isEmpty) {
            throw const BreedingRepositoryException('缺少配对记录，请刷新');
          }
          final result = await repository.separatePairing(
            planId: plan.id,
            attemptId: attemptId,
            planVersion: plan.version,
            attemptVersion: activeAttempt?.version ?? 1,
            separatedAt: now,
            result: 'effective',
            sireDestinationEnclosureId: sireDest,
            damDestinationEnclosureId: damDest,
          );
          selected = result.plan;
          activeAttempt = result.attempt;
          lastMessage = '已分笼，可进入孕期观察';
        case 'post_pair':
          final attemptId =
              activeAttempt?.id ?? plan.activePairingAttemptId ?? '';
          if (attemptId.isEmpty) {
            throw const BreedingRepositoryException('缺少配对记录，请刷新');
          }
          selected = await repository.startGestation(
            planId: plan.id,
            version: plan.version,
            pairingAttemptId: attemptId,
            result: 'effective',
            baselineAt: now,
          );
          lastMessage = '已进入孕期观察';
        case 'gestation':
          final result = await repository.confirmBirth(
            planId: plan.id,
            version: plan.version,
            bornAt: now,
            enclosureId: enclosureId,
            initialAliveCount: livePups,
          );
          selected = result.plan;
          lastMessage = result.litterId == null
              ? '已记录无活仔结果'
              : '产仔确认成功，窝次 ${result.litterId}';
        default:
          lastMessage = '当前状态无需继续主路径动作';
      }
      await refresh();
    });
  }

  Future<bool> _run(Future<void> Function() body) async {
    actionState = const I2AsyncState.loading();
    lastMessage = null;
    notifyListeners();
    try {
      await body();
      actionState = const I2AsyncState.data(null);
      notifyListeners();
      return true;
    } catch (error) {
      final message = breedingErrorMessage(error);
      actionState = I2AsyncState.error(message);
      lastMessage = message;
      notifyListeners();
      return false;
    }
  }
}
