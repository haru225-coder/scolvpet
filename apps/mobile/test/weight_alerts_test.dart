import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/i2/i2_controller.dart';
import 'package:scolvpet_mobile/features/i2/i2_models.dart';
import 'package:scolvpet_mobile/features/shell/home_overview.dart';
import 'package:scolvpet_mobile/features/weight/weight_alerts.dart';
import 'support/memory_repositories.dart';

void main() {
  final t0 = DateTime.utc(2026, 7, 1, 10);
  final t1 = DateTime.utc(2026, 7, 2, 10);

  I2WeightRecord record({
    required String id,
    required String hamsterId,
    required num weightG,
    required DateTime recordedAt,
    num? previousWeightG,
    num? changeFromPreviousG,
    num? birthWeightG,
    List<String> alertFlags = const [],
  }) {
    return I2WeightRecord(
      id: id,
      hamsterId: hamsterId,
      litterId: null,
      measurementKind: 'individual',
      subjectCount: 1,
      weightG: weightG,
      recordedAt: recordedAt,
      source: 'manual',
      previousWeightG: previousWeightG,
      changeFromPreviousG: changeFromPreviousG,
      birthWeightG: birthWeightG,
      alertFlags: alertFlags,
      notes: null,
    );
  }

  group('evaluateWeightFlags', () {
    test('flags below absolute min weight', () {
      final flags = evaluateWeightFlags(
        record(id: 'w1', hamsterId: 'h1', weightG: 15, recordedAt: t0),
      );
      expect(flags, contains('below_min_weight'));
    });

    test('flags absolute drop from previous', () {
      final flags = evaluateWeightFlags(
        record(
          id: 'w2',
          hamsterId: 'h1',
          weightG: 100,
          recordedAt: t1,
          previousWeightG: 110,
          changeFromPreviousG: -10,
        ),
      );
      expect(flags, contains('drop_from_previous'));
    });

    test('flags relative drop of 8% without absolute 3g', () {
      // 2g drop on 20g baseline is 10% → relative rule
      final flags = evaluateWeightFlags(
        record(
          id: 'w3',
          hamsterId: 'h1',
          weightG: 18,
          recordedAt: t1,
          previousWeightG: 20,
          changeFromPreviousG: -2,
        ),
      );
      expect(flags, contains('drop_from_previous'));
      expect(flags, contains('below_min_weight'));
    });

    test('flags below birth weight', () {
      final flags = evaluateWeightFlags(
        record(
          id: 'w4',
          hamsterId: 'h1',
          weightG: 25,
          recordedAt: t1,
          previousWeightG: 28,
          changeFromPreviousG: -3,
          birthWeightG: 26,
        ),
      );
      expect(flags, contains('below_birth_weight'));
      expect(flags, contains('drop_from_previous'));
    });

    test('normal weight has no flags', () {
      final flags = evaluateWeightFlags(
        record(
          id: 'w5',
          hamsterId: 'h1',
          weightG: 120,
          recordedAt: t1,
          previousWeightG: 118,
          changeFromPreviousG: 2,
        ),
      );
      expect(flags, isEmpty);
    });

    test('preserves server outside_reference flag', () {
      final flags = evaluateWeightFlags(
        record(
          id: 'w6',
          hamsterId: 'h1',
          weightG: 120,
          recordedAt: t0,
          alertFlags: const ['outside_reference'],
        ),
      );
      expect(flags, contains('outside_reference'));
    });
  });

  group('buildWeightRecord', () {
    test('computes change and alerts on drop', () {
      final previous = record(
        id: 'w-prev',
        hamsterId: 'h1',
        weightG: 50,
        recordedAt: t0,
        birthWeightG: 12,
      );
      final next = buildWeightRecord(
        id: 'w-next',
        draft: I2WeightDraft(
          hamsterId: 'h1',
          weightG: 45,
          recordedAt: t1,
        ),
        previous: previous,
      );
      expect(next.previousWeightG, 50);
      expect(next.changeFromPreviousG, -5);
      expect(next.birthWeightG, 12);
      expect(next.alertFlags, contains('drop_from_previous'));
    });
  });

  group('buildWeightAlerts', () {
    test('uses latest record per hamster only', () {
      final alerts = buildWeightAlerts([
        record(id: 'old', hamsterId: 'h1', weightG: 15, recordedAt: t0),
        record(
          id: 'new',
          hamsterId: 'h1',
          weightG: 130,
          recordedAt: t1,
          previousWeightG: 15,
          changeFromPreviousG: 115,
        ),
        record(id: 'h2-low', hamsterId: 'h2', weightG: 10, recordedAt: t1),
      ]);
      expect(alerts, hasLength(1));
      expect(alerts.single.hamsterId, 'h2');
      expect(alerts.single.summary, contains('低于阈值'));
    });
  });

  test('HomeOverviewMetrics counts weight alerts in attention', () {
    final metrics = HomeOverviewMetrics.fromSnapshot(
      snapshot: I2Snapshot(
        hamsters: const [
          I2Hamster(
            id: 'h1',
            internalCode: 'H-1',
            name: '雪团',
            sex: 'female',
            varietyCode: 'golden',
            lifecycleStatus: 'active',
            breedingStatus: 'candidate',
            birthDate: null,
            currentEnclosureId: null,
            litterId: null,
            notes: null,
            version: 1,
          ),
        ],
        litters: const <I2Litter>[],
        enclosures: const <I2Enclosure>[],
        lastSyncedAt: t1,
        recentWeights: [
          record(
            id: 'w-drop',
            hamsterId: 'h1',
            weightG: 90,
            recordedAt: t1,
            previousWeightG: 100,
            changeFromPreviousG: -10,
          ),
        ],
      ),
      drafts: const [],
      offline: false,
      now: t1,
    );
    expect(metrics.weightAlertCount, 1);
    expect(metrics.attentionCount, 1);
    expect(metrics.weightAlerts.single.summary, contains('掉重'));
  });

  test('createWeightsBatch stores gram records with alert flags', () async {
    final controller = I2Controller(
      repository: MemoryI2Repository(
        snapshot: I2Snapshot(
          hamsters: const [
            I2Hamster(
              id: 'h1',
              internalCode: 'H-1',
              name: '雪团',
              sex: 'female',
              varietyCode: 'golden',
              lifecycleStatus: 'active',
              breedingStatus: 'candidate',
              birthDate: null,
              currentEnclosureId: null,
              litterId: null,
              notes: null,
              version: 1,
            ),
          ],
          litters: const <I2Litter>[],
          enclosures: const <I2Enclosure>[],
          lastSyncedAt: t0,
          recentWeights: [
            record(
              id: 'w0',
              hamsterId: 'h1',
              weightG: 100,
              recordedAt: t0,
            ),
          ],
        ),
      ),
    );
    await controller.restore();
    await controller.createWeightsBatch([
      I2WeightDraft(hamsterId: 'h1', weightG: 90, recordedAt: t1),
    ]);

    expect(controller.actionState.status, I2AsyncStatus.data);
    final weights = controller.snapshotState.data!.recentWeights;
    expect(weights, isNotEmpty);
    final latest = weights.firstWhere((w) => w.weightG == 90);
    expect(latest.alertFlags, contains('drop_from_previous'));
    expect(latest.changeFromPreviousG, -10);

    final alerts = buildWeightAlerts(weights);
    expect(alerts, hasLength(1));
  });
}
