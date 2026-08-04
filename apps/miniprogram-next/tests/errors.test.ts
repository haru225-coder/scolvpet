import { describe, expect, it } from 'vitest'

import { formatNetworkError, unwrapRequestError } from '../src/api/errors'
import config from '../src/utils/config'

describe('网络错误解包', () => {
  const apiHost = String((config as { API_BASE?: string }).API_BASE || '')

  it('展开 FetchError.cause 里的微信域名错误（客户句 + dev 尾）', () => {
    const root = new Error('request:fail url not in domain list')
    const wrapped = new Error('The request failed and the interceptors did not return an alternative response')
    ;(wrapped as Error & { cause?: Error }).cause = root
    const text = formatNetworkError(wrapped)
    expect(text).toContain('连不上服务器')
    // development 包才挂技术尾，且不再出现「底层 / OpenAPI / 公众平台」
    expect(text).not.toContain('底层')
    expect(text).not.toMatch(/OpenAPI/i)
    expect(text).not.toContain('微信公众平台')
    if (String((config as { APP_ENV?: string }).APP_ENV) === 'development') {
      expect(text).toContain(apiHost || 'pet.scolv.com')
    }
    expect(unwrapRequestError(wrapped)).toContain('url not in domain list')
  })

  it('interceptor 英文单独出现时人话化，不写 OpenAPI', () => {
    const text = formatNetworkError(
      new Error('The request failed and the interceptors did not return an alternative response')
    )
    expect(text).toContain('网络请求失败')
    expect(text).not.toMatch(/OpenAPI/i)
    expect(text).not.toContain('底层')
  })

  it('优先展示服务端中文 error.message', async () => {
    const { formatUserError, extractApiMessageSync } = await import('../src/api/errors')
    const body = { error: { code: 'STATE_ERROR', message: '只有 pair_ready 状态的繁育计划可以开始配对' } }
    expect(extractApiMessageSync({ data: body })).toContain('pair_ready')
    const err = {
      name: 'ResponseError',
      message: 'Response returned an error code',
      response: {
        json: async () => body,
        clone: () => ({ json: async () => body })
      }
    }
    const text = await formatUserError(err, '操作失败')
    expect(text).toContain('只有 pair_ready')
  })

  it('notifyUserError / presentUserMessage 导出且不截半句依赖 toast', async () => {
    const { notifyUserError, presentUserMessage } = await import('../src/api/errors')
    expect(typeof notifyUserError).toBe('function')
    expect(typeof presentUserMessage).toBe('function')
    // 桩环境无 UI，只要求不抛
    await presentUserMessage('短句')
    await presentUserMessage('这是一句超过三十六字的长错误说明，必须走 modal 而不是 toast 截断半句。')
  })
})
