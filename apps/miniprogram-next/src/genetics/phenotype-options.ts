/**
 * 试配选择器：同物异名合并 + 稳定展示顺序。
 * 与 geneticcore.NormalizePhenotypeLabel 对齐（chocolate 别名）。
 */

/** 展示用规范名（用户看到的）。 */
export function canonicalPhenotypeLabel(seriesCode: string, raw: string): string {
  const name = String(raw || '').trim()
  if (!name) return name
  if (seriesCode !== 'chocolate' && seriesCode !== '巧克力色系') return name
  switch (name) {
    case '巧克力色':
      return '巧克力'
    case '巧显斑':
      return '巧克力显斑'
    case '鸽灰':
      return '普通鸽灰'
    case '黑显斑':
      return '普通黑显斑'
    case '黑熊':
      return '普通黑熊'
    default:
      return name
  }
}

/** 副标题别名提示（规范名 → 其它叫法）。 */
export function phenotypeAliasHint(seriesCode: string, canonical: string): string {
  if (seriesCode !== 'chocolate' && seriesCode !== '巧克力色系') return ''
  switch (canonical) {
    case '巧克力':
      return '别名：巧克力色'
    case '巧克力显斑':
      return '别名：巧显斑'
    case '普通鸽灰':
      return '别名：鸽灰'
    case '普通黑显斑':
      return '别名：黑显斑'
    case '普通黑熊':
      return '别名：黑熊'
    default:
      return ''
  }
}

/** chocolate 选择器推荐顺序（规范名）。 */
const CHOCOLATE_ORDER = [
  '普通黑熊',
  '携巧黑熊',
  '巧克力',
  '香槟色',
  '普通鸽灰',
  '携巧鸽灰',
  '普通黑显斑',
  '携巧黑显斑',
  '巧克力显斑'
]

const POLY_ORDER = [
  '火波利',
  '肉桂波利',
  '黄波利',
  '黑波利',
  '蜜波利',
  '鸽灰波利',
  '黑黄波利',
  '黑蜜波利'
]

/**
 * 合并同义名后的选择列表（只保留规范名，顺序稳定）。
 */
export function dedupePhenotypeOptions(seriesCode: string, raw: unknown): string[] {
  const list = Array.isArray(raw) ? raw.map((x) => String(x || '').trim()).filter(Boolean) : []
  const code = String(seriesCode || '').trim()
  const seen = new Set<string>()
  for (const item of list) {
    seen.add(canonicalPhenotypeLabel(code, item))
  }
  const order =
    code === 'chocolate' || code === '巧克力色系'
      ? CHOCOLATE_ORDER
      : code === 'poly' || code === '波利系列'
        ? POLY_ORDER
        : []
  const out: string[] = []
  for (const name of order) {
    if (seen.has(name)) {
      out.push(name)
      seen.delete(name)
    }
  }
  // 剩余（未知系列或新增名）按字典序
  const rest = [...seen].sort((a, b) => a.localeCompare(b, 'zh-Hans'))
  return out.concat(rest)
}

/** 波利表型-only 时的假设说明（与后端默认杂合一致）。 */
export function phenotypeModeAssumptionNote(seriesCode: string, hasExactGenotype: boolean): string {
  if (hasExactGenotype) return '本轮使用了精确基因型（多代续推）'
  const code = String(seriesCode || '')
  if (code === 'poly' || code === '波利系列') {
    return '只选样子时：波利非隐性位点按杂合假设（与权威表构造一致）'
  }
  if (code === 'chocolate' || code === '巧克力色系') {
    return '只选样子时：按目录默认基因型；表外配对由位点模型补算'
  }
  return '只选样子时：按表型推算；表内优先权威表'
}
