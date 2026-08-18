import { describe, expect, it } from 'vitest'

import {
  animalDetailUrl,
  contactDetailUrl,
  handoverDetailUrl,
  requireCreatedId,
  reservationDetailUrl
} from '../src/utils/created-routes'

describe('创建后去详情', () => {
  it('有编号才拼详情路径', () => {
    expect(animalDetailUrl('h1')).toContain('id=h1')
    expect(contactDetailUrl('c1')).toContain('contact-c1')
    expect(reservationDetailUrl('r1')).toContain('reservation-r1')
    expect(handoverDetailUrl('d1')).toContain('handover-d1')
  })

  it('没编号拒绝，避免退回列表当成功', () => {
    expect(() => requireCreatedId(' ', '客户')).toThrow(/编号/)
  })
})
