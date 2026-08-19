import { describe, expect, it, vi } from 'vitest'

import { p1CrmApi } from '../src/api/client'
import { loadCrmDetail } from '../src/packages/crm/detail'
import {
  handoverCanComplete,
  reservationCanCancel,
  reservationCanConfirm,
  reservationStatusNote,
  rowsForContact
} from '../src/utils/crm-status'

describe('CRM 详情读取', () => {
  it('按记录类型读取生成客户端详情，不再并发拉取三个列表', async () => {
    const getContact = vi.spyOn(p1CrmApi, 'getCrmContact').mockResolvedValue({ data: { id: 'contact-1' } } as never)
    const getReservation = vi.spyOn(p1CrmApi, 'getCrmReservation').mockResolvedValue({ data: { id: 'reservation-1' } } as never)
    const getHandover = vi.spyOn(p1CrmApi, 'getCrmHandover').mockResolvedValue({ data: { id: 'handover-1' } } as never)

    await expect(loadCrmDetail('contact', 'contact-1')).resolves.toMatchObject({ data: { id: 'contact-1' } })
    await expect(loadCrmDetail('reservation', 'reservation-1')).resolves.toMatchObject({ data: { id: 'reservation-1' } })
    await expect(loadCrmDetail('handover', 'handover-1')).resolves.toMatchObject({ data: { id: 'handover-1' } })

    expect(getContact).toHaveBeenCalledWith({ contactId: 'contact-1' })
    expect(getReservation).toHaveBeenCalledWith({ reservationId: 'reservation-1' })
    expect(getHandover).toHaveBeenCalledWith({ handoverId: 'handover-1' })
  })
})

describe('CRM 状态按钮', () => {
  it('held 可确认可取消，cancelled 都不能恢复', () => {
    expect(reservationCanConfirm('held')).toBe(true)
    expect(reservationCanCancel('held')).toBe(true)
    expect(reservationCanConfirm('cancelled')).toBe(false)
    expect(reservationCanCancel('cancelled')).toBe(false)
    expect(reservationStatusNote('cancelled')).toContain('不能恢复')
  })

  it('只有 scheduled 交付能完成', () => {
    expect(handoverCanComplete('scheduled')).toBe(true)
    expect(handoverCanComplete('completed')).toBe(false)
  })

  it('客户详情只留这位客户的预订/交付，并封顶', () => {
    expect(
      rowsForContact(
        [
          { id: 'a', contactId: 'c1' },
          { id: 'b', contact_id: 'c2' },
          { id: 'c', contact_id: 'c1' }
        ],
        'c1'
      ).map((item) => item.id)
    ).toEqual(['a', 'c'])
    expect(rowsForContact(Array.from({ length: 30 }, (_, i) => ({ contactId: 'c1', id: String(i) })), 'c1')).toHaveLength(20)
  })
})
