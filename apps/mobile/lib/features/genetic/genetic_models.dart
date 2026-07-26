import 'dart:math' as math;

class GeneticLocus {
  const GeneticLocus({
    required this.code,
    required this.name,
    required this.dominantAllele,
    required this.recessiveAllele,
    required this.dominantLabel,
    required this.recessiveLabel,
    this.description,
  });

  final String code;
  final String name;
  final String dominantAllele;
  final String recessiveAllele;
  final String dominantLabel;
  final String recessiveLabel;
  final String? description;

  List<String> get pairOptions => [
    '$dominantAllele/$dominantAllele',
    '$dominantAllele/$recessiveAllele',
    '$recessiveAllele/$recessiveAllele',
  ];

  factory GeneticLocus.fromJson(Map<String, dynamic> json) => GeneticLocus(
    code: json['code'] as String? ?? '',
    name: json['name'] as String? ?? '',
    dominantAllele: json['dominant_allele'] as String? ?? '',
    recessiveAllele: json['recessive_allele'] as String? ?? '',
    dominantLabel: json['dominant_label'] as String? ?? '',
    recessiveLabel: json['recessive_label'] as String? ?? '',
    description: json['description'] as String?,
  );
}

/// Built-in educational catalog (mirrors api/internal/geneticcore).
const defaultGeneticLoci = <GeneticLocus>[
  GeneticLocus(
    code: 'A',
    name: '刺鼠色',
    dominantAllele: 'A',
    recessiveAllele: 'a',
    dominantLabel: '刺鼠',
    recessiveLabel: '黑',
    description: 'A 对 a 完全显性（简化）',
  ),
  GeneticLocus(
    code: 'B',
    name: '黑/肉桂',
    dominantAllele: 'B',
    recessiveAllele: 'b',
    dominantLabel: '黑系',
    recessiveLabel: '肉桂',
    description: 'B 对 b 完全显性（简化）',
  ),
  GeneticLocus(
    code: 'C',
    name: '色素',
    dominantAllele: 'C',
    recessiveAllele: 'c',
    dominantLabel: '有色',
    recessiveLabel: '白化',
    description: 'C 对 c 完全显性（简化）',
  ),
];

class GeneticProfile {
  const GeneticProfile({
    required this.id,
    this.hamsterId,
    required this.name,
    required this.phenotype,
    required this.genotype,
    required this.confidence,
    this.notes,
    required this.version,
    this.updatedAt,
  });

  final String id;
  final String? hamsterId;
  final String name;
  final Map<String, dynamic> phenotype;
  final Map<String, String> genotype;
  final String confidence;
  final String? notes;
  final int version;
  final DateTime? updatedAt;

  String get confidenceLabel => switch (confidence) {
    'observed' => '实测',
    'inferred' => '推测',
    _ => '未知',
  };

  String get genotypeSummary {
    if (genotype.isEmpty) return '无基因型';
    final keys = genotype.keys.toList()..sort();
    return keys.map((k) => '$k=${genotype[k]}').join(' · ');
  }

  String get phenotypeSummary {
    final summary = phenotype['summary'];
    if (summary is String && summary.trim().isNotEmpty) return summary;
    if (genotype.isEmpty) return '无表型';
    return phenotypeLabelFor(genotype);
  }

  factory GeneticProfile.fromJson(Map<String, dynamic> json) {
    final pheno = json['phenotype'];
    final geno = json['genotype'];
    return GeneticProfile(
      id: json['id'] as String? ?? '',
      hamsterId: json['hamster_id'] as String?,
      name: json['name'] as String? ?? '',
      phenotype: pheno is Map
          ? Map<String, dynamic>.from(pheno)
          : <String, dynamic>{},
      genotype: geno is Map
          ? geno.map((k, v) => MapEntry(k.toString(), v.toString()))
          : <String, String>{},
      confidence: json['confidence'] as String? ?? 'unknown',
      notes: json['notes'] as String?,
      version: (json['version'] as num?)?.toInt() ?? 1,
      updatedAt: DateTime.tryParse(
        json['updated_at'] as String? ?? '',
      )?.toUtc(),
    );
  }
}

class GeneticProfileDraft {
  const GeneticProfileDraft({
    required this.name,
    required this.genotype,
    this.confidence = 'unknown',
    this.notes,
    this.hamsterId,
  });

  final String name;
  final Map<String, String> genotype;
  final String confidence;
  final String? notes;
  final String? hamsterId;
}

class GeneticOutcome {
  const GeneticOutcome({
    required this.genotypeKey,
    required this.genotype,
    required this.phenotypeLabel,
    required this.phenotype,
    required this.probability,
    required this.countWeight,
  });

  final String genotypeKey;
  final Map<String, String> genotype;
  final String phenotypeLabel;
  final Map<String, String> phenotype;
  final double probability;
  final int countWeight;

  String get percentLabel => '${(probability * 100).toStringAsFixed(1)}%';

  factory GeneticOutcome.fromJson(Map<String, dynamic> json) {
    final geno = json['genotype'];
    final pheno = json['phenotype'];
    return GeneticOutcome(
      genotypeKey: json['genotype_key'] as String? ?? '',
      genotype: geno is Map
          ? geno.map((k, v) => MapEntry(k.toString(), v.toString()))
          : <String, String>{},
      phenotypeLabel: json['phenotype_label'] as String? ?? '',
      phenotype: pheno is Map
          ? pheno.map((k, v) => MapEntry(k.toString(), v.toString()))
          : <String, String>{},
      probability: (json['probability'] as num?)?.toDouble() ?? 0,
      countWeight: (json['count_weight'] as num?)?.toInt() ?? 0,
    );
  }
}

class GeneticSimulationResult {
  const GeneticSimulationResult({
    required this.sire,
    required this.dam,
    required this.outcomes,
    required this.notes,
    this.mode = 'mendel',
    this.series,
    this.seriesName,
    this.sirePhenotype,
    this.damPhenotype,
    this.tableVersion,
    this.predictionBasis,
    this.historyLitterCount,
    this.historyPupCount,
  });

  final Map<String, String> sire;
  final Map<String, String> dam;
  final List<GeneticOutcome> outcomes;
  final String notes;
  final String mode;
  final String? series;
  final String? seriesName;
  final String? sirePhenotype;
  final String? damPhenotype;
  final String? tableVersion;
  final String? predictionBasis;
  final int? historyLitterCount;
  final int? historyPupCount;

  bool get isPhenotypeTable => mode == 'phenotype_table';

  bool get usesHistoricalRecords {
    final basis = predictionBasis?.toLowerCase() ?? '';
    return basis.contains('history') ||
        (historyLitterCount ?? 0) > 0 ||
        (historyPupCount ?? 0) > 0;
  }

  String get consumerPredictionBasisLabel =>
      usesHistoricalRecords ? '已结合历史繁殖记录' : '基于权威表计算';

  factory GeneticSimulationResult.fromJson(Map<String, dynamic> json) {
    final outcomes = json['outcomes'];
    final sire = json['sire'];
    final dam = json['dam'];
    return GeneticSimulationResult(
      sire: sire is Map
          ? sire.map((k, v) => MapEntry(k.toString(), v.toString()))
          : <String, String>{},
      dam: dam is Map
          ? dam.map((k, v) => MapEntry(k.toString(), v.toString()))
          : <String, String>{},
      outcomes: outcomes is List
          ? outcomes
                .whereType<Map>()
                .map(
                  (e) => GeneticOutcome.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [],
      notes: json['notes'] as String? ?? '',
      mode: json['mode'] as String? ?? 'mendel',
      series: json['series'] as String?,
      seriesName: json['series_name'] as String?,
      sirePhenotype: json['sire_phenotype'] as String?,
      damPhenotype: json['dam_phenotype'] as String?,
      tableVersion: json['table_version'] as String?,
      predictionBasis: json['prediction_basis'] as String?,
      historyLitterCount: (json['history_litter_count'] as num?)?.toInt(),
      historyPupCount: (json['history_pup_count'] as num?)?.toInt(),
    );
  }
}

/// One series from the authority phenotype table (poly / chocolate).
class PhenotypeSeriesCatalog {
  const PhenotypeSeriesCatalog({
    required this.code,
    required this.name,
    required this.phenotypes,
  });

  final String code;
  final String name;
  final List<String> phenotypes;

  factory PhenotypeSeriesCatalog.fromJson(Map<String, dynamic> json) {
    final list = json['phenotypes'];
    return PhenotypeSeriesCatalog(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phenotypes: list is List
          ? list.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
          : const [],
    );
  }
}

class PhenotypeCatalog {
  const PhenotypeCatalog({
    required this.id,
    required this.title,
    required this.version,
    required this.notes,
    required this.series,
  });

  final String id;
  final String title;
  final String version;
  final List<String> notes;
  final List<PhenotypeSeriesCatalog> series;

  factory PhenotypeCatalog.fromJson(Map<String, dynamic> json) {
    final notes = json['notes'];
    final series = json['series'];
    return PhenotypeCatalog(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      version: json['version'] as String? ?? '',
      notes: notes is List
          ? notes.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
          : const [],
      series: series is List
          ? series
                .whereType<Map>()
                .map(
                  (e) => PhenotypeSeriesCatalog.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const [],
    );
  }

  PhenotypeSeriesCatalog? seriesByCode(String code) {
    for (final s in series) {
      if (s.code == code) return s;
    }
    return null;
  }
}

class TargetCrossRecommendation {
  const TargetCrossRecommendation({
    required this.parentA,
    required this.parentB,
    required this.targetProbability,
    this.targetFraction,
    this.outcomes = const [],
  });

  final String parentA;
  final String parentB;
  final double targetProbability;
  final String? targetFraction;
  final List<GeneticOutcome> outcomes;

  String get percentLabel => '${(targetProbability * 100).toStringAsFixed(1)}%';

  factory TargetCrossRecommendation.fromJson(Map<String, dynamic> json) {
    final outcomes = json['outcomes'];
    return TargetCrossRecommendation(
      parentA: json['parent_a'] as String? ?? '',
      parentB: json['parent_b'] as String? ?? '',
      targetProbability: (json['target_probability'] as num?)?.toDouble() ?? 0,
      targetFraction: json['target_fraction'] as String?,
      outcomes: outcomes is List
          ? outcomes.whereType<Map>().map((e) {
              final m = Map<String, dynamic>.from(e);
              // table_outcomes shape → GeneticOutcome
              if (m.containsKey('phenotype') &&
                  !m.containsKey('phenotype_label')) {
                final ph = m['phenotype']?.toString() ?? '';
                final frac = m['fraction']?.toString() ?? '';
                return GeneticOutcome(
                  genotypeKey: 'phenotype=$ph',
                  genotype: {
                    'phenotype': ph,
                    if (frac.isNotEmpty) 'fraction': frac,
                  },
                  phenotypeLabel: ph,
                  phenotype: {'label': ph},
                  probability: (m['probability'] as num?)?.toDouble() ?? 0,
                  countWeight: 1,
                );
              }
              return GeneticOutcome.fromJson(m);
            }).toList()
          : const [],
    );
  }
}

/// Local authority-table index for offline / memory repository.
class PhenotypeTableIndex {
  PhenotypeTableIndex(this.document);

  final Map<String, dynamic> document;
  late final Map<String, Map<String, dynamic>> _crossByKey = {};
  late final PhenotypeCatalog catalog;

  factory PhenotypeTableIndex.fromJson(Map<String, dynamic> json) {
    final idx = PhenotypeTableIndex(json);
    idx.catalog = PhenotypeCatalog.fromJson(json);
    final crosses = json['crosses'];
    if (crosses is List) {
      for (final raw in crosses.whereType<Map>()) {
        final c = Map<String, dynamic>.from(raw);
        final series = c['series']?.toString() ?? '';
        final a = c['parent_a']?.toString() ?? '';
        final b = c['parent_b']?.toString() ?? '';
        final key = _crossKey(series, a, b);
        idx._crossByKey[key] = c;
      }
    }
    return idx;
  }

  static String _normPair(String a, String b) {
    final x = a.trim();
    final y = b.trim();
    return x.compareTo(y) <= 0 ? '$x\x00$y' : '$y\x00$x';
  }

  static String _crossKey(String series, String a, String b) {
    final pair = _normPair(a, b);
    return '$series\x00$pair';
  }

  GeneticSimulationResult simulate({
    required String series,
    required String sirePhenotype,
    required String damPhenotype,
  }) {
    final ser = catalog.seriesByCode(series);
    if (ser == null) {
      throw FormatException('未知系列 $series');
    }
    if (!ser.phenotypes.contains(sirePhenotype)) {
      throw FormatException('表型 "$sirePhenotype" 不在系列 ${ser.name} 中');
    }
    if (!ser.phenotypes.contains(damPhenotype)) {
      throw FormatException('表型 "$damPhenotype" 不在系列 ${ser.name} 中');
    }
    final cross = _crossByKey[_crossKey(series, sirePhenotype, damPhenotype)];
    if (cross == null) {
      throw FormatException(
        '核心表中无此配对：$sirePhenotype × $damPhenotype（系列 ${ser.name}）',
      );
    }
    final rawOutcomes = cross['outcomes'];
    final outcomes = <GeneticOutcome>[];
    if (rawOutcomes is List) {
      for (final raw in rawOutcomes.whereType<Map>()) {
        final m = Map<String, dynamic>.from(raw);
        final ph = m['phenotype']?.toString() ?? '';
        final frac = m['fraction']?.toString() ?? '';
        final p = (m['probability'] as num?)?.toDouble() ?? 0;
        outcomes.add(
          GeneticOutcome(
            genotypeKey: 'phenotype=$ph',
            genotype: {'phenotype': ph, if (frac.isNotEmpty) 'fraction': frac},
            phenotypeLabel: ph,
            phenotype: {'label': ph, 'series': series},
            probability: p,
            countWeight: 1,
          ),
        );
      }
    }
    outcomes.sort((a, b) {
      final byP = b.probability.compareTo(a.probability);
      if (byP != 0) return byP;
      return a.phenotypeLabel.compareTo(b.phenotypeLabel);
    });
    final notes = (document['notes'] is List)
        ? (document['notes'] as List).map((e) => e.toString()).join(' ')
        : '';
    final version = document['version']?.toString() ?? '';
    final title = document['title']?.toString() ?? '核心表';
    return GeneticSimulationResult(
      sire: {'series': series, 'phenotype': sirePhenotype},
      dam: {'series': series, 'phenotype': damPhenotype},
      outcomes: outcomes,
      notes: '$notes 数据源：$title（$version）。',
      mode: 'phenotype_table',
      series: series,
      seriesName: ser.name,
      sirePhenotype: sirePhenotype,
      damPhenotype: damPhenotype,
      tableVersion: version,
    );
  }

  List<TargetCrossRecommendation> findForTarget({
    required String series,
    required String targetPhenotype,
  }) {
    final list = <TargetCrossRecommendation>[];
    for (final cross in _crossByKey.values) {
      if (cross['series']?.toString() != series) continue;
      final outcomesRaw = cross['outcomes'];
      if (outcomesRaw is! List) continue;
      double? p;
      String? frac;
      final outcomes = <GeneticOutcome>[];
      for (final raw in outcomesRaw.whereType<Map>()) {
        final m = Map<String, dynamic>.from(raw);
        final ph = m['phenotype']?.toString() ?? '';
        final probability = (m['probability'] as num?)?.toDouble() ?? 0;
        final fraction = m['fraction']?.toString() ?? '';
        outcomes.add(
          GeneticOutcome(
            genotypeKey: 'phenotype=$ph',
            genotype: {
              'phenotype': ph,
              if (fraction.isNotEmpty) 'fraction': fraction,
            },
            phenotypeLabel: ph,
            phenotype: {'label': ph},
            probability: probability,
            countWeight: 1,
          ),
        );
        if (ph == targetPhenotype) {
          p = probability;
          frac = fraction.isEmpty ? null : fraction;
        }
      }
      if (p == null || p <= 0) continue;
      list.add(
        TargetCrossRecommendation(
          parentA: cross['parent_a']?.toString() ?? '',
          parentB: cross['parent_b']?.toString() ?? '',
          targetProbability: p,
          targetFraction: frac,
          outcomes: outcomes,
        ),
      );
    }
    list.sort((a, b) {
      final byP = b.targetProbability.compareTo(a.targetProbability);
      if (byP != 0) return byP;
      return ('${a.parentA}${a.parentB}').compareTo('${b.parentA}${b.parentB}');
    });
    return list;
  }
}

String? normalizeAllelePair(GeneticLocus locus, String raw) {
  var value = raw.trim().replaceAll(' ', '');
  late String a1;
  late String a2;
  if (value.contains('/')) {
    final parts = value.split('/');
    if (parts.length != 2) return null;
    a1 = parts[0];
    a2 = parts[1];
  } else if (value.runes.length == 2) {
    final runes = value.runes.toList();
    a1 = String.fromCharCode(runes[0]);
    a2 = String.fromCharCode(runes[1]);
  } else {
    return null;
  }
  final valid = {locus.dominantAllele, locus.recessiveAllele};
  if (!valid.contains(a1) || !valid.contains(a2)) return null;
  if (a1 == locus.recessiveAllele && a2 == locus.dominantAllele) {
    final tmp = a1;
    a1 = a2;
    a2 = tmp;
  }
  return '$a1/$a2';
}

Map<String, String> phenotypeMapFor(Map<String, String> genotype) {
  final out = <String, String>{};
  for (final locus in defaultGeneticLoci) {
    final pair = genotype[locus.code];
    if (pair == null || pair.isEmpty) continue;
    final norm = normalizeAllelePair(locus, pair);
    if (norm == null) continue;
    final alleles = norm.split('/');
    final recessiveOnly =
        alleles[0] == locus.recessiveAllele &&
        alleles[1] == locus.recessiveAllele;
    out[locus.code] = recessiveOnly
        ? locus.recessiveLabel
        : locus.dominantLabel;
  }
  return out;
}

String phenotypeLabelFor(Map<String, String> genotype) {
  final map = phenotypeMapFor(genotype);
  if (map.isEmpty) return '未知表型';
  final parts = <String>[];
  for (final locus in defaultGeneticLoci) {
    final label = map[locus.code];
    if (label != null) parts.add(label);
  }
  return parts.join(' · ');
}

/// Pure multi-locus Punnett simulator (mirrors geneticcore.Simulate).
GeneticSimulationResult simulateBreeding(
  Map<String, String> sire,
  Map<String, String> dam,
) {
  final sireN = <String, String>{};
  final damN = <String, String>{};
  final lociUsed = <GeneticLocus>[];
  for (final locus in defaultGeneticLoci) {
    final sRaw = sire[locus.code];
    final dRaw = dam[locus.code];
    if (sRaw == null && dRaw == null) continue;
    if (sRaw == null || dRaw == null) {
      throw const FormatException('位点父母双方都需要基因型');
    }
    final sNorm = normalizeAllelePair(locus, sRaw);
    final dNorm = normalizeAllelePair(locus, dRaw);
    if (sNorm == null || dNorm == null) {
      throw FormatException('位点 ${locus.code} 基因型无效');
    }
    sireN[locus.code] = sNorm;
    damN[locus.code] = dNorm;
    lociUsed.add(locus);
  }
  if (lociUsed.isEmpty) {
    throw const FormatException('至少需要一个共同位点');
  }

  var combos = <({Map<String, String> gt, int weight})>[
    (gt: <String, String>{}, weight: 1),
  ];
  for (final locus in lociUsed) {
    final sAlleles = sireN[locus.code]!.split('/');
    final dAlleles = damN[locus.code]!.split('/');
    final next = <({Map<String, String> gt, int weight})>[];
    for (final c in combos) {
      for (final sa in sAlleles) {
        for (final da in dAlleles) {
          final pair = normalizeAllelePair(locus, '$sa/$da')!;
          final ng = Map<String, String>.from(c.gt)..[locus.code] = pair;
          next.add((gt: ng, weight: c.weight));
        }
      }
    }
    combos = next;
  }

  final total = combos.fold<int>(0, (sum, c) => sum + c.weight);
  final merged = <String, GeneticOutcome>{};
  for (final c in combos) {
    final key = _genotypeKey(c.gt);
    final existing = merged[key];
    if (existing != null) {
      merged[key] = GeneticOutcome(
        genotypeKey: existing.genotypeKey,
        genotype: existing.genotype,
        phenotypeLabel: existing.phenotypeLabel,
        phenotype: existing.phenotype,
        probability: 0,
        countWeight: existing.countWeight + c.weight,
      );
      continue;
    }
    final pheno = phenotypeMapFor(c.gt);
    merged[key] = GeneticOutcome(
      genotypeKey: key,
      genotype: c.gt,
      phenotypeLabel: phenotypeLabelFor(c.gt),
      phenotype: pheno,
      probability: 0,
      countWeight: c.weight,
    );
  }
  final outcomes =
      merged.values
          .map(
            (o) => GeneticOutcome(
              genotypeKey: o.genotypeKey,
              genotype: o.genotype,
              phenotypeLabel: o.phenotypeLabel,
              phenotype: o.phenotype,
              probability: o.countWeight / total,
              countWeight: o.countWeight,
            ),
          )
          .toList()
        ..sort((a, b) {
          final byP = b.probability.compareTo(a.probability);
          if (byP != 0) return byP;
          return a.genotypeKey.compareTo(b.genotypeKey);
        });

  return GeneticSimulationResult(
    sire: sireN,
    dam: damN,
    outcomes: outcomes,
    notes: '简化孟德尔模型，仅供教育与配对参考，非完整金丝熊遗传标准。',
  );
}

String _genotypeKey(Map<String, String> gt) {
  final keys = gt.keys.toList()..sort();
  return keys.map((k) => '$k=${gt[k]}').join(';');
}

/// Expected offspring count for a given litter size (theoretical).
double expectedOffspringCount(double probability, int litterSize) {
  if (litterSize < 0) return 0;
  return probability * litterSize;
}

/// Probability that an outcome appears at least once in a litter.
double probabilityAtLeastOne(double probability, int litterSize) {
  if (litterSize <= 0) return 0;
  final p = probability.clamp(0.0, 1.0).toDouble();
  return 1 - math.pow(1 - p, litterSize).toDouble();
}

/// Combined probability for a phenotype (some engines may emit split rows).
double phenotypeProbability(
  Iterable<GeneticOutcome> outcomes,
  String? phenotype,
) {
  if (phenotype == null || phenotype.trim().isEmpty) return 0;
  return outcomes
      .where((outcome) => outcome.phenotypeLabel == phenotype)
      .fold<double>(0, (sum, outcome) => sum + outcome.probability)
      .clamp(0.0, 1.0)
      .toDouble();
}

/// Highest-probability phenotype, preserving source order for ties.
GeneticOutcome? mostLikelyOutcome(Iterable<GeneticOutcome> outcomes) {
  GeneticOutcome? best;
  for (final outcome in outcomes) {
    if (best == null || outcome.probability > best.probability) {
      best = outcome;
    }
  }
  return best;
}

String formatProbabilityPercent(double probability) {
  final p = probability.clamp(0.0, 1.0).toDouble();
  return '${(p * 100).toStringAsFixed(1)}%';
}

/// Consumer-facing “为什么？” block — pure presentation over authority results.
///
/// Does **not** recompute genetics; only formats fields already returned by
/// phenotype-table / Mendel simulators.
class SimulationWhyExplanation {
  const SimulationWhyExplanation({
    required this.sireSummary,
    required this.damSummary,
    required this.therefore,
    required this.highlights,
    required this.basisNote,
  });

  /// e.g. 表现「蜜波利」 / 携带 A=A/a
  final String sireSummary;
  final String damSummary;

  /// One-line conclusion for the pair.
  final String therefore;

  /// Top outcomes as short bullets (phenotype + %).
  final List<String> highlights;

  /// Authority / history basis for the user.
  final String basisNote;
}

/// Summarize a genotype map without inventing new allele rules.
String summarizeGenotypeCarries(Map<String, String> genotype) {
  if (genotype.isEmpty) return '基因型未提供';
  // Phenotype-table path stores series/phenotype keys, not locus alleles.
  final ph = genotype['phenotype']?.trim();
  if (ph != null && ph.isNotEmpty) return '表现「$ph」';

  final parts = <String>[];
  for (final locus in defaultGeneticLoci) {
    final raw = genotype[locus.code];
    if (raw == null || raw.trim().isEmpty) continue;
    final norm = normalizeAllelePair(locus, raw);
    if (norm == null) {
      parts.add('${locus.code}=$raw');
      continue;
    }
    final alleles = norm.split('/');
    final bothRecessive =
        alleles[0] == locus.recessiveAllele &&
        alleles[1] == locus.recessiveAllele;
    final bothDominant =
        alleles[0] == locus.dominantAllele &&
        alleles[1] == locus.dominantAllele;
    if (bothRecessive) {
      parts.add('表现${locus.recessiveLabel}（${locus.code}=$norm）');
    } else if (bothDominant) {
      parts.add('表现${locus.dominantLabel}（${locus.code}=$norm）');
    } else {
      parts.add(
        '表现${locus.dominantLabel}、携带${locus.recessiveLabel}隐性'
        '（${locus.code}=$norm）',
      );
    }
  }
  if (parts.isEmpty) {
    // Fallback: print remaining keys (still authority payload, not recomputed).
    final keys = genotype.keys.toList()..sort();
    return keys.map((k) => '$k=${genotype[k]}').join(' · ');
  }
  return parts.join('；');
}

/// Build the “为什么？” explanation from an existing simulation result only.
SimulationWhyExplanation buildSimulationWhyExplanation(
  GeneticSimulationResult result, {
  int topN = 3,
}) {
  final sirePh =
      result.sirePhenotype?.trim().isNotEmpty == true
      ? result.sirePhenotype!.trim()
      : (result.sire['phenotype']?.trim().isNotEmpty == true
            ? result.sire['phenotype']!.trim()
            : null);
  final damPh =
      result.damPhenotype?.trim().isNotEmpty == true
      ? result.damPhenotype!.trim()
      : (result.dam['phenotype']?.trim().isNotEmpty == true
            ? result.dam['phenotype']!.trim()
            : null);

  final sireSummary = sirePh != null
      ? '表现「$sirePh」'
      : summarizeGenotypeCarries(result.sire);
  final damSummary = damPh != null
      ? '表现「$damPh」'
      : summarizeGenotypeCarries(result.dam);

  final ranked = List<GeneticOutcome>.from(result.outcomes)
    ..sort((a, b) {
      final byP = b.probability.compareTo(a.probability);
      if (byP != 0) return byP;
      return a.phenotypeLabel.compareTo(b.phenotypeLabel);
    });
  final n = topN < 1 ? 1 : topN;
  final top = ranked.take(n).toList();
  final highlights = <String>[
    for (final o in top)
      '${o.phenotypeLabel} ${o.percentLabel}'
          '${o.genotype['fraction'] != null && o.genotype['fraction']!.isNotEmpty ? '（${o.genotype['fraction']}）' : ''}',
  ];

  final most = top.isEmpty ? null : top.first;
  final seriesPart = (result.seriesName ?? result.series)?.trim();
  final pairPart = (sirePh != null && damPh != null)
      ? '「$sirePh」×「$damPh」'
      : '该配对';

  final String therefore;
  if (most == null) {
    therefore = '$pairPart 暂无可用后代概率结果。';
  } else if (result.isPhenotypeTable) {
    therefore =
        '${seriesPart == null || seriesPart.isEmpty ? '' : '$seriesPart 系列中，'}'
        '$pairPart 后代最可能出现「${most.phenotypeLabel}」'
        '（${most.percentLabel}）'
        '${top.length > 1 ? '，并可能出现 ${top.skip(1).map((o) => o.phenotypeLabel).join('、')}' : ''}。';
  } else {
    therefore =
        '按位点孟德尔组合，$pairPart 后代最可能表型为「${most.phenotypeLabel}」'
        '（${most.percentLabel}）。';
  }

  final basisNote = result.usesHistoricalRecords
      ? '已结合历史繁殖记录校准；单窝仍会有随机波动，以下为期望比例。'
      : (result.isPhenotypeTable
            ? '基于权威表型表${result.tableVersion == null || result.tableVersion!.isEmpty ? '' : '（${result.tableVersion}）'}；以下为理论概率，单窝不保证按比例出现。'
            : '基于位点组合理论概率；单窝不保证按比例出现。');

  return SimulationWhyExplanation(
    sireSummary: sireSummary,
    damSummary: damSummary,
    therefore: therefore,
    highlights: highlights,
    basisNote: basisNote,
  );
}

/// Validates phenotype counts against declared live pup total.
class PhenotypeCountValidation {
  const PhenotypeCountValidation({
    required this.livePups,
    required this.counts,
  });

  final int livePups;
  final Map<String, int> counts;

  int get sum => counts.values.fold<int>(0, (a, b) => a + (b < 0 ? 0 : b));

  bool get hasAnyCount => counts.values.any((n) => n > 0);

  /// When user entered any phenotype count, sum must equal live pups.
  /// livePups==0 means no litter — counts must be empty.
  bool get isValid {
    if (livePups < 0) return false;
    if (livePups == 0) return !hasAnyCount;
    if (!hasAnyCount) return true; // optional skip of phenotype breakdown
    return sum == livePups;
  }

  String? get errorMessage {
    if (livePups < 0) return '活仔数不能为负';
    if (livePups == 0 && hasAnyCount) {
      return '无活仔时不应填写表型计数';
    }
    if (hasAnyCount && sum != livePups) {
      return '表型计数合计 $sum ≠ 活仔数 $livePups';
    }
    return null;
  }
}

String formatExpectedCount(double probability, int litterSize) {
  final n = expectedOffspringCount(probability, litterSize);
  if (n == 0) return '0';
  if (n == n.roundToDouble()) return n.toInt().toString();
  return n.toStringAsFixed(1);
}

/// Snapshot text for breeding-plan notes (core table authority).
String buildSimulationPlanNotes({
  required GeneticSimulationResult result,
  int? litterSize,
}) {
  final buf = StringBuffer();
  final usesHistory = result.usesHistoricalRecords;
  buf.writeln(usesHistory ? '[遗传推算（已结合历史）]' : '[核心表推算]');
  if (result.seriesName != null || result.series != null) {
    buf.writeln('系列: ${result.seriesName ?? result.series}');
  }
  if (result.sirePhenotype != null && result.damPhenotype != null) {
    buf.writeln('配对: ${result.sirePhenotype} × ${result.damPhenotype}');
  }
  if (result.tableVersion != null && result.tableVersion!.isNotEmpty) {
    buf.writeln('表版本: ${result.tableVersion}');
  }
  if (litterSize != null && litterSize > 0) {
    buf.writeln('假设窝产: $litterSize 只（理论期望）');
  }
  buf.writeln('后代表型概率:');
  for (final o in result.outcomes) {
    final frac = o.genotype['fraction'];
    final fracPart = (frac != null && frac.isNotEmpty) ? ' ($frac)' : '';
    final expPart = (litterSize != null && litterSize > 0)
        ? ' · 期望 ${formatExpectedCount(o.probability, litterSize)} 只'
        : '';
    buf.writeln('- ${o.phenotypeLabel}: ${o.percentLabel}$fracPart$expPart');
  }
  buf.writeln(
    usesHistory ? '说明: 已结合历史繁殖记录，单窝仍会有随机波动。' : '说明: 理论概率，单窝不保证按比例出现。',
  );
  // Machine-readable block for later actual-vs-predicted feedback.
  final outcomesJson = result.outcomes
      .map(
        (o) =>
            '{"phenotype":"${o.phenotypeLabel}","p":${o.probability},"fraction":"${o.genotype['fraction'] ?? ''}"}',
      )
      .join(',');
  buf.writeln('---scolvpet-sim-json---');
  buf.writeln(
    '{"series":"${result.series ?? ''}","sire":"${result.sirePhenotype ?? ''}","dam":"${result.damPhenotype ?? ''}","litter_size":${litterSize ?? 0},"outcomes":[$outcomesJson]}',
  );
  buf.writeln('---end-scolvpet-sim-json---');
  return buf.toString().trimRight();
}

/// Parsed prediction snapshot from plan notes (if present).
class SimulationSnapshot {
  const SimulationSnapshot({
    required this.series,
    required this.sire,
    required this.dam,
    this.litterSize,
  });

  final String series;
  final String sire;
  final String dam;
  final int? litterSize;

  static SimulationSnapshot? tryParseNotes(String? notes) {
    if (notes == null || notes.isEmpty) return null;
    const start = '---scolvpet-sim-json---';
    const end = '---end-scolvpet-sim-json---';
    final i = notes.indexOf(start);
    final j = notes.indexOf(end);
    if (i < 0 || j < 0 || j <= i) return null;
    final raw = notes.substring(i + start.length, j).trim();
    try {
      final map = _parseLooseJsonObject(raw);
      final series = map['series']?.toString() ?? '';
      final sire = map['sire']?.toString() ?? '';
      final dam = map['dam']?.toString() ?? '';
      if (series.isEmpty || sire.isEmpty || dam.isEmpty) return null;
      final ls = map['litter_size'];
      int? litterSize;
      if (ls is num) litterSize = ls.toInt();
      if (ls is String) litterSize = int.tryParse(ls);
      return SimulationSnapshot(
        series: series,
        sire: sire,
        dam: dam,
        litterSize: litterSize,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Minimal object parser for the compact snapshot we emit (no nested objects needed).
Map<String, dynamic> _parseLooseJsonObject(String raw) {
  // Prefer dart:convert when available via top-level import in repository;
  // here keep dependency-free simple path using RegExp for our fixed shape.
  final series = RegExp(r'"series"\s*:\s*"([^"]*)"').firstMatch(raw)?.group(1);
  final sire = RegExp(r'"sire"\s*:\s*"([^"]*)"').firstMatch(raw)?.group(1);
  final dam = RegExp(r'"dam"\s*:\s*"([^"]*)"').firstMatch(raw)?.group(1);
  final litter = RegExp(r'"litter_size"\s*:\s*(\d+)').firstMatch(raw)?.group(1);
  return {
    'series': series,
    'sire': sire,
    'dam': dam,
    'litter_size': litter == null ? null : int.tryParse(litter),
  };
}

class PhenotypeCompareRow {
  const PhenotypeCompareRow({
    required this.phenotype,
    required this.predictedProbability,
    required this.expectedCount,
    required this.actualCount,
    required this.residual,
    required this.absResidual,
    this.predictedFraction,
  });

  final String phenotype;
  final double predictedProbability;
  final String? predictedFraction;
  final double expectedCount;
  final int actualCount;
  final double residual;
  final double absResidual;

  String get predictedPercent =>
      '${(predictedProbability * 100).toStringAsFixed(1)}%';

  factory PhenotypeCompareRow.fromJson(Map<String, dynamic> json) =>
      PhenotypeCompareRow(
        phenotype: json['phenotype'] as String? ?? '',
        predictedProbability:
            (json['predicted_probability'] as num?)?.toDouble() ?? 0,
        predictedFraction: json['predicted_fraction'] as String?,
        expectedCount: (json['expected_count'] as num?)?.toDouble() ?? 0,
        actualCount: (json['actual_count'] as num?)?.toInt() ?? 0,
        residual: (json['residual'] as num?)?.toDouble() ?? 0,
        absResidual: (json['abs_residual'] as num?)?.toDouble() ?? 0,
      );
}

class PhenotypeCompareResult {
  const PhenotypeCompareResult({
    required this.series,
    required this.seriesName,
    required this.sirePhenotype,
    required this.damPhenotype,
    required this.totalActual,
    required this.rows,
    required this.meanAbsError,
    required this.totalVariation,
    required this.notes,
    this.tableVersion,
    this.feedbackId,
  });

  final String series;
  final String seriesName;
  final String sirePhenotype;
  final String damPhenotype;
  final int totalActual;
  final List<PhenotypeCompareRow> rows;
  final double meanAbsError;
  final double totalVariation;
  final String notes;
  final String? tableVersion;
  final String? feedbackId;

  factory PhenotypeCompareResult.fromJson(Map<String, dynamic> json) {
    // API may wrap as { comparison, feedback_id }.
    final root = json['comparison'] is Map
        ? Map<String, dynamic>.from(json['comparison'] as Map)
        : json;
    final rows = root['rows'];
    return PhenotypeCompareResult(
      series: root['series'] as String? ?? '',
      seriesName: root['series_name'] as String? ?? '',
      sirePhenotype: root['sire_phenotype'] as String? ?? '',
      damPhenotype: root['dam_phenotype'] as String? ?? '',
      totalActual: (root['total_actual'] as num?)?.toInt() ?? 0,
      rows: rows is List
          ? rows
                .whereType<Map>()
                .map(
                  (e) => PhenotypeCompareRow.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const [],
      meanAbsError: (root['mean_abs_error'] as num?)?.toDouble() ?? 0,
      totalVariation: (root['total_variation'] as num?)?.toDouble() ?? 0,
      notes: root['notes'] as String? ?? '',
      tableVersion: root['table_version'] as String?,
      feedbackId: json['feedback_id'] as String?,
    );
  }
}

/// Aggregated deviation for one parent pair (org-level).
class PhenotypeFeedbackPairSummary {
  const PhenotypeFeedbackPairSummary({
    required this.series,
    required this.sirePhenotype,
    required this.damPhenotype,
    required this.sampleCount,
    required this.avgMeanAbsError,
    required this.avgTotalVariation,
    required this.avgLitterSize,
    this.lastAt,
  });

  final String series;
  final String sirePhenotype;
  final String damPhenotype;
  final int sampleCount;
  final double avgMeanAbsError;
  final double avgTotalVariation;
  final double avgLitterSize;
  final DateTime? lastAt;

  String get pairLabel => '$sirePhenotype × $damPhenotype';

  factory PhenotypeFeedbackPairSummary.fromJson(Map<String, dynamic> json) =>
      PhenotypeFeedbackPairSummary(
        series: json['series'] as String? ?? '',
        sirePhenotype: json['sire_phenotype'] as String? ?? '',
        damPhenotype: json['dam_phenotype'] as String? ?? '',
        sampleCount: (json['sample_count'] as num?)?.toInt() ?? 0,
        avgMeanAbsError: (json['avg_mean_abs_error'] as num?)?.toDouble() ?? 0,
        avgTotalVariation:
            (json['avg_total_variation'] as num?)?.toDouble() ?? 0,
        avgLitterSize: (json['avg_litter_size'] as num?)?.toDouble() ?? 0,
        lastAt: DateTime.tryParse(json['last_at'] as String? ?? '')?.toUtc(),
      );
}

/// Local compare using authority table (mirrors geneticcore.CompareActualToTable).
PhenotypeCompareResult compareActualLocally({
  required PhenotypeTableIndex table,
  required String series,
  required String sirePhenotype,
  required String damPhenotype,
  required Map<String, int> actualCounts,
}) {
  final sim = table.simulate(
    series: series,
    sirePhenotype: sirePhenotype,
    damPhenotype: damPhenotype,
  );
  var total = 0;
  actualCounts.forEach((_, n) {
    if (n > 0) total += n;
  });
  if (total <= 0) {
    throw const FormatException('实际只数合计须大于 0');
  }
  final labels = <String>{
    ...sim.outcomes.map((o) => o.phenotypeLabel),
    ...actualCounts.keys.where((k) => k.trim().isNotEmpty),
  };
  final predBy = {for (final o in sim.outcomes) o.phenotypeLabel: o};
  final rows = <PhenotypeCompareRow>[];
  var sumAbs = 0.0;
  var tv = 0.0;
  for (final ph in labels) {
    final o = predBy[ph];
    final p = o?.probability ?? 0.0;
    final actual = actualCounts[ph] ?? 0;
    final expected = p * total;
    final residual = actual - expected;
    final obsP = actual / total;
    tv += (obsP - p).abs();
    sumAbs += residual.abs();
    rows.add(
      PhenotypeCompareRow(
        phenotype: ph,
        predictedProbability: p,
        predictedFraction: o?.genotype['fraction'],
        expectedCount: expected,
        actualCount: actual,
        residual: residual,
        absResidual: residual.abs(),
      ),
    );
  }
  rows.sort((a, b) {
    final byR = b.absResidual.compareTo(a.absResidual);
    if (byR != 0) return byR;
    return b.predictedProbability.compareTo(a.predictedProbability);
  });
  return PhenotypeCompareResult(
    series: sim.series ?? series,
    seriesName: sim.seriesName ?? series,
    sirePhenotype: sirePhenotype,
    damPhenotype: damPhenotype,
    totalActual: total,
    rows: rows,
    meanAbsError: sumAbs / rows.length,
    totalVariation: 0.5 * tv,
    notes: '对比基于核心表理论概率与本窝实际计数；小样本偏差属正常，不表示核心表错误。',
    tableVersion: sim.tableVersion,
  );
}
