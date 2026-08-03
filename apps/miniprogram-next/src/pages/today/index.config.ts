// 今日经营首页。
// 注意：不要在 Tab 页上开 renderer: 'skyline'。
// Skyline 不接管 custom-tab-bar，自绘底栏会退化成普通节点插到文档流最前面，
// 结果是底栏跑到屏幕顶部压住状态栏（2026-08-02 真机复现）。
// 三个 Tab 页统一走 WebView 渲染器，直到自绘底栏改为页内 fixed 组件为止。
export default definePageConfig({
  navigationStyle: 'custom',
  backgroundColor: '#14110F',
  backgroundTextStyle: 'light',
  navigationBarTitleText: '今日'
})
