// 开发构建「离线进入」：不请求任何远端域名，真机也不碰合法域名。
// 生产语义（非 development）下所有入口 fail-closed。
// 不 import api/client，避免与 taro-fetch 循环依赖；token 由 saveBreederSession 写入。
import config from '../utils/config'
import { storageGet, storageRemove, storageSet } from '../utils/storage'
import { saveBreederSession, type BreederSession } from './session'

export const OFFLINE_DEV_FLAG_KEY = 'scolvpet_offline_dev_mode'
/** 本地假会话 token；真机会话落盘时必须清掉同名标记。 */
export const OFFLINE_DEV_TOKEN = 'offline-dev-token'
const OFFLINE_TOKEN = OFFLINE_DEV_TOKEN

const ALL_CAPS = [
  'member_role:owner',
  'tenant_scope',
  'offline_read_cache',
  'manage_members',
  'manage_subscriptions',
  'write_breeding',
  'write_litter',
  'write_hamster',
  'write_enclosure',
  'write_weight',
  'write_task',
  'write_health',
  'write_import',
  'write_media',
  'write_crm',
  'write_documents',
  'write_accounting',
  'write_growth'
]

function isDevBuild() {
  return (config as { APP_ENV?: string }).APP_ENV === 'development'
}

export function isOfflineDevMode() {
  return isDevBuild() && storageGet(OFFLINE_DEV_FLAG_KEY) === true
}

/** 写入本地假会话并打开离线开关。仅 development。 */
export function enterOfflineDevSession(): BreederSession {
  if (!isDevBuild()) {
    throw new Error('离线进入仅开发构建可用')
  }
  const session: BreederSession = {
    accessToken: OFFLINE_TOKEN,
    refreshToken: '',
    expiresAt: Date.now() + 7 * 24 * 60 * 60 * 1000,
    displayName: '离线演示',
    phoneMasked: '离线模式',
    organizationName: '离线熊舍（无后端）',
    memberRole: 'owner',
    capabilities: ALL_CAPS
  }
  storageSet(OFFLINE_DEV_FLAG_KEY, true)
  saveBreederSession(session)
  return session
}

export function clearOfflineDevMode() {
  storageRemove(OFFLINE_DEV_FLAG_KEY)
}

/** 是否为离线假会话（accessToken 或标记位）。 */
export function isOfflineDevSession(session?: { accessToken?: string } | null) {
  if (!isDevBuild()) return false
  if (storageGet(OFFLINE_DEV_FLAG_KEY) === true) return true
  return Boolean(session?.accessToken && session.accessToken === OFFLINE_TOKEN)
}
