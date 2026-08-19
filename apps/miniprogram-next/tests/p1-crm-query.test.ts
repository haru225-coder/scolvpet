import { describe, expect, it } from 'vitest'

import { fetchCrmListWithContact, unwrapCrmList, withContactIdQuery } from '../src/api/p1-crm-query'

describe('CRM 按客户拉列表', () => {
  it('空 id 不加 query，有 id 才补 contact_id', () => {
    expect(withContactIdQuery('/v1/crm/reservations', '')).toBe('/v1/crm/reservations')
    expect(withContactIdQuery('/v1/crm/reservations', 'c1')).toBe('/v1/crm/reservations?contact_id=c1')
    expect(withContactIdQuery('/v1/crm/reservations?limit=10', 'c1')).toBe(
      '/v1/crm/reservations?limit=10&contact_id=c1'
    )
  })

  it('unwrap 只收数组', () => {
    expect(unwrapCrmList({ data: [{ id: 'a' }] })).toEqual([{ id: 'a' }])
    expect(unwrapCrmList({ data: null })).toEqual([])
  })

  it('请求 URL 带 contact_id，并把 data 解开', async () => {
    const seen: string[] = []
    const rows = await fetchCrmListWithContact(
      { path: '/v1/crm/reservations', headers: { Authorization: 'Bearer t' } },
      'c1',
      async (url, init) => {
        seen.push(url)
        expect(init.headers).toMatchObject({ Authorization: 'Bearer t' })
        return {
          ok: true,
          json: async () => ({ data: [{ id: 'r1', contact_id: 'c1' }] })
        } as Response
      },
      'https://pet.scolv.com/v1'
    )
    expect(seen).toEqual(['https://pet.scolv.com/v1/v1/crm/reservations?contact_id=c1'])
    expect(rows).toEqual([{ id: 'r1', contact_id: 'c1' }])
  })
})
