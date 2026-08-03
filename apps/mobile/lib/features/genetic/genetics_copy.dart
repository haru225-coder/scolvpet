/// 遗传 / 繁育模拟 · 展示层人话（只读权威结果，不重算、不改名）。
///
/// 对照任务书：结论先行 L1–L4；权威代码仅出现在 L4 折叠区。
library;

import 'genetic_models.dart';

// —— 固定文案（第三节，勿再创作）——

class GeneticsUiCopy {
  GeneticsUiCopy._();

  static const pageTitle = '这两只会生出什么';
  static const entryCta = '试配一下';
  static const runCta = '试配一下';
  static const emptyHint = '选好父母表型后点「试配一下」';
  static const resultHeading = '宝宝可能长这样';
  static const professionalSectionTitle = '专业信息（基因型）';
  static const savePlanCta = '存成繁育计划';
  static const missingData = '资料不足，算不准';
  static const notRegistered = '没登记';
  static const riskBanner = '这一配有风险';
  static const fillDataCta = '去补资料';

  /// 可见层禁止直出的英文/字段名（L4 与 docs 除外）。
  static const bannedVisibleTokens = <String>[
    'genotype',
    'phenotype',
    'punnett',
    'lethal',
    'homozygous',
    'COI',
    'null',
    'undefined',
  ];
}

/// L1 结论色。
enum GeneticsConclusionTone { green, blue, yellow, orange, red }

/// L1 一句人话（只允许任务书 3.2 五句模板）。
class GeneticsConclusion {
  const GeneticsConclusion({required this.tone, required this.line});

  final GeneticsConclusionTone tone;
  final String line;
}

/// 概率：整数百分比（仅格式化，不改概率语义）。
String formatGeneticsPercent(double probability) {
  final p = probability.clamp(0.0, 1.0);
  return '${(p * 100).round()}%';
}

/// 「约 N 只里 M 只」——用最接近的小分母表述，不发明新概率。
String formatAboutNInM(double probability) {
  final p = probability.clamp(0.0, 1.0);
  if (p <= 0) return '约不会出现';
  if (p >= 0.999) return '约每只都会';
  for (var n = 2; n <= 12; n++) {
    final m = (p * n).round();
    if (m < 1) continue;
    if ((m / n - p).abs() <= 0.03) {
      return '约 $n 只里 $m 只';
    }
  }
  final m = (p * 4).round().clamp(1, 4);
  return '约 4 只里 $m 只';
}

/// 窝产期望人话（权威 probability × 窝产）。
String formatExpectedPupsLine(double probability, int litterSize) {
  if (litterSize <= 0) return formatAboutNInM(probability);
  final expected = probability * litterSize;
  final label = expected == expected.roundToDouble()
      ? expected.toInt().toString()
      : expected.toStringAsFixed(1);
  return '按 $litterSize 只窝产，约 $label 只 · ${formatAboutNInM(probability)}';
}

/// 空值展示。
String humanMissing(Object? value) {
  if (value == null) return GeneticsUiCopy.notRegistered;
  final s = value.toString().trim();
  if (s.isEmpty ||
      s == '--' ||
      s == '-' ||
      s.toLowerCase() == 'null' ||
      s.toLowerCase() == 'unknown' ||
      s.toLowerCase() == 'undefined') {
    return GeneticsUiCopy.notRegistered;
  }
  return s;
}

/// 术语对照表 · 可接线项（与 `docs/product/遗传术语人话对照表.md` 同步）。
///
/// key = 权威侧出现的原文/英文；value = 界面主显示人话。
/// 波利色显示名原样保留，不进此表替换。
const Map<String, String> geneticsTermDisplayTable = {
  // 教育位点表（权威已给中文时直通；英文/别名走表）
  '刺鼠': '刺鼠',
  '黑': '黑',
  '黑系': '黑系',
  '肉桂': '肉桂',
  '有色': '有色',
  '白化': '白化',
  // 概念字段
  'phenotype': '看得见的样子',
  '表型': '看得见的样子',
  'genotype': '基因型',
  '基因型': '基因型',
  'punnett': '配对表',
  'punnett square': '配对表',
  // 风险 / 近亲（概念句，不编数字）
  'homozygous lethal': '这种搭配可能生出活不下来的宝宝',
  'carrier': '自己不显，但会传给宝宝',
  '携带者': '自己不显，但会传给宝宝',
  '杂合携带': '自己不显，但会传给宝宝',
  'anophthalmic white': '可能生出没有眼睛的宝宝',
  'anophthalmic': '可能生出没有眼睛的宝宝',
  '无眼白': '可能生出没有眼睛的宝宝',
  'half-sib': '同父异母 / 同母异父',
  'halfsib': '同父异母 / 同母异父',
  'coi': '它们是亲兄妹级的近亲',
  'inbreeding': '它们是亲兄妹级的近亲',
  '近交系数': '它们是亲兄妹级的近亲',
};

/// 波利色：显示名原样锁定（只允许加解释，不替换主名）。
bool isLockedPoliPhenotypeLabel(String raw) {
  final t = raw.trim();
  return t.contains('波利');
}

/// 风险 / 近亲 / 概念术语 → 人话（附加层；权威原文仍可放在 L4）。
String humanizeGeneticsTerm(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return GeneticsUiCopy.notRegistered;
  // 波利色锁定：主显示名不替换
  if (isLockedPoliPhenotypeLabel(t)) return t;

  final exact = geneticsTermDisplayTable[t] ??
      geneticsTermDisplayTable[t.toLowerCase()];
  if (exact != null) return exact;

  final lower = t.toLowerCase();
  if (lower.contains('homozygous lethal') ||
      (lower.contains('lethal') && lower.contains('homozyg')) ||
      t.contains('致死基因纯合') ||
      t.contains('纯合致死')) {
    return geneticsTermDisplayTable['homozygous lethal']!;
  }
  if (lower.contains('anophthalmic') ||
      t.contains('无眼白') ||
      lower.contains('anophthalmia')) {
    return geneticsTermDisplayTable['anophthalmic']!;
  }
  if (lower.contains('half-sib') ||
      lower.contains('halfsib') ||
      t.contains('同父异母') ||
      t.contains('同母异父')) {
    return geneticsTermDisplayTable['half-sib']!;
  }
  if (lower.contains('coi') ||
      lower.contains('inbreed') ||
      t.contains('近交系数')) {
    return geneticsTermDisplayTable['coi']!;
  }
  if (lower.contains('carrier') || t.contains('杂合携带') || t.contains('携带者')) {
    return geneticsTermDisplayTable['carrier']!;
  }
  if (lower.contains('punnett')) {
    return geneticsTermDisplayTable['punnett']!;
  }
  if (lower == 'phenotype') {
    return geneticsTermDisplayTable['phenotype']!;
  }
  if (lower == 'genotype') {
    return geneticsTermDisplayTable['genotype']!;
  }
  // 未进表：权威中文表型等原样直通，禁止猜测改名
  return t;
}

/// 结果行主显示：波利原样；其余走 humanMissing + 术语表。
String displayPhenotypeLabel(Object? value) {
  final base = humanMissing(value);
  if (base == GeneticsUiCopy.notRegistered) return base;
  if (isLockedPoliPhenotypeLabel(base)) return base;
  return humanizeGeneticsTerm(base);
}

/// 从权威 notes / 字段中探测是否含风险关键词（不自行推断）。
String? detectRiskPhrase(GeneticSimulationResult result) {
  final blobs = <String>[
    result.notes,
    result.predictionBasis ?? '',
    ...result.outcomes.map((o) => o.phenotypeLabel),
    ...result.outcomes.expand((o) => o.phenotype.values),
  ];
  for (final raw in blobs) {
    final lower = raw.toLowerCase();
    if (lower.contains('lethal') ||
        raw.contains('致死') ||
        lower.contains('anophthalmic') ||
        raw.contains('无眼')) {
      return humanizeGeneticsTerm(raw);
    }
  }
  return null;
}

/// 资料缺失计数：父母表型/基因型一侧空。
int countMissingParentFields(GeneticSimulationResult result) {
  var n = 0;
  final sirePh = (result.sirePhenotype ?? result.sire['phenotype'] ?? '').trim();
  final damPh = (result.damPhenotype ?? result.dam['phenotype'] ?? '').trim();
  if (sirePh.isEmpty && result.sire.isEmpty) n++;
  if (damPh.isEmpty && result.dam.isEmpty) n++;
  if (result.outcomes.isEmpty) n++;
  return n;
}

/// L1：只套 3.2 五句模板。
GeneticsConclusion buildGeneticsConclusion(
  GeneticSimulationResult result, {
  String? kinshipLabel,
}) {
  final risk = detectRiskPhrase(result);
  if (risk != null && risk.isNotEmpty) {
    final short = risk.length > 10 ? '遗传风险' : risk;
    return GeneticsConclusion(
      tone: GeneticsConclusionTone.red,
      line: '不要配：可能出现 $short',
    );
  }
  if (kinshipLabel != null && kinshipLabel.trim().isNotEmpty) {
    return GeneticsConclusion(
      tone: GeneticsConclusionTone.orange,
      line: '血缘太近（${kinshipLabel.trim()}），不建议',
    );
  }
  final missing = countMissingParentFields(result);
  if (missing > 0 || result.outcomes.isEmpty) {
    final n = missing < 1 ? 1 : missing;
    return GeneticsConclusion(
      tone: GeneticsConclusionTone.yellow,
      line: '能配，但有 $n 项资料缺失，结果只能算参考',
    );
  }
  final kinds = result.outcomes.map((o) => o.phenotypeLabel).toSet().length;
  final most = mostLikelyOutcome(result.outcomes);
  if (kinds <= 1 && most != null) {
    return GeneticsConclusion(
      tone: GeneticsConclusionTone.green,
      line: '这一配没问题，宝宝大概率是「${most.phenotypeLabel}」',
    );
  }
  return GeneticsConclusion(
    tone: GeneticsConclusionTone.blue,
    line: '这一配能配，会出 $kinds 种毛色',
  );
}

/// 父母主行：人话名 · 毛色；副行才是基因型代码。
({String title, String? subtitle}) formatParentHeadline({
  String? name,
  String? sexLabel,
  String? phenotypeLabel,
  Map<String, String>? genotype,
}) {
  final ph = displayPhenotypeLabel(phenotypeLabel);
  final sex = (sexLabel == null || sexLabel.isEmpty) ? '' : sexLabel;
  final who = (name == null || name.trim().isEmpty)
      ? (sex.isEmpty ? '未命名' : sex)
      : (sex.isEmpty ? name.trim() : '${name.trim()}（$sex）');
  final title = ph == GeneticsUiCopy.notRegistered ? who : '$who · $ph';
  String? sub;
  if (genotype != null && genotype.isNotEmpty) {
    final keys = genotype.keys.toList()..sort();
    // 表型表路径的 phenotype= 键不当主展示，仍进 L4。
    final parts = <String>[];
    for (final k in keys) {
      if (k == 'phenotype' || k == 'series' || k == 'fraction') continue;
      parts.add('${genotype[k]}');
    }
    if (parts.isEmpty && genotype['phenotype'] != null) {
      // 无位点时副行不放英文 phenotype 字样
      sub = null;
    } else if (parts.isNotEmpty) {
      sub = parts.join(' ');
    }
  }
  return (title: title, subtitle: sub);
}

/// 谱系关系口语（P1 可复用）。
String humanPedigreeRelation(String raw) {
  final t = raw.trim().toLowerCase();
  return switch (t) {
    'sire' || 'father' || '父' || '爸' => '爸爸',
    'dam' || 'mother' || '母' || '妈' => '妈妈',
    'paternal_grandfather' || '祖父' => '爷爷',
    'maternal_grandmother' || '外祖母' => '外婆',
    'paternal_grandmother' || '祖母' => '奶奶',
    'maternal_grandfather' || '外祖父' => '外公',
    'full_sib' || 'littermate' || '同窝' => '同窝',
    'half_sib' || 'half-sib' => '同父异母',
    'offspring' || 'child' || '仔' => '孩子',
    _ => humanMissing(raw),
  };
}
