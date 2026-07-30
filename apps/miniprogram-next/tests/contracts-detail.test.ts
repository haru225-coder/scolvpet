import { describe, expect, it } from 'vitest'

import { isDocumentVersionConflict } from '../src/packages/contracts/detail'

describe('合同详情冲突处理', () => {
  it('只把 HTTP 409 识别为 If-Match 冲突', () => {
    expect(isDocumentVersionConflict({ response: { status: 409 } })).toBe(true)
    expect(isDocumentVersionConflict({ response: { status: 401 } })).toBe(false)
    expect(isDocumentVersionConflict(new Error('network down'))).toBe(false)
  })
})
