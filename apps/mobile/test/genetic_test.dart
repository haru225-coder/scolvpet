import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/genetic/genetic.dart';
import 'package:scolvpet_mobile/features/i2/i2_models.dart';
import 'support/memory_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('simulateBreeding Aa x Aa yields 1:2:1', () {
    final result = simulateBreeding({'A': 'A/a'}, {'A': 'A/a'});
    expect(result.outcomes.length, 3);
    final by = {
      for (final o in result.outcomes) o.genotype['A']!: o.probability,
    };
    expect(by['A/A'], closeTo(0.25, 1e-9));
    expect(by['A/a'], closeTo(0.5, 1e-9));
    expect(by['a/a'], closeTo(0.25, 1e-9));
  });

  test('MemoryGeneticRepository profile and mendel simulate', () async {
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
    final sim = await repo.simulate(sire: {'A': 'A/A'}, dam: {'A': 'a/a'});
    expect(sim.outcomes.length, 1);
    expect(sim.outcomes.single.genotype['A'], 'A/a');
    expect(sim.outcomes.single.probability, 1.0);
  });

  test('MemoryGeneticRepository phenotype table simulate', () async {
    final repo = MemoryGeneticRepository();
    final catalog = await repo.listPhenotypeCatalog();
    expect(catalog.series, isNotEmpty);
    final poly = catalog.series.firstWhere((s) => s.code == 'poly');
    expect(poly.phenotypes, contains('蜜波利'));

    final sim = await repo.simulatePhenotype(
      series: 'poly',
      sirePhenotype: '蜜波利',
      damPhenotype: '火波利',
    );
    expect(sim.isPhenotypeTable, isTrue);
    expect(sim.outcomes.length, 8);
    final by = {for (final o in sim.outcomes) o.phenotypeLabel: o.probability};
    expect(by['蜜波利'], closeTo(0.1875, 1e-9));
    expect(by['黑波利'], closeTo(0.0625, 1e-9));

    final targets = await repo.findTargetCrosses(
      series: 'poly',
      targetPhenotype: '蜜波利',
    );
    expect(targets, isNotEmpty);
    expect(targets.first.targetProbability, greaterThanOrEqualTo(0.5));
  });

  test('GeneticController phenotype path', () async {
    final table = await loadBundledPhenotypeTable();
    final controller = GeneticController(
      repository: MemoryGeneticRepository(table: table),
    );
    await controller.refreshCatalog();
    expect(controller.catalogState.hasValue, isTrue);

    final ok = await controller.simulatePhenotype(
      series: 'poly',
      sirePhenotype: '蜜波利',
      damPhenotype: '蜜波利',
    );
    expect(ok, isTrue);
    expect(controller.simulateState.hasValue, isTrue);
    expect(controller.simulateState.data!.outcomes.first.probability, 0.75);

    final found = await controller.findTargetCrosses(
      series: 'poly',
      targetPhenotype: '蜜波利',
    );
    expect(found, isTrue);
    expect(controller.targetState.hasValue, isTrue);
  });

  test('buildSimulationWhyExplanation formats authority result only', () async {
    final repo = MemoryGeneticRepository();
    final sim = await repo.simulatePhenotype(
      series: 'poly',
      sirePhenotype: '蜜波利',
      damPhenotype: '火波利',
    );
    final why = buildSimulationWhyExplanation(sim, topN: 3);
    expect(why.sireSummary, contains('蜜波利'));
    expect(why.damSummary, contains('火波利'));
    expect(why.therefore, contains('蜜波利'));
    expect(why.therefore, contains('火波利'));
    expect(why.highlights, isNotEmpty);
    expect(why.basisNote, contains('权威表型表'));
  });

  test('summarizeGenotypeCarries reports heterozygous carrier', () {
    final line = summarizeGenotypeCarries({'A': 'A/a'});
    expect(line, contains('携带'));
    expect(line, contains('A/a'));
  });

  test('phenotype count validation', () {
    expect(
      const PhenotypeCountValidation(
        livePups: 8,
        counts: {'蜜波利': 6, '黑蜜波利': 2},
      ).isValid,
      isTrue,
    );
    expect(
      const PhenotypeCountValidation(livePups: 8, counts: {'蜜波利': 5}).isValid,
      isFalse,
    );
    expect(
      const PhenotypeCountValidation(livePups: 8, counts: {}).isValid,
      isTrue,
    );
    expect(
      const PhenotypeCountValidation(livePups: 0, counts: {'蜜波利': 1}).isValid,
      isFalse,
    );
  });

  test('expected offspring and plan notes', () {
    expect(expectedOffspringCount(0.25, 8), 2.0);
    expect(formatExpectedCount(0.1875, 8), '1.5');
    expect(probabilityAtLeastOne(0.25, 8), closeTo(0.8998870849609375, 1e-12));
    expect(probabilityAtLeastOne(0, 8), 0);
    expect(probabilityAtLeastOne(1, 8), 1);
    expect(probabilityAtLeastOne(0.25, 0), 0);
    final result = GeneticSimulationResult(
      sire: const {'phenotype': '蜜波利'},
      dam: const {'phenotype': '蜜波利'},
      outcomes: const [
        GeneticOutcome(
          genotypeKey: 'phenotype=蜜波利',
          genotype: {'phenotype': '蜜波利', 'fraction': '3/4'},
          phenotypeLabel: '蜜波利',
          phenotype: {'label': '蜜波利'},
          probability: 0.75,
          countWeight: 3,
        ),
        GeneticOutcome(
          genotypeKey: 'phenotype=黑蜜波利',
          genotype: {'phenotype': '黑蜜波利', 'fraction': '1/4'},
          phenotypeLabel: '黑蜜波利',
          phenotype: {'label': '黑蜜波利'},
          probability: 0.25,
          countWeight: 1,
        ),
      ],
      notes: 'core',
      mode: 'phenotype_table',
      series: 'poly',
      seriesName: '波利系列',
      sirePhenotype: '蜜波利',
      damPhenotype: '蜜波利',
      tableVersion: 'v1',
    );
    final notes = buildSimulationPlanNotes(result: result, litterSize: 8);
    expect(notes, contains('蜜波利 × 蜜波利'));
    expect(notes, contains('期望 6 只'));
    expect(notes, contains('3/4'));
    expect(phenotypeProbability(result.outcomes, '蜜波利'), 0.75);
    expect(phenotypeProbability(result.outcomes, '不存在'), 0);
    expect(mostLikelyOutcome(result.outcomes)?.phenotypeLabel, '蜜波利');
    expect(formatProbabilityPercent(0.8998870849609375), '90.0%');
  });

  test(
    'simulation result history fields stay optional and consumer friendly',
    () {
      final tableOnly = GeneticSimulationResult.fromJson({
        'mode': 'phenotype_table',
        'outcomes': const [],
      });
      expect(tableOnly.usesHistoricalRecords, isFalse);
      expect(tableOnly.consumerPredictionBasisLabel, '基于权威表计算');

      final calibrated = GeneticSimulationResult.fromJson({
        'mode': 'phenotype_table',
        'outcomes': const [],
        'prediction_basis': 'authority_table_plus_history',
        'history_litter_count': 12,
        'history_pup_count': 88,
      });
      expect(calibrated.usesHistoricalRecords, isTrue);
      expect(calibrated.historyLitterCount, 12);
      expect(calibrated.historyPupCount, 88);
      expect(calibrated.consumerPredictionBasisLabel, '已结合历史繁殖记录');
      expect(
        buildSimulationPlanNotes(result: calibrated),
        contains('[遗传推算（已结合历史）]'),
      );
    },
  );

  test('encode core variety code', () {
    expect(encodeCoreVarietyCode('poly', '蜜波利'), 'poly|蜜波利');
    final h = I2Hamster.fromJson({
      'id': '1',
      'internal_code': 'H1',
      'sex': 'male',
      'variety_code': 'poly|蜜波利',
      'lifecycle_status': 'active',
      'breeding_status': 'candidate',
      'version': 1,
    });
    expect(h.coreSeriesCode, 'poly');
    expect(h.corePhenotypeLabel, '蜜波利');
  });

  test('rank mates and prefill for pair', () {
    I2Hamster h({required String id, required String sex, String? variety}) =>
        I2Hamster.fromJson({
          'id': id,
          'internal_code': id,
          'name': id,
          'sex': sex,
          'variety_code': variety,
          'lifecycle_status': 'active',
          'breeding_status': 'candidate',
          'version': 1,
        });

    final sire = h(id: 'M1', sex: 'male', variety: 'poly|蜜波利');
    final dam = h(id: 'F1', sex: 'female', variety: 'poly|火波利');
    final otherMale = h(id: 'M2', sex: 'male', variety: 'poly|黑波利');
    final noPheno = h(id: 'F2', sex: 'female');

    final ranked = rankMateCandidates(
      self: sire,
      all: [sire, dam, otherMale, noPheno],
    );
    expect(ranked.first.id, 'F1'); // female + same series + phenotype
    expect(ranked.map((e) => e.id), isNot(contains('M1')));

    final prefill = prefillForPair(sire, dam);
    expect(prefill.sireHamsterId, 'M1');
    expect(prefill.damHamsterId, 'F1');
    expect(prefill.sirePhenotype, '蜜波利');
    expect(prefill.damPhenotype, '火波利');
    expect(prefill.autoSimulate, isTrue);

    final flipped = prefillForPair(dam, sire);
    expect(flipped.sireHamsterId, 'M1');
    expect(flipped.damHamsterId, 'F1');
  });

  test('compare actual to table locally', () async {
    final table = await loadBundledPhenotypeTable();
    final result = compareActualLocally(
      table: table,
      series: 'poly',
      sirePhenotype: '蜜波利',
      damPhenotype: '蜜波利',
      actualCounts: {'蜜波利': 6, '黑蜜波利': 2},
    );
    expect(result.totalActual, 8);
    final honey = result.rows.firstWhere((r) => r.phenotype == '蜜波利');
    expect(honey.expectedCount, closeTo(6, 1e-9));
    expect(honey.residual.abs(), closeTo(0, 1e-9));

    final repo = MemoryGeneticRepository(table: table);
    final viaRepo = await repo.compareActual(
      series: 'poly',
      sirePhenotype: '蜜波利',
      damPhenotype: '蜜波利',
      actualCounts: {'蜜波利': 6, '黑蜜波利': 2},
      save: true,
    );
    expect(viaRepo.totalActual, 8);
    final summary = await repo.listFeedbackSummary();
    expect(summary, isNotEmpty);
    expect(summary.first.sampleCount, greaterThanOrEqualTo(1));

    final notes = buildSimulationPlanNotes(
      result: GeneticSimulationResult(
        sire: const {},
        dam: const {},
        outcomes: const [],
        notes: '',
        mode: 'phenotype_table',
        series: 'poly',
        sirePhenotype: '蜜波利',
        damPhenotype: '火波利',
      ),
      litterSize: 6,
    );
    final snap = SimulationSnapshot.tryParseNotes(notes);
    expect(snap, isNotNull);
    expect(snap!.series, 'poly');
    expect(snap.sire, '蜜波利');
    expect(snap.dam, '火波利');
  });
}
