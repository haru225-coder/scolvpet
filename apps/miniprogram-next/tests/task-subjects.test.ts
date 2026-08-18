import { describe, expect, it } from 'vitest'

import {
  MAX_TODAY_SUBJECT_FETCHES,
  buildSubjectMap,
  collectTaskSubjectRefs,
  unwrapSubjectRecord
} from '../src/utils/task-subjects'

describe('今日任务主体只拉用到的', () => {
  it('按 targetType 拆仓鼠和窝次，丢掉 custom', () => {
    const refs = collectTaskSubjectRefs([
      { targetType: 'hamster', targetId: 'h1', subjectIds: ['h1', 'h2'] },
      { targetType: 'litter', target_id: 'L1' },
      { targetType: 'custom', targetId: 'custom' }
    ])
    expect(refs.hamsterIds.sort()).toEqual(['h1', 'h2'])
    expect(refs.litterIds).toEqual(['L1'])
  })

  it('unwrap 兼容 envelope 和 litter 包一层', () => {
    expect(unwrapSubjectRecord({ data: { id: 'h1', name: '哈豆' } })?.name).toBe('哈豆')
    expect(unwrapSubjectRecord({ data: { litter: { id: 'L1' } } })?.id).toBe('L1')
    expect(unwrapSubjectRecord({})).toBeNull()
  })

  it('buildSubjectMap 跳过空记录', () => {
    expect(buildSubjectMap([{ id: 'h1' }], [null, { id: 'L1' }])).toEqual({
      h1: { id: 'h1' },
      L1: { id: 'L1' }
    })
  })

  it('点查数量封顶，避免任务很多时打爆', () => {
    const refs = collectTaskSubjectRefs(
      Array.from({ length: 20 }, (_, index) => ({
        targetType: 'hamster',
        targetId: `h${index}`
      }))
    )
    expect(refs.hamsterIds).toHaveLength(MAX_TODAY_SUBJECT_FETCHES)
    expect(refs.litterIds).toEqual([])
  })
})
