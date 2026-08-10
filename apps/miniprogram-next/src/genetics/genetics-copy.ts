/**
 * 遗传 / 繁育模拟 · 展示层人话（只读权威结果，不重算）。
 * 对照任务书 L1–L4；权威代码仅 L4。
 */

export const GeneticsUiCopy = {
  pageTitle: '试配模拟',
  entryCta: '开始试配',
  runCta: '试配一下',
  emptyHint: '选好公、母的样子，点「试配一下」看结果',
  resultHeading: '模拟结果',
  professionalSectionTitle: '专业信息（基因型）',
  savePlanCta: '（已停用）存成繁育计划',
  missingData: '资料不足，算不准',
  notRegistered: '没登记',
  riskBanner: '这一配有风险',
  fillDataCta: '去补资料'
} as const

export type GeneticsConclusionTone = 'green' | 'blue' | 'yellow' | 'orange' | 'red'

export type GeneticsConclusion = { tone: GeneticsConclusionTone; line: string }

export function formatGeneticsPercent(probability: number): string {
  const p = Math.min(1, Math.max(0, Number(probability) || 0))
  return `${Math.round(p * 100)}%`
}

export function formatAboutNInM(probability: number): string {
  const p = Math.min(1, Math.max(0, Number(probability) || 0))
  if (p <= 0) return '约不会出现'
  if (p >= 0.999) return '约每只都会'
  for (let n = 2; n <= 12; n += 1) {
    const m = Math.round(p * n)
    if (m < 1) continue
    if (Math.abs(m / n - p) <= 0.03) return `约 ${n} 只里 ${m} 只`
  }
  const m = Math.min(4, Math.max(1, Math.round(p * 4)))
  return `约 4 只里 ${m} 只`
}

export function humanMissing(value: unknown): string {
  if (value == null) return GeneticsUiCopy.notRegistered
  const s = String(value).trim()
  if (!s || s === '--' || s === '-' || ['null', 'unknown', 'undefined'].includes(s.toLowerCase())) {
    return GeneticsUiCopy.notRegistered
  }
  return s
}

/** 与 docs/product/遗传术语人话对照表.md 同步；波利色不替换主名。 */
export const geneticsTermDisplayTable: Record<string, string> = {
  刺鼠: '刺鼠',
  黑: '黑',
  黑系: '黑系',
  肉桂: '肉桂',
  有色: '有色',
  白化: '白化',
  phenotype: '看得见的样子',
  表型: '看得见的样子',
  genotype: '基因型',
  基因型: '基因型',
  punnett: '配对表',
  'punnett square': '配对表',
  'homozygous lethal': '这种搭配可能生出活不下来的宝宝',
  carrier: '自己不显，但会传给宝宝',
  携带者: '自己不显，但会传给宝宝',
  杂合携带: '自己不显，但会传给宝宝',
  'anophthalmic white': '可能生出没有眼睛的宝宝',
  anophthalmic: '可能生出没有眼睛的宝宝',
  无眼白: '可能生出没有眼睛的宝宝',
  'half-sib': '同父异母 / 同母异父',
  halfsib: '同父异母 / 同母异父',
  coi: '它们是亲兄妹级的近亲',
  inbreeding: '它们是亲兄妹级的近亲',
  近交系数: '它们是亲兄妹级的近亲'
}

export function isLockedPoliPhenotypeLabel(raw: string): boolean {
  return String(raw || '').trim().includes('波利')
}

export function humanizeGeneticsTerm(raw: string): string {
  const t = String(raw || '').trim()
  if (!t) return GeneticsUiCopy.notRegistered
  if (isLockedPoliPhenotypeLabel(t)) return t
  const exact = geneticsTermDisplayTable[t] || geneticsTermDisplayTable[t.toLowerCase()]
  if (exact) return exact
  const lower = t.toLowerCase()
  if (lower.includes('homozygous lethal') || (lower.includes('lethal') && lower.includes('homozyg')) || t.includes('致死')) {
    return geneticsTermDisplayTable['homozygous lethal']
  }
  if (lower.includes('anophthalmic') || t.includes('无眼')) {
    return geneticsTermDisplayTable.anophthalmic
  }
  if (lower.includes('half-sib') || lower.includes('halfsib')) {
    return geneticsTermDisplayTable['half-sib']
  }
  if (lower.includes('coi') || lower.includes('inbreed') || t.includes('近交')) {
    return geneticsTermDisplayTable.coi
  }
  if (lower.includes('carrier') || t.includes('携带')) {
    return geneticsTermDisplayTable.carrier
  }
  if (lower === 'phenotype') return geneticsTermDisplayTable.phenotype
  if (lower === 'genotype') return geneticsTermDisplayTable.genotype
  if (lower.includes('punnett')) return geneticsTermDisplayTable.punnett
  // 未进表：权威中文表型原样直通
  return t
}

export function displayPhenotypeLabel(value: unknown): string {
  const base = humanMissing(value)
  if (base === GeneticsUiCopy.notRegistered) return base
  if (isLockedPoliPhenotypeLabel(base)) return base
  return humanizeGeneticsTerm(base)
}

type OutcomeLike = {
  phenotypeLabel?: string
  phenotype?: string
  probability?: number
  genotypeKey?: string
  genotype?: Record<string, string>
  carrierSummary?: string
  carrier_summary?: string
  genotypeBreakdown?: Array<{
    key?: string
    displayLabel?: string
    display_label?: string
    probability?: number
    carrierTags?: string[]
    carrier_tags?: string[]
  }>
  genotype_breakdown?: Array<{
    key?: string
    displayLabel?: string
    display_label?: string
    probability?: number
    carrierTags?: string[]
    carrier_tags?: string[]
  }>
}

type ResultLike = {
  notes?: string
  predictionBasis?: string
  sirePhenotype?: string
  damPhenotype?: string
  sire?: Record<string, string>
  dam?: Record<string, string>
  outcomes?: OutcomeLike[]
}

export function buildGeneticsConclusion(result: ResultLike, kinshipLabel?: string): GeneticsConclusion {
  const outcomes = result.outcomes || []
  const blobs = [result.notes, result.predictionBasis, ...outcomes.map((o) => o.phenotypeLabel || o.phenotype || '')]
  for (const raw of blobs) {
    const s = String(raw || '')
    const lower = s.toLowerCase()
    if (lower.includes('lethal') || s.includes('致死') || lower.includes('anophthalmic') || s.includes('无眼')) {
      return { tone: 'red', line: `不要配：可能出现 ${humanizeGeneticsTerm(s).slice(0, 12)}` }
    }
  }
  if (kinshipLabel && kinshipLabel.trim()) {
    return { tone: 'orange', line: `血缘太近（${kinshipLabel.trim()}），不建议` }
  }
  let missing = 0
  if (!String(result.sirePhenotype || result.sire?.phenotype || '').trim()) missing += 1
  if (!String(result.damPhenotype || result.dam?.phenotype || '').trim()) missing += 1
  if (!outcomes.length) missing += 1
  if (missing > 0 || !outcomes.length) {
    return { tone: 'yellow', line: `能配，但有 ${Math.max(1, missing)} 项资料缺失，结果只能算参考` }
  }
  const kinds = new Set(outcomes.map((o) => o.phenotypeLabel || o.phenotype || '')).size
  const ranked = [...outcomes].sort((a, b) => Number(b.probability || 0) - Number(a.probability || 0))
  const top = ranked[0]
  const topLabel = top?.phenotypeLabel || top?.phenotype || ''
  if (kinds <= 1 && topLabel) {
    return { tone: 'green', line: `这一配没问题，宝宝大概率是「${topLabel}」` }
  }
  return { tone: 'blue', line: `这一配能配，会出 ${kinds} 种毛色` }
}

/** 后端 prediction_basis → 用户可读依据。 */
export function humanizePredictionBasis(raw: unknown): string {
  const b = String(raw || '').trim()
  switch (b) {
    case 'authority_table':
      return '依据：权威表'
    case 'authority_table_plus_history':
      return '依据：权威表 + 历史窝次校准'
    case 'locus_model':
      return '依据：位点模型（表外补算）'
    case 'parent_genotype_posterior':
      return '依据：窝次反推亲本基因型'
    default:
      return b ? `依据：${b}` : '依据：未标明'
  }
}

export function decorateOutcomes(outcomes: OutcomeLike[]) {
  return (outcomes || []).map((o) => {
    const p = Number(o.probability || 0)
    const carrier = String(o.carrierSummary || o.carrier_summary || o.genotype?.carrier_summary || '').trim()
    const baseName = displayPhenotypeLabel(o.phenotypeLabel || o.phenotype)
    // Strip backend-appended carrier clause from phenotypeLabel for clean title
    const cleanName = baseName.includes(' · ') ? baseName.split(' · ')[0] : baseName
    const breakdown = o.genotypeBreakdown || o.genotype_breakdown || []
    const top = breakdown[0]
    const proKey =
      o.genotypeKey ||
      o.genotype?.top_genotype_key ||
      top?.key ||
      ''
    const aboutParts = [formatAboutNInM(p)]
    if (carrier) aboutParts.push(carrier)
    return {
      ...o,
      displayName: cleanName,
      percentLabel: formatGeneticsPercent(p),
      aboutLabel: aboutParts.join(' · '),
      carrierSummary: carrier,
      professionalKey: proKey,
      genotypeBreakdown: breakdown.map((g) => ({
        key: g.key || '',
        displayLabel: g.displayLabel || g.display_label || '',
        probability: Number(g.probability || 0),
        percentLabel: formatGeneticsPercent(Number(g.probability || 0)),
        carrierTags: g.carrierTags || g.carrier_tags || []
      }))
    }
  })
}
