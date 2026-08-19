import { describe, expect, it } from 'vitest'

import { hamsterSearchLabel, searchHamsters, unwrapHamsterList } from '../src/utils/search-hamsters'

describe('个体搜索', () => {
  it('unwrap 兼容 data 数组和 items', () => {
    expect(unwrapHamsterList({ data: [{ id: 'h1' }] })).toEqual([{ id: 'h1' }])
    expect(unwrapHamsterList({ data: { items: [{ id: 'h2' }] } })).toEqual([{ id: 'h2' }])
    expect(unwrapHamsterList({})).toEqual([])
  })

  it('标签用名字加编号，不甩裸对象', () => {
    expect(hamsterSearchLabel({ name: '布丁', internalCode: 'A01' })).toBe('布丁 · A01')
    expect(hamsterSearchLabel({ id: 'x' })).toBe('x')
  })

  it('把 q/sex/limit 传给 listHamsters，并丢掉自己', async () => {
    const calls: unknown[] = []
    const hits = await searchHamsters(
      {
        listHamsters: async (req) => {
          calls.push(req)
          return {
            data: [
              { id: 'self', name: '自己' },
              { id: 'sire-1', name: '阿黑', sex: 'male' }
            ]
          }
        }
      },
      { q: '阿', sex: 'male', excludeId: 'self', limit: 20 }
    )
    expect(calls).toEqual([{ limit: 20, q: '阿', sex: 'male' }])
    expect(hits.map((item) => item.id)).toEqual(['sire-1'])
  })
})
