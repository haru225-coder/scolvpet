import { describe, expect, it } from 'vitest'

import { filterCategoriesForEntryType } from '../src/packages/finance/create'
import { buildReversalDraft } from '../src/utils/finance-reversal'

describe('记账分类联动', () => {
  it('只展示与收支类型一致的分类', () => {
    const categories = [
      { id: 'expense-1', entryType: 'expense' },
      { id: 'income-1', entryType: 'income' }
    ]
    expect(filterCategoriesForEntryType(categories, 'expense')).toEqual([categories[0]])
    expect(filterCategoriesForEntryType(categories, 'income')).toEqual([categories[1]])
  })
})

describe('记账冲销草稿', () => {
  it('收入冲成等额支出，标题带冲销', () => {
    expect(buildReversalDraft({ id: 'a1', title: '订金', amountCents: 15000, entryType: 'income' })).toEqual({
      title: '冲销：订金',
      amount: '150.00',
      entryType: 'expense',
      notes: '冲销原记录 a1'
    })
  })

  it('无效金额拒绝', () => {
    expect(() => buildReversalDraft({ title: '空', amountCents: 0, entryType: 'expense' })).toThrow(/金额/)
  })
})
