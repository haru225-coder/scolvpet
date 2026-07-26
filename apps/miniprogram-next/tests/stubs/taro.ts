// @tarojs/taro 的最小桩:mp-ui 只用到窗口/状态栏信息与路由返回。
export function getWindowInfo() {
  return { statusBarHeight: 44, windowWidth: 375, windowHeight: 812, safeArea: { bottom: 778 } }
}

export function getSystemInfoSync() {
  return getWindowInfo()
}

export function navigateBack() {}

export default { getWindowInfo, getSystemInfoSync, navigateBack }
