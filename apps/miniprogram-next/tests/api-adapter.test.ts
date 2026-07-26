import { describe, expect, it } from 'vitest'
import { createTaroFetch, type RequestFn } from '../src/api/taro-fetch'
import { buildConfiguration, idempotencyMiddleware, setApiToken } from '../src/api/client'

function capturingRequest(response?: Partial<{ statusCode: number; data: unknown; header: Record<string, string> }>) {
  const calls: Array<Parameters<RequestFn>[0]> = []
  const fn: RequestFn = async (option) => {
    calls.push(option)
    return {
      statusCode: response?.statusCode ?? 200,
      data: response?.data ?? { ok: true },
      header: response?.header ?? { 'Content-Type': 'application/json' }
    }
  }
  return { calls, fn }
}

describe('createTaroFetch', () => {
  it('把 fetch 语义映射为 Taro.request 参数', async () => {
    const { calls, fn } = capturingRequest()
    const fetchApi = createTaroFetch(fn)
    const res = await fetchApi('https://api.example/v1/things', {
      method: 'post',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ a: 1 })
    })
    expect(calls).toHaveLength(1)
    expect(calls[0].url).toBe('https://api.example/v1/things')
    expect(calls[0].method).toBe('POST')
    expect(calls[0].header?.['Content-Type']).toBe('application/json')
    expect(calls[0].data).toBe('{"a":1}')
    expect(res.status).toBe(200)
    expect(res.ok).toBe(true)
    await expect(res.json()).resolves.toEqual({ ok: true })
  })

  it('响应头大小写不敏感,非 2xx 标记 ok=false', async () => {
    const { fn } = capturingRequest({ statusCode: 404, data: { error: { message: 'not found' } } })
    const fetchApi = createTaroFetch(fn)
    const res = await fetchApi('https://api.example/v1/none')
    expect(res.ok).toBe(false)
    expect(res.status).toBe(404)
    expect(res.headers.get('content-type')).toBe('application/json')
  })
})

describe('idempotencyMiddleware', () => {
  it('写请求自动补 Idempotency-Key,读请求不加', async () => {
    const post = await idempotencyMiddleware.pre!({
      fetch: (() => {}) as never,
      url: 'https://api.example/v1/things',
      init: { method: 'POST', headers: {} }
    })
    expect((post!.init.headers as Record<string, string>)['Idempotency-Key']).toMatch(/^mp-/)

    const get = await idempotencyMiddleware.pre!({
      fetch: (() => {}) as never,
      url: 'https://api.example/v1/things',
      init: { method: 'GET', headers: {} }
    })
    expect((get!.init.headers as Record<string, string>)['Idempotency-Key']).toBeUndefined()
  })

  it('已有 Idempotency-Key 不覆盖', async () => {
    const out = await idempotencyMiddleware.pre!({
      fetch: (() => {}) as never,
      url: 'https://api.example/v1/things',
      init: { method: 'POST', headers: { 'Idempotency-Key': 'fixed-key' } }
    })
    expect((out!.init.headers as Record<string, string>)['Idempotency-Key']).toBe('fixed-key')
  })
})

describe('buildConfiguration', () => {
  it('basePath = API_BASE + /v1,accessToken 取当前 token', async () => {
    const cfg = buildConfiguration({ basePath: 'https://api.example' })
    expect(cfg.basePath).toBe('https://api.example/v1')
    setApiToken('tok-123')
    await expect(cfg.accessToken!('bearerAuth', [])).resolves.toBe('tok-123')
    setApiToken('')
  })
})
