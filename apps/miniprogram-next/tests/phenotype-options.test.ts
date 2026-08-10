import { describe, expect, it } from 'vitest'

import {
  canonicalPhenotypeLabel,
  dedupePhenotypeOptions,
  phenotypeAliasHint,
  phenotypeModeAssumptionNote
} from '../src/genetics/phenotype-options'

describe('phenotype-options', () => {
  it('merges chocolate synonyms into canonical labels', () => {
    expect(canonicalPhenotypeLabel('chocolate', '巧克力色')).toBe('巧克力')
    expect(canonicalPhenotypeLabel('chocolate', '巧显斑')).toBe('巧克力显斑')
    expect(canonicalPhenotypeLabel('chocolate', '黑熊')).toBe('普通黑熊')
    expect(canonicalPhenotypeLabel('poly', '蜜波利')).toBe('蜜波利')
  })

  it('dedupes catalog list to 9 chocolate entries', () => {
    const raw = [
      '巧克力',
      '巧克力色',
      '巧显斑',
      '巧克力显斑',
      '普通黑熊',
      '黑熊',
      '携巧黑熊',
      '香槟色',
      '普通鸽灰',
      '鸽灰',
      '携巧鸽灰',
      '普通黑显斑',
      '黑显斑',
      '携巧黑显斑'
    ]
    const got = dedupePhenotypeOptions('chocolate', raw)
    expect(got).toEqual([
      '普通黑熊',
      '携巧黑熊',
      '巧克力',
      '香槟色',
      '普通鸽灰',
      '携巧鸽灰',
      '普通黑显斑',
      '携巧黑显斑',
      '巧克力显斑'
    ])
    expect(got).toHaveLength(9)
  })

  it('alias hint only for canonical names that have synonyms', () => {
    expect(phenotypeAliasHint('chocolate', '巧克力')).toContain('巧克力色')
    expect(phenotypeAliasHint('chocolate', '携巧黑熊')).toBe('')
  })

  it('assumption note differs for exact genotype vs phenotype-only', () => {
    expect(phenotypeModeAssumptionNote('poly', false)).toContain('杂合')
    expect(phenotypeModeAssumptionNote('poly', true)).toContain('精确基因型')
    expect(phenotypeModeAssumptionNote('chocolate', false)).toContain('模型')
  })
})
