import { afterEach, describe, expect, it, vi } from 'vitest'

import { p1CrmApi } from '../src/api/client'
import { loadCrmListItems } from '../src/packages/crm/index'

afterEach(() => vi.restoreAllMocks())

describe('CRM 首页读取', () => {
  it('一个数据集读取失败时仍展示其余成功记录', async () => {
    vi.spyOn(p1CrmApi, 'listCrmContacts').mockRejectedValue(new Error('contacts unavailable'))
    vi.spyOn(p1CrmApi, 'listCrmReservations').mockResolvedValue({ data: [{ id: 'reservation-1', title: '待确认预订', status: 'held' }] } as never)
    vi.spyOn(p1CrmApi, 'listCrmHandovers').mockResolvedValue({ data: [{ id: 'handover-1', status: 'scheduled' }] } as never)

    await expect(loadCrmListItems()).resolves.toMatchObject([
      { id: 'reservation-reservation-1', title: '待确认预订' },
      { id: 'handover-handover-1', title: '交付事项' }
    ])
  })

  it('三个数据集都不可读取时才整体报错', async () => {
    vi.spyOn(p1CrmApi, 'listCrmContacts').mockRejectedValue(new Error('contacts unavailable'))
    vi.spyOn(p1CrmApi, 'listCrmReservations').mockRejectedValue(new Error('reservations unavailable'))
    vi.spyOn(p1CrmApi, 'listCrmHandovers').mockRejectedValue(new Error('handovers unavailable'))

    await expect(loadCrmListItems()).rejects.toThrow('客户数据读取失败')
  })
})
