import { describe, expect, it } from 'vitest'

import { createIdempotencyIntent } from '../src/api/idempotency'

describe('业务意图幂等键', () => {
  it('失败重试复用 key，成功完成后才生成下一枚 key', () => {
    const intent = createIdempotencyIntent()
    const first = intent.getKey()
    expect(first).toMatch(/^mp-/)
    expect(intent.getKey()).toBe(first)
    intent.complete()
    expect(intent.getKey()).toMatch(/^mp-/)
    expect(intent.getKey()).not.toBe(first)
  })
})
