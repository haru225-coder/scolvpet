import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/data/i2_repository.dart';
import 'package:scolvpet_mobile/features/i2/i2_controller.dart';
import 'package:scolvpet_mobile/features/i2/i2_enclosures.dart';
import 'package:scolvpet_mobile/features/i2/i2_models.dart';
import 'package:scolvpet_mobile/features/i2/i2_widgets.dart';

void main() {
  I2Enclosure enclosure({
    required String id,
    required String state,
    String cleanliness = 'clean',
    List<String> occupants = const [],
  }) {
    return I2Enclosure(
      id: id,
      code: id.toUpperCase(),
      rackCode: 'A',
      levelCode: '1',
      state: state,
      cleanlinessState: cleanliness,
      capacity: 2,
      equipment: const [],
      lastCleanedAt: null,
      currentHamsterIds: occupants,
      version: 1,
    );
  }

  test('enclosureBoardTone distinguishes vacant/occupied/isolation/dirty', () {
    expect(
      enclosureBoardTone(enclosure(id: 'e1', state: 'vacant')),
      EnclosureBoardTone.vacant,
    );
    expect(
      enclosureBoardTone(
        enclosure(id: 'e2', state: 'occupied_single', occupants: ['h1']),
      ),
      EnclosureBoardTone.occupied,
    );
    expect(
      enclosureBoardTone(
        enclosure(id: 'e3', state: 'isolation', occupants: ['h2']),
      ),
      EnclosureBoardTone.isolation,
    );
    expect(
      enclosureBoardTone(
        enclosure(
          id: 'e4',
          state: 'occupied_single',
          cleanliness: 'dirty',
          occupants: ['h3'],
        ),
      ),
      EnclosureBoardTone.dirty,
    );
    expect(
      enclosureBoardTone(enclosure(id: 'e5', state: 'pairing_temp', occupants: ['h4', 'h5'])),
      EnclosureBoardTone.pairing,
    );
  });

  test('enclosureStateForPurpose maps stay purpose', () {
    expect(enclosureStateForPurpose('isolation', occupantCount: 1), 'isolation');
    expect(
      enclosureStateForPurpose('single', occupantCount: 1),
      'occupied_single',
    );
    expect(enclosureStateForPurpose('single', occupantCount: 0), 'vacant');
    expect(enclosureStateForPurpose('pairing_temp', occupantCount: 2), 'pairing_temp');
  });

  test('MemoryI2Repository.moveHamster writes stay and updates board state', () async {
    final repo = MemoryI2Repository(
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
        litters: const [],
        enclosures: [
          enclosure(id: 'e-vacant', state: 'vacant'),
          enclosure(
            id: 'e-old',
            state: 'occupied_single',
            occupants: const ['h1'],
          ),
        ],
        lastSyncedAt: DateTime.utc(2026, 7, 1),
      ),
    );
    // Seed old occupancy on hamster.
    await repo.updateHamster(
      'h1',
      1,
      const I2HamsterUpdate(),
    );
    // Manually set current enclosure via move into vacant with isolation.
    // First put hamster on e-old by a move.
    final stay = await repo.moveHamster(
      I2MoveDraft(
        enclosureId: 'e-vacant',
        hamsterId: 'h1',
        purpose: 'isolation',
        startedAt: DateTime.utc(2026, 7, 17, 10),
      ),
      enclosureVersion: 1,
    );
    expect(stay.enclosureId, 'e-vacant');
    expect(stay.purpose, 'isolation');
    expect(stay.endedAt, isNull);

    final snapshot = await repo.loadSnapshot();
    final target = snapshot.enclosures.firstWhere((e) => e.id == 'e-vacant');
    expect(target.state, 'isolation');
    expect(target.currentHamsterIds, ['h1']);
    expect(
      enclosureBoardTone(target),
      EnclosureBoardTone.isolation,
    );

    final detail = await repo.getEnclosureDetail('e-vacant');
    expect(detail.stays, isNotEmpty);
    expect(detail.stays.first.hamsterId, 'h1');

    final hamster = snapshot.hamsters.single;
    expect(hamster.currentEnclosureId, 'e-vacant');
  });

  testWidgets('EnclosureGridPage shows legend and colored tiles', (tester) async {
    final controller = I2Controller(
      repository: MemoryI2Repository(
        snapshot: I2Snapshot(
          hamsters: const [],
          litters: const [],
          enclosures: [
            enclosure(id: 'e1', state: 'vacant'),
            enclosure(
              id: 'e2',
              state: 'isolation',
              occupants: const ['h9'],
            ),
          ],
          lastSyncedAt: DateTime.utc(2026, 7, 1),
        ),
      ),
    );
    await controller.restore();

    await tester.pumpWidget(
      MaterialApp(home: EnclosureGridPage(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('空置'), findsWidgets);
    expect(find.text('隔离'), findsWidgets);
    expect(find.byKey(const Key('enclosure-tile-e1')), findsOneWidget);
    expect(find.byKey(const Key('enclosure-tile-e2')), findsOneWidget);
    expect(find.textContaining('无人入住'), findsOneWidget);
    expect(find.textContaining('在住 1'), findsOneWidget);
  });

  test('I2Controller.moveHamster refreshes snapshot occupancy', () async {
    final repo = MemoryI2Repository(
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
        litters: const [],
        enclosures: [enclosure(id: 'e1', state: 'vacant')],
        lastSyncedAt: DateTime.utc(2026, 7, 1),
      ),
    );
    final controller = I2Controller(repository: repo);
    await controller.restore();
    await controller.moveHamster(
      I2MoveDraft(
        enclosureId: 'e1',
        hamsterId: 'h1',
        purpose: 'single',
        startedAt: DateTime.utc(2026, 7, 17),
      ),
      enclosureVersion: 1,
    );
    expect(controller.actionState.status, I2AsyncStatus.data);
    final enc = controller.snapshotState.data!.enclosures.single;
    expect(enc.currentHamsterIds, ['h1']);
    expect(enc.state, 'occupied_single');
  });
}
