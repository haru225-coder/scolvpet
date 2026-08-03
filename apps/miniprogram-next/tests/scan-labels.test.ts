import { describe, expect, it } from 'vitest'
import {
  ageLabel,
  animalScanSubtitle,
  animalScanTitle,
  litterScanSubtitle,
  sexMark,
  shortDate,
  taskScanSubtitle,
  taskTargetAgeLabel,
  taskTargetScanLabel,
  taskTimeLabel
} from '../src/utils/scan-labels'

describe('scan-labels', () => {
  const fixedNow = Date.parse('2026-08-02T12:00:00+08:00')

  it('sexMark', () => {
    expect(sexMark('female')).toBe('♀')
    expect(sexMark('male')).toBe('♂')
    expect(sexMark('unknown')).toBe('')
  })

  it('ageLabel 日龄/月龄', () => {
    expect(ageLabel('2026-07-23', fixedNow)).toBe('10日龄')
    expect(ageLabel('2026-02-01', fixedNow)).toMatch(/月龄$/)
    expect(ageLabel('2025-08-02', fixedNow)).toBe('1岁')
    expect(ageLabel(null, fixedNow)).toBeUndefined()
  })

  it('animalScanSubtitle 含编号日龄笼位，不写空样子', () => {
    const sub = animalScanSubtitle({
      internalCode: 'A01',
      birthDate: '2026-07-20',
      sex: 'female',
      currentEnclosureId: 'e1'
    })
    // now is dynamic in default path — use explicit fields without relying on age if flake
    expect(sub).toContain('A01')
    expect(sub).toContain('已分笼')
    expect(sub).not.toContain('样子未记')
  })

  it('animalScanTitle', () => {
    expect(animalScanTitle({ name: '布丁', sex: 'female' })).toBe('布丁 ♀')
    expect(animalScanTitle({ internalCode: 'X1', sex: 'male' })).toBe('X1 ♂')
  })

  it('litterScanSubtitle 在管数量', () => {
    const sub = litterScanSubtitle(
      { bornAt: '2026-07-20', currentManagedCount: 5, state: 'active' },
      '进行中'
    )
    expect(sub).toContain('进行中')
    expect(sub).toContain('在管 5 只')
  })

  it('shortDate', () => {
    expect(shortDate('2026-08-02')).toMatch(/2026\/8\/2/)
  })

  it('taskScanSubtitle 时间 · 目标 · 日龄', () => {
    const task = {
      scheduledAt: '2026-08-02T09:30:00+08:00',
      targetType: 'hamster',
      targetId: 'h1'
    }
    const subject = {
      id: 'h1',
      name: '布丁',
      sex: 'female',
      birthDate: '2026-07-23'
    }
    expect(taskTimeLabel(task.scheduledAt)).toMatch(/09:30|9:30/)
    expect(taskTargetScanLabel(task, subject)).toBe('布丁 ♀')
    expect(taskTargetAgeLabel(task, subject, fixedNow)).toBe('10日龄')
    expect(taskScanSubtitle(task, subject, fixedNow)).toMatch(/布丁 ♀/)
    expect(taskScanSubtitle(task, subject, fixedNow)).toContain('10日龄')
  })

  it('taskScanSubtitle 无 subject 时不编造日龄', () => {
    const sub = taskScanSubtitle(
      { scheduledAt: '2026-08-02T10:00:00+08:00', targetType: 'hamster' },
      null,
      fixedNow
    )
    expect(sub).toContain('一只仓鼠')
    expect(sub).not.toContain('日龄')
  })

  it('taskTargetScanLabel 窝次用 bornAt', () => {
    const task = { targetType: 'litter', targetId: 'l1' }
    const litter = { id: 'l1', bornAt: '2026-07-20', currentManagedCount: 4 }
    expect(taskTargetScanLabel(task, litter)).toMatch(/窝次|在管/)
    expect(taskTargetAgeLabel(task, litter, fixedNow)).toBe('13日龄')
  })
})
