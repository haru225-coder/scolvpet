// Storage 原语单一真源：会话与离线快照都从这里读写，
// 避免 auth/session 与 offline/snapshots 互相 import 形成循环依赖。
// 测试桩只实现 get/set/remove，因此 keys() 必须容忍缺失。
import Taro from '@tarojs/taro'

function runtime(): any {
  const taro = Taro as any
  if (typeof taro?.getStorageSync === 'function') return taro
  return (globalThis as any).wx
}

export function storageGet<T = unknown>(key: string): T | undefined {
  const api = runtime()
  return typeof api?.getStorageSync === 'function' ? (api.getStorageSync(key) as T) : undefined
}

export function storageSet(key: string, value: unknown) {
  const api = runtime()
  if (typeof api?.setStorageSync === 'function') api.setStorageSync(key, value)
}

export function storageRemove(key: string) {
  const api = runtime()
  if (typeof api?.removeStorageSync === 'function') api.removeStorageSync(key)
}

/** 枚举已写入的 key；宿主不支持时返回空数组（调用方需自备回退）。 */
export function storageKeys(): string[] {
  const api = runtime()
  if (typeof api?.getStorageInfoSync !== 'function') return []
  try {
    const info = api.getStorageInfoSync()
    return Array.isArray(info?.keys) ? info.keys : []
  } catch {
    return []
  }
}
