import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/i2/i2_models.dart';
import 'package:scolvpet_mobile/features/litter/litter.dart';

List<LitterPupSeparation> _separationsFor(
  LitterBoard board, {
  required String maleEnclosureId,
  required String femaleEnclosureId,
}) {
  return [
    for (var i = 0; i < board.alivePups.length; i++)
      LitterPupSeparation(
        pupIdentityId: board.alivePups[i].id,
        sex: i.isEven ? 'male' : 'female',
        destinationEnclosureId: i.isEven ? maleEnclosureId : femaleEnclosureId,
      ),
  ];
}

List<LitterPupProfileDraft> _profilesFor(LitterBoard board) {
  return [
    for (var i = 0; i < board.alivePups.length; i++)
      LitterPupProfileDraft(
        pupIdentityId: board.alivePups[i].id,
        internalCode: 'H-${board.code ?? board.id}-${i + 1}',
        name: board.alivePups[i].temporaryCode,
      ),
  ];
}

void main() {
  test('nextLitterAction only opens after weaning is due', () {
    expect(nextLitterAction('nursing'), isNull);
    expect(nextLitterAction('newborn'), isNull);
    expect(nextLitterAction('weaning_due'), LitterBoardAction.wean);
    expect(nextLitterAction('sexing_due'), LitterBoardAction.sexAndSeparate);
    expect(
      nextLitterAction('individualizing'),
      LitterBoardAction.individualize,
    );
    expect(nextLitterAction('closed'), isNull);
  });

  test('MemoryLitterBoardRepository full happy path', () async {
    final repo = MemoryLitterBoardRepository();
    final seeded = repo.seedNursingLitter(pupCount: 4, enclosureId: 'enc-1');
    // Force due state so wean is allowed; nursing/newborn stay read-only.
    final due = LitterBoard(
      id: seeded.id,
      code: seeded.code,
      state: 'weaning_due',
      version: seeded.version,
      bornAt: seeded.bornAt,
      initialAliveCount: seeded.initialAliveCount,
      currentManagedCount: seeded.currentManagedCount,
      enclosureId: seeded.enclosureId,
      pups: seeded.pups,
      sireId: seeded.sireId,
      damId: seeded.damId,
    );
    // Replace seeded board with weaning_due via private list by re-wean path:
    // seed then overwrite through wean precondition by using sex seed helper.
    final store = MemoryLitterBoardRepository(seed: [due]);

    var board = await store.wean(litterId: due.id, version: due.version);
    expect(board.state, 'sexing_due');
    expect(board.pups.every((p) => !p.isAlive || p.weaned), isTrue);

    board = await store.sexAndSeparate(
      litterId: board.id,
      version: board.version,
      assignments: _separationsFor(
        board,
        maleEnclosureId: 'enc-m',
        femaleEnclosureId: 'enc-f',
      ),
    );
    expect(board.state, 'individualizing');
    expect(board.alivePups.every((p) => p.sexAssigned), isTrue);

    board = await store.individualize(
      litterId: board.id,
      version: board.version,
      profiles: _profilesFor(board),
    );
    expect(board.state, 'closed');
    expect(board.alivePups.every((p) => p.individualized), isTrue);
    expect(board.currentManagedCount, 0);
  });

  test('MemoryLitterBoardRepository rejects mixed-sex enclosure', () async {
    final due = MemoryLitterBoardRepository().seedNursingLitter(pupCount: 2);
    final repo = MemoryLitterBoardRepository(
      seed: [
        LitterBoard(
          id: due.id,
          code: due.code,
          state: 'weaning_due',
          version: due.version,
          bornAt: due.bornAt,
          initialAliveCount: due.initialAliveCount,
          currentManagedCount: due.currentManagedCount,
          enclosureId: due.enclosureId,
          pups: due.pups,
        ),
      ],
    );
    final weaned = await repo.wean(litterId: due.id, version: due.version);

    expect(
      () => repo.sexAndSeparate(
        litterId: weaned.id,
        version: weaned.version,
        assignments: [
          LitterPupSeparation(
            pupIdentityId: weaned.alivePups[0].id,
            sex: 'male',
            destinationEnclosureId: 'enc-shared',
          ),
          LitterPupSeparation(
            pupIdentityId: weaned.alivePups[1].id,
            sex: 'female',
            destinationEnclosureId: 'enc-shared',
          ),
        ],
      ),
      throwsA(isA<LitterBoardRepositoryException>()),
    );
  });

  test('LitterBoardController advances next actions', () async {
    final seeded = MemoryLitterBoardRepository().seedNursingLitter(pupCount: 3);
    final repo = MemoryLitterBoardRepository(
      seed: [
        LitterBoard(
          id: seeded.id,
          code: seeded.code,
          state: 'weaning_due',
          version: seeded.version,
          bornAt: seeded.bornAt,
          initialAliveCount: seeded.initialAliveCount,
          currentManagedCount: seeded.currentManagedCount,
          enclosureId: seeded.enclosureId,
          pups: seeded.pups,
        ),
      ],
    );
    final controller = LitterBoardController(repository: repo);
    await controller.openLitter(seeded.id);
    expect(controller.detailState.data?.state, 'weaning_due');

    expect(await controller.runNextAction(), isTrue);
    expect(controller.detailState.data?.state, 'sexing_due');

    final sexing = controller.detailState.data!;
    expect(
      await controller.runNextAction(
        separations: _separationsFor(
          sexing,
          maleEnclosureId: 'm',
          femaleEnclosureId: 'f',
        ),
      ),
      isTrue,
    );
    expect(controller.detailState.data?.state, 'individualizing');

    final individualizing = controller.detailState.data!;
    expect(
      await controller.runNextAction(profiles: _profilesFor(individualizing)),
      isTrue,
    );
    expect(controller.detailState.data?.state, 'closed');
  });

  testWidgets('LitterBoardListPage opens detail and weans', (tester) async {
    final seeded = MemoryLitterBoardRepository().seedNursingLitter(
      pupCount: 2,
      code: 'L-TEST',
    );
    final repo = MemoryLitterBoardRepository(
      seed: [
        LitterBoard(
          id: seeded.id,
          code: seeded.code,
          state: 'weaning_due',
          version: seeded.version,
          bornAt: seeded.bornAt,
          initialAliveCount: seeded.initialAliveCount,
          currentManagedCount: seeded.currentManagedCount,
          enclosureId: seeded.enclosureId,
          pups: seeded.pups,
        ),
      ],
    );
    final controller = LitterBoardController(repository: repo);

    await tester.pumpWidget(
      MaterialApp(
        home: LitterBoardListPage(
          controller: controller,
          enclosures: const [
            I2Enclosure(
              id: 'enc-1',
              code: 'A-1',
              rackCode: 'A',
              levelCode: '1',
              state: 'vacant',
              cleanlinessState: 'clean',
              capacity: 2,
              equipment: <String>[],
              lastCleanedAt: null,
              currentHamsterIds: <String>[],
              version: 1,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('L-TEST'), findsOneWidget);
    await tester.tap(find.byKey(Key('litter-card-${seeded.id}')));
    await tester.pumpAndSettle();

    expect(find.text('窝次详情'), findsOneWidget);
    expect(find.byKey(Key('litter-next-${seeded.id}')), findsOneWidget);

    await tester.tap(find.byKey(Key('litter-next-${seeded.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('litter-confirm-wean')));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('litter-next-${seeded.id}')), findsOneWidget);
    expect(controller.detailState.data?.state, 'sexing_due');
    expect(find.text('分性分笼'), findsWidgets);
  });
}
