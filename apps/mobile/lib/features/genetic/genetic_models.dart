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
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '')?.toUtc(),
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
  });

  final Map<String, String> sire;
  final Map<String, String> dam;
  final List<GeneticOutcome> outcomes;
  final String notes;

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
                .map((e) => GeneticOutcome.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
      notes: json['notes'] as String? ?? '',
    );
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
  final outcomes = merged.values
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
