import { describe, expect, it } from 'vitest'
import { WeightRecordCreateRequestToJSON } from '@scolvpet/api-client'
import { createTaroFetch, type RequestFn } from '../src/api/taro-fetch'
import { buildConfiguration, getApiToken, idempotencyMiddleware, setApiToken } from '../src/api/client'
import { getCustomerAccessToken, setCustomerAccessToken } from '../src/api/customer-client'

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

  it('收敛生成客户端历史路径中的重复 /v1', async () => {
    const { calls, fn } = capturingRequest()
    await createTaroFetch(fn)('https://api.example/v1/v1/public-site')
    expect(calls[0].url).toBe('https://api.example/v1/public-site')
  })

  it('保留非字符串 request body，并提供完整的 headers/clone/blob 语义', async () => {
    const body = new Uint8Array([123, 125]).buffer
    const { calls, fn } = capturingRequest({
      data: body,
      header: { 'Content-Type': 'application/octet-stream', 'X-Trace': 'trace-1' }
    })
    const fetchApi = createTaroFetch(fn)
    const response = await fetchApi('https://api.example/v1/binary', { method: 'POST', body: body as never })

    expect(calls[0].data).toBe(body)
    expect(response.headers.entries()).toEqual([
      ['content-type', 'application/octet-stream'],
      ['x-trace', 'trace-1']
    ])
    expect([...response.headers]).toEqual([
      ['content-type', 'application/octet-stream'],
      ['x-trace', 'trace-1']
    ])
    expect(response.headers.keys()).toEqual(['content-type', 'x-trace'])
    expect(response.headers.values()).toEqual(['application/octet-stream', 'trace-1'])
    const clone = response.clone()
    expect(clone).not.toBe(response)
    await expect(response.blob()).resolves.toBeInstanceOf(Blob)
  })
})

describe('generated correction contract', () => {
  it('体重纠错字段按 snake_case 写出', () => {
    expect(
      WeightRecordCreateRequestToJSON({
        hamsterId: 'h1',
        weightG: 118,
        recordedAt: new Date('2026-08-19T00:00:00Z'),
        source: 'manual',
        correctsWeightRecordId: 'w1',
        correctionReason: '看错秤'
      } as never)
    ).toMatchObject({
      hamster_id: 'h1',
      corrects_weight_record_id: 'w1',
      correction_reason: '看错秤'
    })
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

describe('customer API token isolation', () => {
  it('客户 token 不会写入繁育者 API client', () => {
    setApiToken('breeder-token')
    setCustomerAccessToken('ct_customer_token')

    expect(getApiToken()).toBe('breeder-token')
    expect(getCustomerAccessToken()).toBe('ct_customer_token')

    setApiToken('')
    setCustomerAccessToken('')
  })
})
