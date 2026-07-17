import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/i2/i2_models.dart';
import 'package:scolvpet_mobile/features/litter/litter.dart';

void main() {
  test('nextLitterAction maps nursing → wean → sex → individualize', () {
    expect(nextLitterAction('nursing'), LitterBoardAction.wean);
    expect(nextLitterAction('newborn'), LitterBoardAction.wean);
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
    expect(seeded.state, 'nursing');
    expect(seeded.pups, hasLength(4));

    var board = await repo.wean(litterId: seeded.id, version: seeded.version);
    expect(board.state, 'sexing_due');
    expect(board.pups.every((p) => !p.isAlive || p.weaned), isTrue);

    board = await repo.sexAndSeparate(
      litterId: board.id,
      version: board.version,
      maleEnclosureId: 'enc-m',
      femaleEnclosureId: 'enc-f',
    );
    expect(board.state, 'individualizing');
    expect(board.alivePups.every((p) => p.sexAssigned), isTrue);

    board = await repo.individualize(
      litterId: board.id,
      version: board.version,
    );
    expect(board.state, 'closed');
    expect(board.alivePups.every((p) => p.individualized), isTrue);
    expect(board.currentManagedCount, 0);
  });

  test('LitterBoardController advances next actions', () async {
    final repo = MemoryLitterBoardRepository();
    final seeded = repo.seedNursingLitter(pupCount: 3);
    final controller = LitterBoardController(repository: repo);
    await controller.openLitter(seeded.id);
    expect(controller.detailState.data?.state, 'nursing');

    expect(
      await controller.runNextAction(
        maleEnclosureId: 'm',
        femaleEnclosureId: 'f',
      ),
      isTrue,
    );
    expect(controller.detailState.data?.state, 'sexing_due');

    expect(
      await controller.runNextAction(
        maleEnclosureId: 'm',
        femaleEnclosureId: 'f',
      ),
      isTrue,
    );
    expect(controller.detailState.data?.state, 'individualizing');

    expect(
      await controller.runNextAction(
        maleEnclosureId: 'm',
        femaleEnclosureId: 'f',
      ),
      isTrue,
    );
    expect(controller.detailState.data?.state, 'closed');
  });

  testWidgets('LitterBoardListPage opens detail and weans', (tester) async {
    final repo = MemoryLitterBoardRepository();
    final seeded = repo.seedNursingLitter(pupCount: 2, code: 'L-TEST');
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
    expect(find.byKey(Key('litter-next-${seeded.id}')), findsOneWidget);
    expect(controller.detailState.data?.state, 'sexing_due');
    expect(find.text('分性分笼'), findsWidgets);
  });
}
