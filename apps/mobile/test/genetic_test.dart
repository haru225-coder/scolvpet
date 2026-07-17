import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/genetic/genetic.dart';

void main() {
  test('simulateBreeding Aa x Aa yields 1:2:1', () {
    final result = simulateBreeding(
      {'A': 'A/a'},
      {'A': 'A/a'},
    );
    expect(result.outcomes.length, 3);
    final by = {
      for (final o in result.outcomes) o.genotype['A']!: o.probability,
    };
    expect(by['A/A'], closeTo(0.25, 1e-9));
    expect(by['A/a'], closeTo(0.5, 1e-9));
    expect(by['a/a'], closeTo(0.25, 1e-9));
  });

  test('MemoryGeneticRepository profile and simulate', () async {
    final repo = MemoryGeneticRepository();
    final profile = await repo.createProfile(
      const GeneticProfileDraft(
        name: '雪球',
        genotype: {'A': 'A/a', 'B': 'B/B', 'C': 'C/c'},
        confidence: 'inferred',
      ),
    );
    expect(profile.genotype['A'], 'A/a');
    expect(profile.phenotypeSummary, isNotEmpty);
    final sim = await repo.simulate(
      sire: {'A': 'A/A'},
      dam: {'A': 'a/a'},
    );
    expect(sim.outcomes.length, 1);
    expect(sim.outcomes.single.genotype['A'], 'A/a');
    expect(sim.outcomes.single.probability, 1.0);
  });

  testWidgets('GeneticHubPage runs simulation', (tester) async {
    final controller = GeneticController(
      repository: MemoryGeneticRepository(),
    );
    await tester.pumpWidget(
      MaterialApp(home: GeneticHubPage(controller: controller)),
    );
    await tester.pumpAndSettle();
    expect(find.text('遗传表型与模拟'), findsOneWidget);
    await tester.tap(find.byKey(const Key('genetic-run-sim')));
    await tester.pumpAndSettle();
    expect(controller.simulateState.hasValue, isTrue);
    final outcomes = controller.simulateState.data!.outcomes;
    expect(outcomes.length, greaterThan(1));
    expect(outcomes.first.percentLabel, contains('%'));
    // SnackBar confirms UI path ran.
    expect(find.textContaining('模拟完成'), findsOneWidget);
  });
}
