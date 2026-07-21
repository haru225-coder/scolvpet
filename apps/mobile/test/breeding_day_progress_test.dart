import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/breeding/breeding_models.dart';

BreedingPlan _plan({
  required String state,
  DateTime? plannedPairingAt,
  DateTime? matingBaselineAt,
}) {
  return BreedingPlan(
    id: 'p1',
    sireId: 's',
    damId: 'd',
    ruleVersionId: 'r',
    state: state,
    version: 1,
    plannedPairingAt: plannedPairingAt,
    matingBaselineAt: matingBaselineAt,
  );
}

void main() {
  // 使用本地中午时刻，避免 UTC 午夜在东八区跨日。
  final now = DateTime(2026, 7, 20, 12);

  group('breedingDayProgressLabel / planned pairing', () {
    test('新计划 draft：显示计划配对日，不显示 Day N', () {
      final plan = _plan(
        state: 'draft',
        plannedPairingAt: DateTime(2026, 7, 22, 12),
      );
      expect(breedingPlannedPairingLabel(plan), '计划配对日 2026-07-22');
      expect(breedingDayProgressLabel(plan, now: now), isNull);
    });

    test('pair_ready 陈旧计划：不因 planned_pairing_at 显示 Day 201', () {
      final plan = _plan(
        state: 'pair_ready',
        plannedPairingAt: DateTime(2025, 12, 31, 12),
      );
      expect(breedingPlannedPairingLabel(plan), '计划配对日 2025-12-31');
      // 旧逻辑：now - planned ≈ 201 天；现必须为 null。
      final staleDays = now.difference(plan.plannedPairingAt!).inDays;
      expect(staleDays, greaterThan(100));
      expect(breedingDayProgressLabel(plan, now: now), isNull);
    });

    test('已开始配对：仅在有 pairingStartedAt 时显示 Day N', () {
      final plan = _plan(
        state: 'pairing',
        plannedPairingAt: DateTime(2025, 12, 31, 12), // 陈旧计划日不得参与
      );
      expect(breedingPlannedPairingLabel(plan), isNull);
      expect(breedingDayProgressLabel(plan, now: now), isNull);
      expect(
        breedingDayProgressLabel(
          plan,
          now: now,
          pairingStartedAt: DateTime(2026, 7, 18, 12),
        ),
        'Day 2',
      );
    });

    test('妊娠：使用 mating_baseline_at 显示 Day N', () {
      final plan = _plan(
        state: 'gestation',
        plannedPairingAt: DateTime(2025, 12, 31, 12),
        matingBaselineAt: DateTime(2026, 7, 10, 12),
      );
      expect(breedingPlannedPairingLabel(plan), isNull);
      expect(breedingDayProgressLabel(plan, now: now), 'Day 10');
    });

    test('妊娠但无 baseline：不显示 Day N（禁止用 planned 回退）', () {
      final plan = _plan(
        state: 'gestation',
        plannedPairingAt: DateTime(2026, 1, 1, 12),
      );
      expect(breedingDayProgressLabel(plan, now: now), isNull);
    });

    test('已完成 / 已取消 / 无活仔：不显示 Day N', () {
      for (final state in [
        'completed',
        'cancelled',
        'unsuccessful',
        'no_litter_outcome',
        'litter_nursing',
        'post_pair',
      ]) {
        final plan = _plan(
          state: state,
          plannedPairingAt: DateTime(2026, 1, 1, 12),
          matingBaselineAt: DateTime(2026, 7, 1, 12),
        );
        expect(
          breedingDayProgressLabel(plan, now: now),
          isNull,
          reason: 'state=$state 不得显示 Day N',
        );
        expect(breedingPlannedPairingLabel(plan), isNull);
      }
    });

    test('日历日差：同日为 Day 0', () {
      final plan = _plan(
        state: 'gestation',
        matingBaselineAt: DateTime(2026, 7, 20, 1),
      );
      expect(breedingDayProgressLabel(plan, now: now), 'Day 0');
    });
  });

  test('BreedingPlan.fromJson 读取 mating_baseline_at', () {
    final plan = BreedingPlan.fromJson({
      'id': '1',
      'sire_id': 's',
      'dam_id': 'd',
      'rule_version_id': 'r',
      'state': 'gestation',
      'version': 2,
      // 本地中午 ISO，避免跨日
      'mating_baseline_at': DateTime(2026, 7, 10, 12).toIso8601String(),
    });
    expect(plan.matingBaselineAt, isNotNull);
    expect(breedingDayProgressLabel(plan, now: now), 'Day 10');
  });
}
