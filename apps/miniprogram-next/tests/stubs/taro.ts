// @tarojs/taro 的最小桩:窗口信息 + 路由/Toast 调用记录(供功能断言)。
export const recorded = {
  toasts: [] as string[],
  navigations: [] as string[],
  backs: 0,
  storage: new Map<string, unknown>(),
  reset() {
    this.toasts = []
    this.navigations = []
    this.backs = 0
    this.storage.clear()
  }
}

export function getWindowInfo() {
  return { statusBarHeight: 44, windowWidth: 375, windowHeight: 812, safeArea: { bottom: 778 } }
}

export function getSystemInfoSync() {
  return getWindowInfo()
}

export function navigateBack() {
  recorded.backs += 1
}

export function navigateTo(opt: { url: string }) {
  recorded.navigations.push(opt.url)
  return Promise.resolve()
}

export function redirectTo(opt: { url: string }) {
  recorded.navigations.push(opt.url)
  return Promise.resolve()
}

export function reLaunch(opt: { url: string }) {
  recorded.navigations.push(opt.url)
  return Promise.resolve()
}

export function showToast(opt: { title: string }) {
  recorded.toasts.push(opt.title)
  return Promise.resolve()
}

export function getStorageSync(key: string) {
  return recorded.storage.get(key)
}

export function setStorageSync(key: string, value: unknown) {
  recorded.storage.set(key, value)
}

export function removeStorageSync(key: string) {
  recorded.storage.delete(key)
}

export function getStorageInfoSync() {
  return { keys: [...recorded.storage.keys()] }
}

export default { getWindowInfo, getSystemInfoSync, navigateBack, navigateTo, redirectTo, reLaunch, showToast, getStorageSync, setStorageSync, removeStorageSync, getStorageInfoSync, recorded }
