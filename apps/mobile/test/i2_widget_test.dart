import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/i2/i2_controller.dart';
import 'package:scolvpet_mobile/features/i2/i2_hamsters.dart';
import 'package:scolvpet_mobile/features/i2/i2_models.dart';
import 'support/memory_repositories.dart';

void main() {
  testWidgets('hamster list renders cached data and offline banner', (
    tester,
  ) async {
    final local = MemoryI2LocalStore();
    await local.saveSnapshot(
      I2Snapshot(
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
            currentEnclosureId: null,
            litterId: null,
            notes: null,
            version: 1,
          ),
        ],
        litters: const <I2Litter>[],
        enclosures: const <I2Enclosure>[],
        lastSyncedAt: DateTime.utc(2025, 1, 1),
      ),
    );
    final controller = I2Controller(
      repository: MemoryI2Repository(failReads: true),
      localStore: local,
    );
    await controller.restore();

    await tester.pumpWidget(
      MaterialApp(home: HamsterListPage(controller: controller)),
    );

    expect(find.text('仓鼠'), findsOneWidget);
    expect(find.textContaining('H-001'), findsOneWidget);
    expect(find.textContaining('离线只读'), findsOneWidget);
  });
}
