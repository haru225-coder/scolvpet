/**
 * OpenAPI typescript-fetch 在 Taro.request fail 时会包成：
 * FetchError: "The request failed and the interceptors did not return an alternative response"
 * 真正原因在 error.cause（微信 errMsg，如 url not in domain list）。
 * 业务 4xx/5xx 则是 ResponseError，服务端中文在 body.error.message。
 *
 * 2026-08-05 4a：用户可见句去掉「底层 / OpenAPI / 公众平台操作说明书」；
 * 技术细节仅 development 追加。长文案用 notifyUserError → showModal。
 */
import Taro from '@tarojs/taro'

import config from '../utils/config'

/** 与 config.API_BASE 一致，提示用户时别写死 staging 别名。 */
function apiBaseDisplay(): string {
  const base = String((config as { API_BASE?: string }).API_BASE || 'https://pet.scolv.com').replace(/\/$/, '')
  return base
}

function isDevBuild(): boolean {
  return String((config as { APP_ENV?: string }).APP_ENV || '') === 'development'
}

/** development 才把原始 err 挂在句末，正式包不进客户眼睛。 */
function withDevTail(userLine: string, raw: string): string {
  if (!isDevBuild()) return userLine
  const tail = String(raw || '').trim()
  if (!tail || userLine.includes(tail)) return userLine
  return `${userLine}\n（开发）${tail.slice(0, 160)}`
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

function looksLikeEngineerNoise(text: string): boolean {
  const t = text.trim()
  if (!t) return true
  if (t.includes('interceptors did not return')) return true
  if (/^Response returned an error code$/i.test(t)) return true
  if (/^HTTP\s*\d{3}$/i.test(t)) return true
  if (/^fetch/i.test(t) && t.length < 40) return true
  return false
}

/**
 * 从 OpenAPI ResponseError 等对象里抽出服务端 error.message（中文优先）。
 * 同步：仅读已缓存/可同步拿到的字段；异步版见 formatUserError。
 */
export function extractApiMessageSync(error: unknown): string {
  if (!error || typeof error !== 'object') return ''
  const anyErr = error as {
    message?: unknown
    response?: { status?: number; _bodyInit?: unknown; data?: unknown }
    body?: unknown
    data?: unknown
  }
  const tryObj = (obj: unknown): string => {
    if (!obj || typeof obj !== 'object') return ''
    const o = obj as { error?: { message?: unknown }; message?: unknown }
    const nested = o.error && typeof o.error === 'object' ? (o.error as { message?: unknown }).message : undefined
    for (const cand of [nested, o.message]) {
      if (typeof cand === 'string' && cand.trim() && !looksLikeEngineerNoise(cand)) return cand.trim()
    }
    return ''
  }
  for (const bag of [anyErr.body, anyErr.data, anyErr.response?.data, anyErr.response?._bodyInit]) {
    const hit = tryObj(bag)
    if (hit) return hit
  }
  if (typeof anyErr.message === 'string' && !looksLikeEngineerNoise(anyErr.message)) {
    // 偶发 message 已是中文业务句
    if (/[\u4e00-\u9fff]/.test(anyErr.message)) return anyErr.message.trim()
  }
  return ''
}

/** 把网络/域名错误翻成可操作的中文。 */
export function formatNetworkError(error: unknown, fallback = '请求失败') {
  const apiMsg = extractApiMessageSync(error)
  if (apiMsg) return apiMsg

  const raw = unwrapRequestError(error)
  const lower = raw.toLowerCase()
  const api = apiBaseDisplay()

  if (
    lower.includes('url not in domain list') ||
    raw.includes('不在以下 request 合法域名') ||
    raw.includes('合法域名列表') ||
    (lower.includes('domain') && lower.includes('list'))
  ) {
    // 客户句：不写公众平台点选路径；开发再挂 tail
    return withDevTail(
      `暂时连不上服务器。请确认网络正常，或稍后再试。`,
      `合法域名/API：${api} · ${raw}`
    )
  }

  if (
    lower.includes('ssl') ||
    lower.includes('certificate') ||
    lower.includes('tls') ||
    raw.includes('证书')
  ) {
    return withDevTail('安全连接失败，请稍后重试。', raw)
  }

  if (
    lower.includes('timeout') ||
    lower.includes('timed out') ||
    lower.includes('connect') ||
    lower.includes('failed to connect') ||
    raw.includes('超时')
  ) {
    return withDevTail('连不上服务器，请检查网络后重试。', raw)
  }

  // 拆掉 interceptor 英文包装，不出现「OpenAPI」字样
  if (raw.includes('interceptors did not return an alternative response')) {
    const root = raw
      .replace(/The request failed and the interceptors did not return an alternative response/gi, '')
      .replace(/^[\s·|:-]+|[\s·|:-]+$/g, '')
    if (root) return formatNetworkError(new Error(root), fallback)
    return withDevTail('网络请求失败，请稍后重试。', raw)
  }

  if (/\b401\b/.test(raw) || /unauthorized/i.test(raw) || raw.includes('未授权')) {
    return `登录态失效，请重新登录后再试。`
  }

  if (looksLikeEngineerNoise(raw)) return fallback
  return withDevTail(raw || fallback, raw)
}

/**
 * 用户可见错误：优先读响应体中文 message，再回落 formatNetworkError。
 * 写操作 catch 里请用这个，避免只显示 “Response returned an error code”。
 */
export async function formatUserError(error: unknown, fallback = '操作失败'): Promise<string> {
  const sync = extractApiMessageSync(error)
  if (sync) return sync

  try {
    const res = (error as { response?: { json?: () => Promise<unknown>; clone?: () => { json: () => Promise<unknown> } } })
      ?.response
    if (res && typeof res.json === 'function') {
      // 有的实现 json 只能读一次，优先 clone
      const body = res.clone && typeof res.clone === 'function' ? await res.clone().json() : await res.json()
      const msg = extractApiMessageSync({ data: body })
      if (msg) return msg
      if (body && typeof body === 'object') {
        const o = body as { error?: { message?: string }; message?: string }
        const m = o.error?.message || o.message
        if (typeof m === 'string' && m.trim()) return m.trim()
      }
    }
  } catch {
    // ignore parse failures
  }

  return formatNetworkError(error, fallback)
}

const TOAST_MAX = 36

/**
 * 把用户可见错误弹出来：短句 toast，长句 modal（不再 title.slice 截半句）。
 * 静态 import Taro（不用动态 import，避免编译/tsc 对 await import 挑剔）。
 */
export async function notifyUserError(
  error: unknown,
  fallback = '操作失败',
  options?: { title?: string }
): Promise<string> {
  const message = await formatUserError(error, fallback)
  await presentUserMessage(message, options?.title || '出了点问题')
  return message
}

/** 已知文案（非 Error）同样走短 toast / 长 modal。 */
export async function presentUserMessage(message: string, title = '提示'): Promise<void> {
  const text = String(message || '').trim() || '请稍后重试'
  try {
    if (text.length <= TOAST_MAX && !text.includes('\n')) {
      await Taro.showToast({ title: text, icon: 'none', duration: 2800 })
      return
    }
    await Taro.showModal({
      title,
      content: text,
      showCancel: false,
      confirmText: '知道了'
    })
  } catch {
    // 测试桩 / 无 UI 环境
  }
}
