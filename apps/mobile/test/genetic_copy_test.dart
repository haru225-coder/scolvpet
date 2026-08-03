import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/genetic/genetic.dart';

import 'support/memory_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('formatGeneticsPercent is integer percent only', () {
    expect(formatGeneticsPercent(0.25), '25%');
    expect(formatGeneticsPercent(0.1875), '19%');
    expect(formatGeneticsPercent(1), '100%');
  });

  test('formatAboutNInM does not invent probability', () {
    expect(formatAboutNInM(0.25), '约 4 只里 1 只');
    expect(formatAboutNInM(0.5), '约 2 只里 1 只');
  });

  test('buildGeneticsConclusion uses only template family', () async {
    final repo = MemoryGeneticRepository();
    final sim = await repo.simulatePhenotype(
      series: 'poly',
      sirePhenotype: '蜜波利',
      damPhenotype: '蜜波利',
    );
    final c = buildGeneticsConclusion(sim);
    expect(
      c.line.contains('这一配') || c.line.contains('能配') || c.line.contains('不要配'),
      isTrue,
    );
    expect(c.line.toLowerCase().contains('genotype'), isFalse);
    expect(c.line.toLowerCase().contains('phenotype'), isFalse);
  });

  test('humanizeGeneticsTerm maps risk concepts', () {
    expect(
      humanizeGeneticsTerm('homozygous lethal'),
      contains('活不下来'),
    );
    expect(humanizeGeneticsTerm('carrier'), contains('会传给宝宝'));
  });

  test('geneticsTermDisplayTable wires product term sheet', () {
    expect(geneticsTermDisplayTable['phenotype'], '看得见的样子');
    expect(geneticsTermDisplayTable['carrier'], contains('会传给宝宝'));
    expect(humanizeGeneticsTerm('phenotype'), '看得见的样子');
    expect(humanizeGeneticsTerm('punnett square'), '配对表');
  });

  test('poli phenotype labels stay locked', () {
    expect(isLockedPoliPhenotypeLabel('蜜波利'), isTrue);
    expect(displayPhenotypeLabel('蜜波利'), '蜜波利');
    expect(displayPhenotypeLabel('火波利'), '火波利');
    expect(displayPhenotypeLabel(null), GeneticsUiCopy.notRegistered);
  });
}
