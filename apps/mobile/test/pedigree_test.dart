import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/pedigree/pedigree.dart';
import 'support/memory_repositories.dart';

void main() {
  test('buildAncestorGenerations expands at least three generations', () {
    final repo = MemoryPedigreeRepository();
    final graph = repo.seedThreeGenerationTree(rootId: 'root');
    final rows = buildAncestorGenerations(graph, generations: 3);

    expect(rows, hasLength(4)); // gen0 + 3 ancestor levels
    expect(rows[0].single.node?.id, 'root');
    expect(rows[1].where((s) => s.node != null), hasLength(2));
    expect(rows[2].where((s) => s.node != null), hasLength(4));
    expect(maxFilledGeneration(rows), 2);
    expect(countKnownAncestors(rows), 6);

    final sire = rows[1].firstWhere((s) => s.rolePath.last == 'sire');
    expect(sire.node?.name, '父本');
    final paternalGranddam = rows[2].firstWhere(
      (s) => s.rolePath.join('/') == 'sire/dam',
    );
    expect(paternalGranddam.node?.name, '曾祖母');
  });

  test('PedigreeController loads tree for root', () async {
    final repo = MemoryPedigreeRepository()..seedThreeGenerationTree();
    final controller = PedigreeController(repository: repo);
    await controller.load('h-root', generationsDepth: 3);

    expect(controller.graphState.data?.rootHamsterId, 'h-root');
    expect(controller.generations.length, 4);
    expect(maxFilledGeneration(controller.generations), 2);
  });

  testWidgets('PedigreePage shows three generation headers and cards', (
    tester,
  ) async {
    final repo = MemoryPedigreeRepository()..seedThreeGenerationTree();
    final controller = PedigreeController(repository: repo);

    await tester.binding.setSurfaceSize(const Size(400, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: PedigreePage(
          controller: controller,
          hamsterId: 'h-root',
          hamsterLabel: '雪团',
          generations: 3,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('谱系 · 雪团'), findsOneWidget);
    expect(find.text('本代'), findsWidgets);
    expect(find.text('父母（第 1 代）'), findsOneWidget);
    expect(find.text('祖父母（第 2 代）'), findsOneWidget);
    expect(find.text('曾祖（第 3 代）'), findsOneWidget);
    expect(find.textContaining('父本'), findsOneWidget);
    expect(find.textContaining('母本'), findsOneWidget);
    expect(find.byKey(const Key('pedigree-slot-0-')), findsOneWidget);
    expect(find.byKey(const Key('pedigree-slot-1-sire')), findsOneWidget);
    expect(find.byKey(const Key('pedigree-slot-2-sire-dam')), findsOneWidget);
  });
}
