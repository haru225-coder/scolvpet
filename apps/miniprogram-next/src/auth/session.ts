import { clearApiToken, getApiToken, setApiToken } from '../api/client'
import { clearAllSnapshots } from '../offline/snapshots'
import { storageGet, storageRemove, storageSet } from '../utils/storage'

export const BREEDER_SESSION_KEY = 'scolvpet_breeder_session'

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

export function readSessionStorage<T = unknown>(key: string): T | undefined {
  return storageGet(key) as T | undefined
}

export function writeSessionStorage(key: string, value: unknown) {
  storageSet(key, value)
}

export function removeSessionStorage(key: string) {
  storageRemove(key)
}

export function readBreederSession(): BreederSession | null {
  const stored = storageGet(BREEDER_SESSION_KEY) as Partial<BreederSession> | undefined
  const now = Date.now()
  const expiresAt = Number(stored?.expiresAt) || 0
  if (!stored?.accessToken || !expiresAt || expiresAt <= now || expiresAt > now + MAX_SESSION_WINDOW_MS) {
    clearApiToken()
    storageRemove(BREEDER_SESSION_KEY)
    return null
  }
  setApiToken(stored.accessToken)
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

export function saveBreederSession(session: BreederSession) {
  setApiToken(session.accessToken)
  storageSet(BREEDER_SESSION_KEY, session)
}

/**
 * 退出登录：token、会话、离线快照一起清。
 * 快照里是上一个账号的任务与个体数据，共用设备时不能留给下一个人。
 */
export function clearBreederSession() {
  clearApiToken()
  storageRemove(BREEDER_SESSION_KEY)
  clearAllSnapshots()
}

export function hasBreederSession() {
  return Boolean(getApiToken() || readBreederSession())
}
