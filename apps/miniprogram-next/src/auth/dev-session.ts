// 开发构建专用：用 Mock 验证码自动换真实 B 端会话。
// 生产语义下 config 会清空 DEV_LOGIN_*，本模块所有入口 fail-closed。
//
// 真机登录走裸 Taro.request + snake_case（与 curl 成功路径一致），
// 避免 OpenAPI 中间层吞掉微信 errMsg / 响应体。
//
// 2026-08：首屏改成「种群 / 试配」后，不能再只在今日页/登录页才自动登录；
// 用 ensureDevelopmentBreederSession 做启动 + 首屏共用的单飞保证。
import Taro from '@tarojs/taro'
import { setApiToken } from '../api/client'
import { formatNetworkError } from '../api/errors'
import config from '../utils/config'
import { diag } from '../utils/diag'
import { clearOfflineDevMode, isOfflineDevMode, isOfflineDevSession } from './offline-dev'
import {
  clearBreederSession,
  peekBreederSession,
  readBreederSession,
  saveBreederSession,
  type BreederSession
} from './session'

const runtimeConfig = config as {
  APP_ENV?: string
  API_BASE?: string
  DEV_LOGIN_PHONE?: string
  DEV_LOGIN_CODE?: string
}

function apiBase(): string {
  return String(runtimeConfig.API_BASE || 'https://pet.scolv.com').replace(/\/$/, '')
}

/** Vitest 下 create 走 defaultApi mock（与自动登录开关无关）。 */
function isUnitTestRuntime() {
  return typeof process !== 'undefined' && process.env.VITEST === 'true'
}

export function isDevelopmentQuickLoginEnabled() {
  return (
    runtimeConfig.APP_ENV === 'development' &&
    Boolean(runtimeConfig.DEV_LOGIN_PHONE) &&
    Boolean(runtimeConfig.DEV_LOGIN_CODE)
  )
}

/**
 * 是否在页面挂载时自动 ensure mock 会话。
 * 单测默认关（避免污染表单）；设 SCOLV_ALLOW_DEV_AUTO_ENTER=1 可打开单飞等用例。
 */
export function shouldAutoEnterDevelopmentSession() {
  if (!isDevelopmentQuickLoginEnabled()) return false
  if (isUnitTestRuntime() && process.env.SCOLV_ALLOW_DEV_AUTO_ENTER !== '1') return false
  return true
}

/** 单飞：多页面同时 await 只打一次 mock 登录。 */
let ensureInflight: Promise<BreederSession | null> | null = null
/** 最近一次 ensure 失败原因（成功时清空）；供 UI 展示，避免再二次 create 撞限流。 */
let lastEnsureError = ''

export type EnsureSessionOptions = {
  /** 清掉现有会话并强制重新 mock 登录（401 重登用）。仍走单飞，不与并发 ensure 叠两次发码。 */
  force?: boolean
}

/** 读取最近一次 ensure 失败文案；无失败返回空串。 */
export function getLastEnsureError(): string {
  return lastEnsureError
}

/**
 * 保证当前有可用 B 端会话（开发构建下自动 mock 登录）。
 * - 生产 / 未注入 DEV_LOGIN / 单测：只 hydrate 本地会话，不抢跑。
 * - 开发：无会话或离线假会话 → createDevelopmentBreederSession。
 * - force：清会话后重登一次（listTasks 401 等）。
 * - **永不抛**：失败返回 null，原因见 getLastEnsureError()。
 *   调用方不要再立刻 createDevelopment 二次发码（易 RATE_LIMITED）。
 */
export async function ensureDevelopmentBreederSession(
  options?: EnsureSessionOptions
): Promise<BreederSession | null> {
  const force = Boolean(options?.force)

  if (!shouldAutoEnterDevelopmentSession()) {
    lastEnsureError = ''
    return readBreederSession()
  }

  if (force) {
    // 等掉在途 ensure，再清会话，避免与首屏 load 抢飞
    if (ensureInflight) {
      try {
        await ensureInflight
      } catch (_) {
        // ignore
      }
    }
    clearBreederSession()
    diag('ensureDevSession: force re-login')
  } else {
    const hydrated = readBreederSession()
    const peek = peekBreederSession()
    if (hydrated && peek && !isOfflineDevSession(peek) && !isOfflineDevMode()) {
      lastEnsureError = ''
      return hydrated
    }
  }

  if (ensureInflight) return ensureInflight

  ensureInflight = (async () => {
    try {
      if (isOfflineDevMode() || isOfflineDevSession(peekBreederSession())) {
        diag('ensureDevSession: clear sticky offline')
        clearBreederSession()
      }
      if (!force) {
        const existing = readBreederSession()
        if (existing && !isOfflineDevSession(existing) && !isOfflineDevMode()) {
          lastEnsureError = ''
          return existing
        }
      }
      clearBreederSession()
      diag('ensureDevSession: create development session')
      const session = await createDevelopmentBreederSession()
      lastEnsureError = ''
      return session
    } catch (cause) {
      lastEnsureError = formatDevelopmentLoginError(cause)
      diag(`ensureDevSession fail ${lastEnsureError.slice(0, 200)}`)
      return null
    } finally {
      ensureInflight = null
    }
  })()

  return ensureInflight
}

/**
 * 页面加载统一入口：ensure 后返回会话。
 * 无会话 → null（开发失败看 getLastEnsureError；生产提示去登录）。
 */
export async function requireBreederSession(
  options?: EnsureSessionOptions
): Promise<BreederSession | null> {
  return ensureDevelopmentBreederSession(options)
}

export function developmentLoginHints() {
  if (!isDevelopmentQuickLoginEnabled()) {
    return { phone: '', code: '', hint: '' }
  }
  const phone = runtimeConfig.DEV_LOGIN_PHONE || ''
  const code = runtimeConfig.DEV_LOGIN_CODE || ''
  const base = apiBase()
  return {
    phone,
    code,
    hint: `真机开发登录：${phone} / ${code}（Mock）。API=${base}。合法域名须完全一致。`
  }
}

export function formatDevelopmentLoginError(error: unknown) {
  const network = formatNetworkError(error, '开发会话创建失败')
  const phone = runtimeConfig.DEV_LOGIN_PHONE || '13800138000'
  const code = runtimeConfig.DEV_LOGIN_CODE || '123456'
  const base = apiBase()
  return (
    `${network}\n\n` +
    `当前 API：${base}\n` +
    `手填：手机号 ${phone}，验证码 ${code}\n` +
    `若列表空但头像不是「离线演示」，说明已联网，只是演示账号暂无任务。`
  )
}

function apiPhone(value: string) {
  const digits = value.replace(/\D/g, '')
  return /^1\d{10}$/.test(digits) ? `+86${digits}` : value
}

type JsonResult = { statusCode: number; data: any }

function taroJson(
  method: 'GET' | 'POST',
  url: string,
  body?: Record<string, unknown>,
  extraHeaders?: Record<string, string>
): Promise<JsonResult> {
  return new Promise((resolve, reject) => {
    Taro.request({
      url,
      method,
      timeout: 20000,
      header: {
        'Content-Type': 'application/json',
        ...(extraHeaders || {})
      },
      data: body,
      success: (res) => {
        resolve({ statusCode: res.statusCode, data: res.data })
      },
      fail: (err) => {
        reject(new Error((err && err.errMsg) || `request fail ${url}`))
      }
    })
  })
}

/** 探测 API 是否可达（域名/证书/网络）。 */
export async function probeApiBase(): Promise<string> {
  const base = apiBase()
  const res = await taroJson('GET', `${base}/readyz`)
  if (res.statusCode < 200 || res.statusCode >= 300) {
    throw new Error(`${base}/readyz → HTTP ${res.statusCode}`)
  }
  return `${base}/readyz → ${res.statusCode}`
}

/**
 * 向当前 API_BASE 用 Mock 码换会话（裸 request，snake_case）。
 */
export async function createDevelopmentBreederSession(phone?: string): Promise<BreederSession> {
  if (!isDevelopmentQuickLoginEnabled()) {
    throw new Error('开发快速登录仅在 development 构建且注入 DEV_LOGIN_* 时可用')
  }
  const quickPhone = phone && /^1\d{10}$/.test(phone) ? phone : runtimeConfig.DEV_LOGIN_PHONE || ''
  const quickCode = runtimeConfig.DEV_LOGIN_CODE || ''
  if (!quickPhone || !quickCode) {
    throw new Error('缺少开发登录手机号或 Mock 验证码')
  }

  clearOfflineDevMode()
  const base = apiBase()
  const phoneE164 = apiPhone(quickPhone)
  diag(`login start api=${base} phone=${phoneE164}`)

  // 单测：没有真实 Taro.request，走 mock 不了裸请求；测试里仍 spy defaultApi 的路径见下方 fallback
  if (isUnitTestRuntime()) {
    const { defaultApi, newIdempotencyKey } = await import('../api/client')
    const codeResponse = await defaultApi.sendVerificationCode({
      idempotencyKey: `mp-dev-login-code-${Date.now()}`,
      sendVerificationCodeRequest: { phone: phoneE164, purpose: 'login' } as any,
      xTimezone: 'Asia/Taipei'
    })
    const response = await defaultApi.createSession({
      idempotencyKey: newIdempotencyKey(),
      phoneCodeLoginRequest: {
        phone: phoneE164,
        verificationId: codeResponse.data.verificationId,
        code: quickCode,
        device: { platform: 'android', appVersion: 'miniprogram-dev', deviceName: 'WeChat Mini Program Dev' }
      } as any,
      xTimezone: 'Asia/Taipei'
    })
    const data = response.data
    if (!data?.accessToken || !data.expiresInSeconds || !data.account || !Array.isArray(data.capabilities)) {
      throw new Error('服务端返回的登录会话不完整')
    }
    const session: BreederSession = {
      accessToken: data.accessToken,
      refreshToken: data.refreshToken || '',
      expiresAt: Date.now() + data.expiresInSeconds * 1000,
      displayName: data.account.displayName || undefined,
      phoneMasked: data.account.phoneMasked,
      organizationName: data.currentOrganization?.name,
      memberRole: data.memberRole,
      capabilities: data.capabilities
    }
    saveBreederSession(session)
    return session
  }

  // 1) 连通性
  try {
    const probe = await probeApiBase()
    diag(`probe ok ${probe}`)
  } catch (error) {
    const msg = formatNetworkError(error, `探测 ${base} 失败`)
    diag(`probe fail ${msg}`)
    throw new Error(msg)
  }

  // 2) 发验证码
  let codeRes: JsonResult
  try {
    codeRes = await taroJson(
      'POST',
      `${base}/v1/auth/verification-codes`,
      { phone: phoneE164, purpose: 'login' },
      {
        'Idempotency-Key': `mp-dev-login-code-${Date.now()}`,
        'X-Timezone': 'Asia/Taipei'
      }
    )
  } catch (error) {
    const msg = formatNetworkError(error, '发送验证码请求失败')
    diag(`sendCode network ${msg}`)
    throw new Error(msg)
  }
  diag(`sendCode HTTP ${codeRes.statusCode}`)
  if (codeRes.statusCode < 200 || codeRes.statusCode >= 300) {
    const msg = `发送验证码 HTTP ${codeRes.statusCode}：${JSON.stringify(codeRes.data).slice(0, 240)}`
    diag(msg)
    throw new Error(msg)
  }
  const verificationId =
    codeRes.data?.data?.verification_id ||
    codeRes.data?.data?.verificationId ||
    codeRes.data?.verification_id ||
    codeRes.data?.verificationId
  if (!verificationId) {
    const msg = `验证码响应无 verification_id：${JSON.stringify(codeRes.data).slice(0, 240)}`
    diag(msg)
    throw new Error(msg)
  }

  // 3) 换会话
  let sessionRes: JsonResult
  try {
    sessionRes = await taroJson(
      'POST',
      `${base}/v1/auth/sessions`,
      {
        phone: phoneE164,
        verification_id: verificationId,
        code: quickCode,
        device: {
          platform: 'android',
          app_version: 'miniprogram-dev',
          device_name: 'WeChat Mini Program Dev'
        }
      },
      {
        'Idempotency-Key': `mp-dev-session-${Date.now()}-${Math.random().toString(16).slice(2)}`,
        'X-Timezone': 'Asia/Taipei'
      }
    )
  } catch (error) {
    const msg = formatNetworkError(error, '创建会话请求失败')
    diag(`session network ${msg}`)
    throw new Error(msg)
  }
  diag(`session HTTP ${sessionRes.statusCode}`)
  if (sessionRes.statusCode < 200 || sessionRes.statusCode >= 300) {
    const msg = `创建会话 HTTP ${sessionRes.statusCode}：${JSON.stringify(sessionRes.data).slice(0, 240)}`
    diag(msg)
    throw new Error(msg)
  }

  const raw = sessionRes.data?.data || sessionRes.data || {}
  const accessToken = raw.access_token || raw.accessToken
  const refreshToken = raw.refresh_token || raw.refreshToken || ''
  const expiresIn = Number(raw.expires_in_seconds ?? raw.expiresInSeconds)
  const account = raw.account || {}
  const org = raw.current_organization || raw.currentOrganization || {}
  const capabilities = raw.capabilities
  if (!accessToken || !expiresIn || !account || !Array.isArray(capabilities)) {
    const msg = `会话响应不完整：${JSON.stringify(sessionRes.data).slice(0, 240)}`
    diag(msg)
    throw new Error(msg)
  }

  const session: BreederSession = {
    accessToken,
    refreshToken,
    expiresAt: Date.now() + expiresIn * 1000,
    displayName: account.display_name || account.displayName || undefined,
    phoneMasked: account.phone_masked || account.phoneMasked,
    organizationName: org.name,
    memberRole: raw.member_role || raw.memberRole,
    capabilities
  }
  saveBreederSession(session)
  setApiToken(accessToken)
  diag(`login ok org=${session.organizationName || ''} name=${session.displayName || ''}`)
  return session
}
