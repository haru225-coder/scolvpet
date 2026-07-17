import '../breeding/breeding_models.dart';
import '../tasks/task_models.dart';

/// Pure helper: care tasks to seed after a breeding plan state transition.
///
/// Covers C-TK-01 partial gap — client-side auto task creation after happy-path
/// advances (publish / pair / separate / gestation / birth).
List<CreateCareTaskDraft> breedingTasksForTransition({
  required BreedingPlan planBefore,
  required BreedingPlan planAfter,
  required String enclosureId,
  String? litterId,
  int livePups = 0,
  DateTime? now,
  int weaningDayOffset = 21,
}) {
  final clock = now ?? DateTime.now().toUtc();
  final drafts = <CreateCareTaskDraft>[];
  final before = planBefore.state;
  final after = planAfter.state;

  if (before == 'draft' && after == 'pair_ready') {
    drafts.add(
      CreateCareTaskDraft(
        taskType: 'pair_prep',
        targetType: 'breeding_plan',
        targetId: planAfter.id,
        scheduledAt: clock,
        priority: 'normal',
        title: '${planAfter.displayName} · 配种准备',
      ),
    );
  }

  if (before == 'pair_ready' && after == 'pairing') {
    drafts.add(
      CreateCareTaskDraft(
        taskType: 'pairing_timeout',
        targetType: 'breeding_plan',
        targetId: planAfter.id,
        scheduledAt: clock.add(const Duration(hours: 12)),
        priority: 'high',
        title: '${planAfter.displayName} · 合笼观察/超时',
      ),
    );
  }

  if (before == 'pairing' &&
      (after == 'post_pair' || after == 'gestation' || after == 'separated')) {
    drafts.add(
      CreateCareTaskDraft(
        taskType: 'separate_now',
        targetType: 'breeding_plan',
        targetId: planAfter.id,
        scheduledAt: clock,
        priority: 'high',
        title: '${planAfter.displayName} · 已分笼复核',
      ),
    );
  }

  if ((before == 'post_pair' || before == 'pairing') && after == 'gestation') {
    drafts.add(
      CreateCareTaskDraft(
        taskType: 'gestation_window',
        targetType: 'breeding_plan',
        targetId: planAfter.id,
        scheduledAt:
            planAfter.expectedBirthStart?.toUtc() ??
            clock.add(const Duration(days: 16)),
        priority: 'normal',
        title: '${planAfter.displayName} · 预产窗口',
      ),
    );
    drafts.add(
      CreateCareTaskDraft(
        taskType: 'no_birth_review',
        targetType: 'breeding_plan',
        targetId: planAfter.id,
        scheduledAt:
            planAfter.expectedBirthEnd?.toUtc() ??
            clock.add(const Duration(days: 20)),
        priority: 'normal',
        title: '${planAfter.displayName} · 未产仔复核',
      ),
    );
  }

  if (before == 'gestation' &&
      (after == 'litter_nursing' ||
          after == 'completed' ||
          after == 'birth_recorded' ||
          after.contains('litter') ||
          after == 'closed' ||
          planAfter.litterId != null ||
          litterId != null)) {
    final lid = litterId ?? planAfter.litterId;
    if (lid != null && livePups > 0) {
      drafts.add(
        CreateCareTaskDraft(
          taskType: 'litter_observation',
          targetType: 'litter',
          targetId: lid,
          scheduledAt: clock.add(const Duration(days: 1)),
          priority: 'high',
          title: '窝次观察 · $lid',
        ),
      );
      drafts.add(
        CreateCareTaskDraft(
          taskType: 'weaning',
          targetType: 'litter',
          targetId: lid,
          scheduledAt: clock.add(Duration(days: weaningDayOffset)),
          priority: 'high',
          title: '断奶窗口 · $lid',
        ),
      );
      drafts.add(
        CreateCareTaskDraft(
          taskType: 'pup_weight_check',
          targetType: 'litter',
          targetId: lid,
          scheduledAt: clock.add(const Duration(days: 2)),
          priority: 'normal',
          title: '幼崽称重 · $lid',
        ),
      );
    } else {
      drafts.add(
        CreateCareTaskDraft(
          taskType: 'no_birth_review',
          targetType: 'breeding_plan',
          targetId: planAfter.id,
          scheduledAt: clock,
          priority: 'normal',
          title: '${planAfter.displayName} · 无活仔复核',
        ),
      );
    }
  }

  return drafts;
}
