// 只拉 runtime，不静态 import defaultApi——否则几乎所有页经 auth 都会钉死 DefaultApi。
import { clearApiToken, getApiToken, newIdempotencyKey, setApiToken } from '../api/runtime-config'
import { clearAllSnapshots } from '../offline/snapshots'
import { storageGet, storageRemove, storageSet } from '../utils/storage'
export const BREEDER_SESSION_KEY = 'scolvpet_breeder_session'
// 与 offline-dev 同 key，写死字符串避免 session ↔ offline 循环 import
const OFFLINE_DEV_FLAG_KEY = 'scolvpet_offline_dev_mode'

// Storage 不加密、expiresAt 可被本地时间影响：这里加上窗口上限，
// 避免调表/写脏数据得到一个几乎永不过期的会话；真正的防线仍是后端。
const MAX_SESSION_WINDOW_MS = 30 * 24 * 60 * 60 * 1000

export type BreederSession = {
  accessToken: string
  refreshToken: string
  expiresAt: number
  displayName?: string
  phoneMasked?: string
  organizationName?: string
  memberRole?: string
  capabilities: string[]
}

type SessionResponseDataLike = {
  accessToken?: string
  refreshToken?: string
  expiresInSeconds?: number
  account?: { displayName?: string | null; phoneMasked?: string }
  currentOrganization?: { name?: string }
  memberRole?: string
  capabilities?: string[]
}

function sessionFromResponse(data: SessionResponseDataLike | undefined): BreederSession | null {
  if (
    !data?.accessToken ||
    !data.refreshToken ||
    !data.expiresInSeconds ||
    !data.account ||
    !Array.isArray(data.capabilities)
  ) return null
  return {
    accessToken: data.accessToken,
    refreshToken: data.refreshToken,
    expiresAt: Date.now() + data.expiresInSeconds * 1000,
    displayName: data.account.displayName || undefined,
    phoneMasked: data.account.phoneMasked,
    organizationName: data.currentOrganization?.name,
    memberRole: data.memberRole,
    capabilities: data.capabilities
  }
}

export function readSessionStorage<T = unknown>(key: string): T | undefined {
  return storageGet(key) as T | undefined
}

export function writeSessionStorage(key: string, value: unknown) {
  storageSet(key, value)
}

export function removeSessionStorage(key: string) {
  storageRemove(key)
}

function sessionFromStorage(): BreederSession | null {
  const stored = storageGet(BREEDER_SESSION_KEY) as Partial<BreederSession> | undefined
  const now = Date.now()
  const expiresAt = Number(stored?.expiresAt) || 0
  if (!stored?.accessToken || !expiresAt || expiresAt <= now || expiresAt > now + MAX_SESSION_WINDOW_MS) {
    return null
  }
  return {
    accessToken: stored.accessToken,
    refreshToken: stored.refreshToken || '',
    expiresAt: stored.expiresAt || 0,
    displayName: stored.displayName,
    phoneMasked: stored.phoneMasked,
    organizationName: stored.organizationName,
    memberRole: stored.memberRole,
    capabilities: Array.isArray(stored.capabilities) ? stored.capabilities : []
  }
}

/** 渲染期只读会话，不写入 API token，也不清理存储。 */
export function peekBreederSession(): BreederSession | null {
  return sessionFromStorage()
}

/** 恢复会话并同步 API token；副作用只应放在加载/事件流程。 */
export function readBreederSession(): BreederSession | null {
  const session = sessionFromStorage()
  if (!session) {
    clearApiToken()
    storageRemove(BREEDER_SESSION_KEY)
    return null
  }
  setApiToken(session.accessToken)
  return session
}

export function saveBreederSession(session: BreederSession) {
  setApiToken(session.accessToken)
  storageSet(BREEDER_SESSION_KEY, session)
  // 真机会话落盘时关掉离线开关。否则扫码预览会一直吃本地 offline-dev-token，
  // 所有请求被 taro-fetch 短路成空列表，看起来永远「离线」。
  if (session.accessToken && session.accessToken !== 'offline-dev-token') {
    storageRemove(OFFLINE_DEV_FLAG_KEY)
  }
}

/**
 * 启动 B 端时恢复会话：有效 access token 直接复用，过期后用轮换 refresh
 * token 换取新的一对令牌；刷新失败才清理本地会话和离线快照。
 */
export async function restoreBreederSession(): Promise<BreederSession | null> {
  const stored = storageGet(BREEDER_SESSION_KEY) as Partial<BreederSession> | undefined
  const expiresAt = Number(stored?.expiresAt) || 0
  if (stored?.accessToken && expiresAt > Date.now() && expiresAt <= Date.now() + MAX_SESSION_WINDOW_MS) {
    return readBreederSession()
  }

  const refreshToken = String(stored?.refreshToken || '')
  if (!refreshToken) {
    clearApiToken()
    storageRemove(BREEDER_SESSION_KEY)
    return null
  }

  try {
    const { defaultApi } = await import('../api/default-api')
    const response = await defaultApi.refreshSession({
      idempotencyKey: newIdempotencyKey(),
      refreshSessionRequest: { refreshToken },
      xTimezone: 'Asia/Taipei'
    })
    const session = sessionFromResponse(response.data)
    if (!session) throw new Error('刷新会话响应不完整')
    saveBreederSession(session)
    return session
  } catch (_) {
    clearBreederSession()
    return null
  }
}

/**
 * 退出登录：token、会话、离线快照一起清。
 * 快照里是上一个账号的任务与个体数据，共用设备时不能留给下一个人。
 */
export function clearBreederSession() {
  clearApiToken()
  storageRemove(BREEDER_SESSION_KEY)
  clearAllSnapshots()
  storageRemove(OFFLINE_DEV_FLAG_KEY)
}

export function hasBreederSession() {
  return Boolean(getApiToken() || peekBreederSession())
}
