import { describe, expect, it } from 'vitest'

import { filterCategoriesForEntryType } from '../src/packages/finance/create'

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
