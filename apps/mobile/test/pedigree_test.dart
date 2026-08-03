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

  test('pedigreeRelationshipLabel covers classic three generations', () {
    expect(pedigreeRelationshipLabel(const []), '这只');
    expect(pedigreeRelationshipLabel(const ['sire']), '爸爸');
    expect(pedigreeRelationshipLabel(const ['dam']), '妈妈');
    expect(pedigreeRelationshipLabel(const ['sire', 'sire']), '爷爷');
    expect(pedigreeRelationshipLabel(const ['sire', 'dam']), '奶奶');
    expect(pedigreeRelationshipLabel(const ['dam', 'sire']), '外公');
    expect(pedigreeRelationshipLabel(const ['dam', 'dam']), '外婆');
  });

  test('listDirectDescendants returns children of root only', () {
    final repo = MemoryPedigreeRepository();
    // Seed root with ancestors; add one child edge under root.
    final graph = repo.seedThreeGenerationTree(rootId: 'root');
    final child = PedigreeNode(
      id: 'pup-1',
      internalCode: 'P1',
      name: '宝宝',
      sex: 'female',
    );
    final withPup = PedigreeGraph(
      rootHamsterId: graph.rootHamsterId,
      nodes: [...graph.nodes, child],
      edges: [
        ...graph.edges,
        const PedigreeEdge(
          childId: 'pup-1',
          parentId: 'root',
          role: 'dam',
        ),
      ],
    );
    final pups = listDirectDescendants(withPup);
    expect(pups.map((n) => n.id), ['pup-1']);
    expect(listDirectDescendants(graph), isEmpty);
  });

  test('pedigreeFillTargetForSlot maps grandparents', () {
    final slot = PedigreeTreeSlot(
      generation: 2,
      rolePath: const ['sire', 'dam'],
      node: null,
    );
    final target = pedigreeFillTargetForSlot(slot)!;
    expect(target.label, '奶奶');
    expect(target.role, 'dam');
    expect(target.pathToChild, ['sire']);
    expect(target.preferredSex, 'female');
  });

  test('PedigreeController.fill empty parent slot', () async {
    final repo = MemoryPedigreeRepository();
    // Root only — no parents.
    final root = const PedigreeNode(
      id: 'h-root',
      internalCode: 'ROOT',
      name: '雪团',
      sex: 'female',
    );
    repo.put(
      PedigreeGraph(rootHamsterId: 'h-root', nodes: [root], edges: const []),
    );
    final controller = PedigreeController(repository: repo);
    await controller.load('h-root', generationsDepth: 2);

    final sireSlot = controller.generations[1].firstWhere(
      (s) => s.rolePath.last == 'sire',
    );
    expect(sireSlot.isUnknown, isTrue);

    final ok = await controller.fillSlot(
      slot: sireSlot,
      parentId: 'dad-1',
      createStub: ({
        required String name,
        required String sex,
        required String relationLabel,
      }) async => PedigreeNode(
        id: 'stub-$relationLabel',
        internalCode: 'STUB',
        name: name,
        sex: sex,
      ),
    );
    expect(ok, isTrue);
    expect(repo.created, hasLength(1));
    expect(repo.created.single.role, 'sire');
    expect(repo.created.single.parentId, 'dad-1');
    expect(controller.generations[1].firstWhere((s) => s.rolePath.last == 'sire').node?.id, 'dad-1');
  });

  test('PedigreeController replace requires reason and end removes edge', () async {
    final repo = MemoryPedigreeRepository();
    final root = const PedigreeNode(
      id: 'h-root',
      internalCode: 'ROOT',
      name: '雪团',
      sex: 'female',
    );
    final dad = const PedigreeNode(
      id: 'dad-1',
      internalCode: 'D1',
      name: '旧父',
      sex: 'male',
    );
    repo.put(
      PedigreeGraph(
        rootHamsterId: 'h-root',
        nodes: [root, dad],
        edges: const [
          PedigreeEdge(
            childId: 'h-root',
            parentId: 'dad-1',
            role: 'sire',
          ),
        ],
      ),
    );
    final controller = PedigreeController(repository: repo);
    await controller.load('h-root', generationsDepth: 2);
    final sireSlot = controller.generations[1].firstWhere(
      (s) => s.rolePath.last == 'sire',
    );

    final noReason = await controller.fillSlot(
      slot: sireSlot,
      parentId: 'dad-2',
      createStub: ({
        required String name,
        required String sex,
        required String relationLabel,
      }) async => PedigreeNode(
        id: 'x',
        internalCode: 'x',
        name: name,
        sex: sex,
      ),
    );
    expect(noReason, isFalse);

    final replaced = await controller.fillSlot(
      slot: sireSlot,
      parentId: 'dad-2',
      correctionReason: '选错父本',
      createStub: ({
        required String name,
        required String sex,
        required String relationLabel,
      }) async => PedigreeNode(
        id: 'x',
        internalCode: 'x',
        name: name,
        sex: sex,
      ),
    );
    expect(replaced, isTrue);
    expect(repo.created.last.reason, '选错父本');
    expect(
      controller.generations[1]
          .firstWhere((s) => s.rolePath.last == 'sire')
          .node
          ?.id,
      'dad-2',
    );

    final ended = await controller.endSlot(
      slot: controller.generations[1].firstWhere(
        (s) => s.rolePath.last == 'sire',
      ),
      correctionReason: '核实无父本',
    );
    expect(ended, isTrue);
    expect(repo.ended, hasLength(1));
    expect(
      controller.generations[1]
          .firstWhere((s) => s.rolePath.last == 'sire')
          .isUnknown,
      isTrue,
    );
  });

  test('PedigreeController auto-creates intermediate when filling grandpa', () async {
    final repo = MemoryPedigreeRepository();
    final root = const PedigreeNode(
      id: 'h-root',
      internalCode: 'ROOT',
      name: '雪团',
      sex: 'female',
    );
    repo.put(
      PedigreeGraph(rootHamsterId: 'h-root', nodes: [root], edges: const []),
    );
    final controller = PedigreeController(repository: repo);
    await controller.load('h-root', generationsDepth: 2);
    final grandpaSlot = controller.generations[2].firstWhere(
      (s) => s.rolePath.join('/') == 'sire/sire',
    );

    final stubs = <String>[];
    final ok = await controller.fillSlot(
      slot: grandpaSlot,
      parentId: 'grandpa-1',
      createStub: ({
        required String name,
        required String sex,
        required String relationLabel,
      }) async {
        stubs.add(relationLabel);
        return PedigreeNode(
          id: 'stub-$relationLabel',
          internalCode: 'STUB',
          name: name,
          sex: sex,
        );
      },
    );
    expect(ok, isTrue);
    expect(stubs, contains('爸爸')); // intermediate 人话标签
    // First edge: root ← stub 爸爸; second: stub ← grandpa
    expect(repo.created, hasLength(2));
    expect(repo.created.first.childId, 'h-root');
    expect(repo.created.last.parentId, 'grandpa-1');
  });

  test('layoutClassicPedigreeChart aligns parents above child (binary)', () {
    final repo = MemoryPedigreeRepository();
    final graph = repo.seedThreeGenerationTree(rootId: 'root');
    final rows = buildAncestorGenerations(graph, generations: 2);
    final layout = layoutClassicPedigreeChart(
      rows,
      nodeWidth: 100,
      nodeHeight: 60,
      horizontalGap: 20,
      verticalGap: 40,
      paddingX: 10,
      paddingY: 10,
    );

    expect(layout.nodes, isNotEmpty);
    expect(layout.edges, isNotEmpty);
    expect(layout.maxGeneration, 2);

    final root = layout.nodeAt(generation: 0, index: 0)!;
    final sire = layout.nodeAt(generation: 1, index: 0)!;
    final dam = layout.nodeAt(generation: 1, index: 1)!;
    // Parents sit above root.
    expect(sire.centerY, lessThan(root.centerY));
    expect(dam.centerY, lessThan(root.centerY));
    // Root centered under parent pair.
    expect(root.centerX, closeTo((sire.centerX + dam.centerX) / 2, 0.5));

    final grandpa = layout.nodeAt(generation: 2, index: 0)!;
    final grandma = layout.nodeAt(generation: 2, index: 1)!;
    expect(sire.centerX, closeTo((grandpa.centerX + grandma.centerX) / 2, 0.5));
  });

  test('PedigreeController loads tree for root', () async {
    final repo = MemoryPedigreeRepository()..seedThreeGenerationTree();
    final controller = PedigreeController(repository: repo);
    await controller.load('h-root', generationsDepth: 3);

    expect(controller.graphState.data?.rootHamsterId, 'h-root');
    expect(controller.generations.length, 4);
    expect(maxFilledGeneration(controller.generations), 2);
  });

  testWidgets('PedigreePage shows an ancestor branch tree', (tester) async {
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
    await tester.pump();
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    await tester.pumpAndSettle();

    expect(find.textContaining('这只从哪来 · 雪团'), findsOneWidget);
    expect(find.byKey(const Key('pedigree-tree')), findsOneWidget);
    expect(find.byKey(const Key('pedigree-chart-viewer')), findsOneWidget);
    expect(find.text('这只从哪来'), findsOneWidget);
    expect(find.text('这只'), findsOneWidget);
    expect(find.text('爸爸'), findsWidgets);
    expect(find.text('妈妈'), findsWidgets);
    expect(find.text('爷爷'), findsWidgets);
    expect(find.text('奶奶'), findsWidgets);
    expect(find.byKey(const Key('pedigree-slot-0-')), findsOneWidget);
    expect(find.byKey(const Key('pedigree-slot-1-sire')), findsOneWidget);
    expect(find.byKey(const Key('pedigree-slot-2-sire-dam')), findsOneWidget);
  });
}
