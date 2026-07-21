// Test doubles only — not part of production lib.
// Moved out of lib/ per docs/engineering/复杂度收敛约定.md

import 'package:scolvpet_mobile/features/genetic/genetic_models.dart';
import 'package:scolvpet_mobile/features/genetic/genetic_repository.dart';

class MemoryGeneticRepository implements GeneticRepository {
  MemoryGeneticRepository({PhenotypeTableIndex? table}) : _table = table;

  final List<GeneticProfile> _profiles = [];
  final List<
    ({
      String series,
      String sire,
      String dam,
      int total,
      double mae,
      double tv,
      DateTime at,
    })
  >
  _feedback = [];
  int _seq = 0;
  PhenotypeTableIndex? _table;

  Future<PhenotypeTableIndex> _ensureTable() async {
    if (_table != null) return _table!;
    _table = await loadBundledPhenotypeTable();
    return _table!;
  }

  @override
  Future<List<GeneticLocus>> listLoci() async => defaultGeneticLoci;

  @override
  Future<PhenotypeCatalog> listPhenotypeCatalog() async {
    final table = await _ensureTable();
    return table.catalog;
  }

  @override
  Future<List<GeneticProfile>> listProfiles() async =>
      List<GeneticProfile>.from(_profiles);

  @override
  Future<GeneticProfile> createProfile(GeneticProfileDraft draft) async {
    final name = draft.name.trim();
    if (name.isEmpty) {
      throw const GeneticRepositoryException('档案名称必填');
    }
    final genotype = <String, String>{};
    for (final entry in draft.genotype.entries) {
      final locus = defaultGeneticLoci.cast<GeneticLocus?>().firstWhere(
        (l) => l?.code == entry.key,
        orElse: () => null,
      );
      if (locus == null) continue;
      final norm = normalizeAllelePair(locus, entry.value);
      if (norm == null) {
        throw GeneticRepositoryException('位点 ${entry.key} 基因型无效');
      }
      genotype[entry.key] = norm;
    }
    final pheno = phenotypeMapFor(genotype);
    // Prefer explicit series phenotype if provided via notes convention later.
    final item = GeneticProfile(
      id: 'gprof-${_seq++}',
      hamsterId: draft.hamsterId,
      name: name,
      phenotype: {...pheno, 'summary': phenotypeLabelFor(genotype)},
      genotype: genotype,
      confidence: draft.confidence,
      notes: draft.notes,
      version: 1,
      updatedAt: DateTime.now().toUtc(),
    );
    _profiles.insert(0, item);
    return item;
  }

  @override
  Future<GeneticSimulationResult> simulate({
    required Map<String, String> sire,
    required Map<String, String> dam,
  }) async {
    try {
      return simulateBreeding(sire, dam);
    } on FormatException catch (error) {
      throw GeneticRepositoryException(error.message);
    }
  }

  @override
  Future<GeneticSimulationResult> simulatePhenotype({
    required String series,
    required String sirePhenotype,
    required String damPhenotype,
    String? sireHamsterId,
    String? damHamsterId,
  }) async {
    try {
      final table = await _ensureTable();
      return table.simulate(
        series: series,
        sirePhenotype: sirePhenotype,
        damPhenotype: damPhenotype,
      );
    } on FormatException catch (error) {
      throw GeneticRepositoryException(error.message);
    }
  }

  @override
  Future<List<TargetCrossRecommendation>> findTargetCrosses({
    required String series,
    required String targetPhenotype,
  }) async {
    final table = await _ensureTable();
    return table.findForTarget(
      series: series,
      targetPhenotype: targetPhenotype,
    );
  }

  @override
  Future<PhenotypeCompareResult> compareActual({
    required String series,
    required String sirePhenotype,
    required String damPhenotype,
    required Map<String, int> actualCounts,
    bool save = false,
    String? breedingPlanId,
    String? litterId,
  }) async {
    try {
      final table = await _ensureTable();
      final result = compareActualLocally(
        table: table,
        series: series,
        sirePhenotype: sirePhenotype,
        damPhenotype: damPhenotype,
        actualCounts: actualCounts,
      );
      if (save) {
        _feedback.add((
          series: result.series,
          sire: result.sirePhenotype,
          dam: result.damPhenotype,
          total: result.totalActual,
          mae: result.meanAbsError,
          tv: result.totalVariation,
          at: DateTime.now().toUtc(),
        ));
      }
      return result;
    } on FormatException catch (error) {
      throw GeneticRepositoryException(error.message);
    }
  }

  @override
  Future<List<PhenotypeFeedbackPairSummary>> listFeedbackSummary() async {
    final buckets =
        <String, List<({double mae, double tv, int total, DateTime at})>>{};
    for (final f in _feedback) {
      final key = '${f.series}\x00${f.sire}\x00${f.dam}';
      buckets.putIfAbsent(key, () => []).add((
        mae: f.mae,
        tv: f.tv,
        total: f.total,
        at: f.at,
      ));
    }
    final out = <PhenotypeFeedbackPairSummary>[];
    for (final entry in buckets.entries) {
      final parts = entry.key.split('\x00');
      final list = entry.value;
      final n = list.length;
      out.add(
        PhenotypeFeedbackPairSummary(
          series: parts[0],
          sirePhenotype: parts[1],
          damPhenotype: parts[2],
          sampleCount: n,
          avgMeanAbsError: list.map((e) => e.mae).reduce((a, b) => a + b) / n,
          avgTotalVariation: list.map((e) => e.tv).reduce((a, b) => a + b) / n,
          avgLitterSize:
              list.map((e) => e.total.toDouble()).reduce((a, b) => a + b) / n,
          lastAt: list.map((e) => e.at).reduce((a, b) => a.isAfter(b) ? a : b),
        ),
      );
    }
    out.sort((a, b) => b.avgMeanAbsError.compareTo(a.avgMeanAbsError));
    return out;
  }
}
