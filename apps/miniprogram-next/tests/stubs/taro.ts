// @tarojs/taro 的最小桩:窗口信息 + 路由/Toast 调用记录(供功能断言)。
export const recorded = {
  toasts: [] as string[],
  navigations: [] as string[],
  backs: 0,
  reset() {
    this.toasts = []
    this.navigations = []
    this.backs = 0
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

export function showToast(opt: { title: string }) {
  recorded.toasts.push(opt.title)
  return Promise.resolve()
}

export default { getWindowInfo, getSystemInfoSync, navigateBack, navigateTo, showToast, recorded }
