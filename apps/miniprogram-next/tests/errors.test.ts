import { describe, expect, it } from 'vitest'

import { formatNetworkError, unwrapRequestError } from '../src/api/errors'
import config from '../src/utils/config'

describe('网络错误解包', () => {
  const apiHost = String((config as { API_BASE?: string }).API_BASE || '')

  it('展开 FetchError.cause 里的微信域名错误', () => {
    const root = new Error('request:fail url not in domain list')
    const wrapped = new Error('The request failed and the interceptors did not return an alternative response')
    ;(wrapped as Error & { cause?: Error }).cause = root
    const text = formatNetworkError(wrapped)
    expect(text).toContain('合法域名')
    expect(text).toContain(apiHost || 'pet.scolv.com')
    expect(unwrapRequestError(wrapped)).toContain('url not in domain list')
  })

  it('interceptor 英文单独出现时也给出域名指引', () => {
    const text = formatNetworkError(
      new Error('The request failed and the interceptors did not return an alternative response')
    )
    expect(text).toContain(apiHost || 'pet.scolv.com')
  })
})
