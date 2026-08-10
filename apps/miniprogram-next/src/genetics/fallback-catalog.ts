/**
 * 服务端表型目录不可用时的内置兜底（与 geneticcore syrian_phenotype_table_v1 系列一致）。
 * 仅用于 UI 选择；真正模拟仍走 API。
 */

export type FallbackSeries = {
  code: string
  name: string
  phenotypes: string[]
}

export type FallbackCatalog = {
  title: string
  series: FallbackSeries[]
}

const FALLBACK: FallbackCatalog = {
  "title": "叙利亚仓鼠表型（内置兜底目录）",
  "series": [
    {
      "code": "poly",
      "name": "波利系列",
      "phenotypes": [
        "火波利",
        "肉桂波利",
        "蜜波利",
        "鸽灰波利",
        "黄波利",
        "黑波利",
        "黑蜜波利",
        "黑黄波利"
      ]
    },
    {
      "code": "chocolate",
      "name": "巧克力色系",
      // 规范名（同义名在选择器层合并；见 phenotype-options.ts）
      "phenotypes": [
        "普通黑熊",
        "携巧黑熊",
        "巧克力",
        "香槟色",
        "普通鸽灰",
        "携巧鸽灰",
        "普通黑显斑",
        "携巧黑显斑",
        "巧克力显斑"
      ]
    }
  ]
}

export function getFallbackPhenotypeCatalog(): FallbackCatalog {
  return {
    title: FALLBACK.title || '内置表型目录',
    series: Array.isArray(FALLBACK.series) ? FALLBACK.series.map((s) => ({
      code: String(s.code || ''),
      name: String(s.name || s.code || ''),
      phenotypes: Array.isArray(s.phenotypes) ? s.phenotypes.map(String) : []
    })) : []
  }
}
