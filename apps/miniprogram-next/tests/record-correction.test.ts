import { describe, expect, it } from 'vitest'

import {
  buildCreateParentageBody,
  buildEndParentageBody,
  buildTaskCorrectionRequest,
  buildWeightCorrectionRequest,
  parentRoleFromCard,
  requireCorrectionReason
} from '../src/utils/record-correction'

describe('族谱纠错载荷', () => {
  it('只把父母行映射成 sire/dam', () => {
    expect(parentRoleFromCard('爸爸')).toBe('sire')
    expect(parentRoleFromCard('妈妈')).toBe('dam')
    expect(parentRoleFromCard('爷爷')).toBeNull()
  })

  it('解除必须带原因', () => {
    expect(buildEndParentageBody({
      childHamsterId: 'child-1',
      role: 'sire',
      correctionReason: ' 登记错了 '
    })).toEqual({
      childHamsterId: 'child-1',
      role: 'sire',
      correctionReason: '登记错了'
    })
  })

  it('替换已有父母时带 correctionReason', () => {
    const body = buildCreateParentageBody({
      childHamsterId: 'child-1',
      parentHamsterId: 'dad-2',
      role: 'sire',
      correctionReason: '换成真正的父本'
    })
    expect(body.correctionReason).toBe('换成真正的父本')
    expect(body.evidenceType).toBe('manual')
  })
})

describe('体重纠错载荷', () => {
  it('追加记录不带 corrects 字段', () => {
    const body = buildWeightCorrectionRequest({ hamsterId: 'h1', weightG: 120 })
    expect(body.correctsWeightRecordId).toBeUndefined()
    expect(body.correctionReason).toBeUndefined()
  })

  it('纠错缺原因直接拒绝，避免 422', () => {
    expect(() =>
      buildWeightCorrectionRequest({
        hamsterId: 'h1',
        weightG: 118,
        correctsWeightRecordId: 'w1',
        correctionReason: '   '
      })
    ).toThrow(/原因/)
  })

  it('纠错带原记录 id 和原因', () => {
    const body = buildWeightCorrectionRequest({
      hamsterId: 'h1',
      weightG: 118,
      notes: '手滑',
      correctsWeightRecordId: 'w1',
      correctionReason: '看错秤'
    })
    expect(body.correctsWeightRecordId).toBe('w1')
    expect(body.correctionReason).toBe('看错秤')
  })

  it('空原因抛错', () => {
    expect(() => requireCorrectionReason(' ')).toThrow(/原因/)
  })
})

describe('任务纠错原因', () => {
  it('跳过/恢复必须手写原因，不再用固定文案', () => {
    expect(buildTaskCorrectionRequest('今天来不及')).toEqual({ reason: '今天来不及' })
    expect(() => buildTaskCorrectionRequest('  ')).toThrow(/原因/)
  })
})
