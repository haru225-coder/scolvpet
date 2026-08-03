/**
 * OpenAPI typescript-fetch 在 Taro.request fail 时会包成：
 * FetchError: "The request failed and the interceptors did not return an alternative response"
 * 真正原因在 error.cause（微信 errMsg，如 url not in domain list）。
 * 真机与开发者工具差异几乎都出在这里：工具可关域名校验，真机永远校验。
 */
import config from '../utils/config'

/** 与 config.API_BASE 一致，提示用户时别写死 staging 别名。 */
function apiBaseDisplay(): string {
  const base = String((config as { API_BASE?: string }).API_BASE || 'https://pet.scolv.com').replace(/\/$/, '')
  return base
}

export function unwrapRequestError(error: unknown): string {
  const parts: string[] = []
  let current: unknown = error
  for (let depth = 0; depth < 6 && current; depth += 1) {
    if (current instanceof Error) {
      const msg = String(current.message || '').trim()
      if (msg && !parts.includes(msg)) parts.push(msg)
      current = (current as Error & { cause?: unknown }).cause
      continue
    }
    const text = String(current || '').trim()
    if (text && !parts.includes(text)) parts.push(text)
    break
  }
  return parts.join(' · ') || '未知网络错误'
}

/** 把网络/域名错误翻成可操作的中文。 */
export function formatNetworkError(error: unknown, fallback = '请求失败') {
  const raw = unwrapRequestError(error)
  const lower = raw.toLowerCase()
  const api = apiBaseDisplay()

  if (
    lower.includes('url not in domain list') ||
    raw.includes('不在以下 request 合法域名') ||
    raw.includes('合法域名列表') ||
    (lower.includes('domain') && lower.includes('list'))
  ) {
    return (
      '真机请求被微信「合法域名」拦住了（开发者工具能进、真机不能进就是这个）。\n' +
      '请打开：微信公众平台 → 开发 → 开发管理 → 服务器域名 → request 合法域名，\n' +
      `填：${api}（要 https://，不要端口、不要路径），必须与小程序 API_BASE 一致。\n` +
      `当前包请求的是 ${api}。\n` +
      `底层：${raw}`
    )
  }

  if (
    lower.includes('ssl') ||
    lower.includes('certificate') ||
    lower.includes('tls') ||
    raw.includes('证书')
  ) {
    return `HTTPS/证书校验失败。确认手机能打开 ${api}/readyz 。底层：${raw}`
  }

  if (
    lower.includes('timeout') ||
    lower.includes('timed out') ||
    lower.includes('connect') ||
    lower.includes('failed to connect') ||
    raw.includes('超时')
  ) {
    return `连不上服务器。确认手机网络可访问 ${api} 。底层：${raw}`
  }

  // OpenAPI 包装文案单独拆掉，避免用户只看到 interceptor 英文
  if (raw.includes('interceptors did not return an alternative response')) {
    const root = raw
      .replace(/The request failed and the interceptors did not return an alternative response/gi, '')
      .replace(/^[\s·|:-]+|[\s·|:-]+$/g, '')
    if (root) return formatNetworkError(new Error(root), fallback)
    return (
      `网络请求失败（OpenAPI 包装错误）。真机请确认 request 合法域名与 API 一致：${api}\n` +
      `底层：${raw}`
    )
  }

  return raw || fallback
}
