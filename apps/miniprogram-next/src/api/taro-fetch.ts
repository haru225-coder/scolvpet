// generated/ts/scolvpet-api(typescript-fetch)的 fetchApi 桥:用 Taro.request
// 实现 fetch 语义。业务代码禁止直接用 Taro.request / 手写 fetch 封装(docs/32 §4)。
import Taro from '@tarojs/taro'

type TaroRequestOption = {
  url: string
  method?: string
  header?: Record<string, string>
  data?: unknown
  timeout?: number
}

type TaroResponse = {
  statusCode: number
  data: unknown
  header: Record<string, string>
}

export type RequestFn = (option: TaroRequestOption) => Promise<TaroResponse>

class HeaderShim {
  private map: Record<string, string> = {}

  constructor(raw: Record<string, string> | undefined) {
    for (const [k, v] of Object.entries(raw || {})) this.map[k.toLowerCase()] = String(v)
  }

  get(name: string): string | null {
    return this.map[name.toLowerCase()] ?? null
  }

  has(name: string): boolean {
    return this.get(name) != null
  }

  forEach(callback: (value: string, key: string, parent: HeaderShim) => void) {
    for (const [key, value] of Object.entries(this.map)) callback(value, key, this)
  }

  entries(): Array<[string, string]> {
    return Object.entries(this.map)
  }

  keys(): string[] {
    return Object.keys(this.map)
  }

  values(): string[] {
    return Object.values(this.map)
  }

  [Symbol.iterator](): IterableIterator<[string, string]> {
    return this.entries()[Symbol.iterator]()
  }
}

function toResponse(res: TaroResponse, url: string): Response {
  const bodyText = async () => {
    if (typeof res.data === 'string') return res.data
    if (res.data instanceof ArrayBuffer) return new TextDecoder().decode(new Uint8Array(res.data))
    if (ArrayBuffer.isView(res.data)) return new TextDecoder().decode(new Uint8Array(res.data.buffer, res.data.byteOffset, res.data.byteLength))
    return JSON.stringify(res.data ?? null)
  }
  const blob = async () => {
    const type = new HeaderShim(res.header).get('content-type') || ''
    if (res.data instanceof Blob) return res.data
    if (res.data instanceof ArrayBuffer || ArrayBuffer.isView(res.data)) return new Blob([res.data], { type })
    return new Blob([typeof res.data === 'string' ? res.data : JSON.stringify(res.data ?? null)], { type })
  }
  const shim = {
    url,
    status: res.statusCode,
    ok: res.statusCode >= 200 && res.statusCode < 300,
    statusText: String(res.statusCode),
    headers: new HeaderShim(res.header),
    json: async () =>
      typeof res.data === 'string' && res.data !== '' ? JSON.parse(res.data) : res.data,
    text: bodyText,
    blob,
    clone() {
      return toResponse(res, url)
    }
  }
  return shim as unknown as Response
}

/** 生成 fetchApi;requestFn 可注入用于测试,默认 Taro.request。 */
export function createTaroFetch(requestFn?: RequestFn) {
  const doRequest: RequestFn =
    requestFn ||
    ((option) =>
      new Promise((resolve, reject) => {
        Taro.request({
          ...option,
          method: (option.method || 'GET') as never,
          success: (res) => resolve(res as TaroResponse),
          fail: (err) => reject(new Error((err && err.errMsg) || 'network error'))
        })
      }))

  return async function taroFetch(input: string | { toString(): string }, init?: RequestInit): Promise<Response> {
    const rawUrl = typeof input === 'string' ? input : input.toString()
    // OpenAPI 中历史 P1/P2 路径有一部分自带 /v1，而 Configuration
    // 统一 basePath 也带 /v1；与 Flutter ApiClient 同口径收敛为单个 /v1。
    const url = rawUrl.replace(/\/v1\/v1\//g, '/v1/')
    const headers = (init?.headers || {}) as Record<string, string>
    const body = init?.body
    const res = await doRequest({
      url,
      method: (init?.method || 'GET').toUpperCase(),
      header: headers,
      // typescript-fetch 传 JSON.stringify 后的 string;Taro 会按 content-type 处理
      data: body == null ? undefined : body
    })
    return toResponse(res, url)
  }
}
