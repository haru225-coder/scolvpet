import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/i2/i2_controller.dart';
import 'package:scolvpet_mobile/features/i2/i2_models.dart';
import 'support/memory_repositories.dart';

void main() {
  final cached = I2Snapshot(
    hamsters: [
      const I2Hamster(
        id: 'h-1',
        internalCode: 'H-001',
        name: '雪团',
        sex: 'female',
        varietyCode: 'golden',
        lifecycleStatus: 'active',
        breedingStatus: 'candidate',
        birthDate: null,
        currentEnclosureId: 'e-1',
        litterId: null,
        notes: null,
        version: 1,
      ),
    ],
    litters: const <I2Litter>[],
    enclosures: const <I2Enclosure>[],
    lastSyncedAt: DateTime.utc(2025, 1, 1),
  );

  test('resetForLogout clears import wizard and weight batch residue', () async {
    final local = MemoryI2LocalStore()..saveSnapshot(cached);
    final controller = I2Controller(
      repository: MemoryI2Repository(),
      localStore: local,
    );
    await controller.restore();
    controller.importStage = I2ImportStage.mapping;
    controller.importRows = const [
      I2ImportRowResult(
        rowNumber: 1,
        status: 'imported',
        mappedValues: {'name': '上一账号的仓鼠'},
        issues: [],
      ),
    ];

    controller.resetForLogout();

    expect(controller.importStage, I2ImportStage.idle);
    expect(controller.importJob, isNull);
    expect(controller.importRows, isEmpty);
    expect(controller.weightBatchResult, isNull);
    expect(controller.snapshotState.status, I2AsyncStatus.idle);
    expect(controller.drafts, isEmpty);
  });

  test('offline restore exposes cached read-only snapshot', () async {
    final local = MemoryI2LocalStore()..saveSnapshot(cached);
    final controller = I2Controller(
      repository: MemoryI2Repository(failReads: true),
      localStore: local,
    );

    await controller.restore();

    expect(controller.offline, isTrue);
    expect(controller.snapshotState.status, I2AsyncStatus.data);
    expect(
      controller.snapshotState.data!.hamsters.single.internalCode,
      'H-001',
    );
    expect(controller.canWrite, isFalse);
  });

  test('offline write saves draft and keeps write entry disabled', () async {
    final local = MemoryI2LocalStore()..saveSnapshot(cached);
    final controller = I2Controller(
      repository: MemoryI2Repository(failReads: true),
      localStore: local,
    );
    await controller.restore();

    await controller.createHamster(
      const I2HamsterDraft(
        internalCode: 'H-002',
        speciesRuleVersionId: 'rule-1',
        sex: 'unknown',
        sourceType: 'introduced',
      ),
    );

    expect(controller.drafts, hasLength(1));
    expect(controller.actionState.status, I2AsyncStatus.error);
    expect(controller.actionState.message, contains('草稿已保存'));
  });
}
