// @tarojs/taro 的最小桩:窗口信息 + 路由/Toast 调用记录(供功能断言)。
import { useEffect } from 'react'

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

type Handler = (...args: any[]) => void
const listeners = new Map<string, Set<Handler>>()

export const eventCenter = {
  on(event: string, handler: Handler) {
    if (!listeners.has(event)) listeners.set(event, new Set())
    listeners.get(event)!.add(handler)
  },
  off(event: string, handler?: Handler) {
    if (!handler) {
      listeners.delete(event)
      return
    }
    listeners.get(event)?.delete(handler)
  },
  trigger(event: string, ...args: any[]) {
    listeners.get(event)?.forEach((handler) => handler(...args))
  }
}

/** useDidShow：测试里立即跑一遍（模拟进入页面）。 */
export function useDidShow(cb: () => void) {
  useEffect(() => {
    cb()
  }, [cb])
}

/** useLoad：测试里立即跑一遍。 */
export function useLoad(cb: (query?: Record<string, string>) => void) {
  useEffect(() => {
    cb({})
  }, [cb])
}

export function getCurrentPages() {
  return [{ route: 'pages/today/index' }]
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

export function switchTab(opt: { url: string }) {
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

export default {
  getWindowInfo,
  getSystemInfoSync,
  getCurrentPages,
  navigateBack,
  navigateTo,
  redirectTo,
  reLaunch,
  switchTab,
  showToast,
  getStorageSync,
  setStorageSync,
  removeStorageSync,
  getStorageInfoSync,
  eventCenter,
  useDidShow,
  useLoad,
  recorded
}
