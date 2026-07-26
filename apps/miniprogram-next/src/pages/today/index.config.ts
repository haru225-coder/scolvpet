// M0-6 样例页:Skyline 按页开启 + 自定义导航(mp-ui NavBar,手势返回)。
// 低端机不达标时允许整页回退 WebView(docs/32 §9):删掉 renderer 即回退。
export default definePageConfig({
  renderer: 'skyline',
  navigationStyle: 'custom',
  disableScroll: true,
  navigationBarTitleText: '今日'
})
