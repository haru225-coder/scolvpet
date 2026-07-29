// 个体列表页：Skyline 按页开启 + 自定义导航(docs/34 §7)。
// 低端机不达标时删除 renderer 即整页回退 WebView。
export default definePageConfig({
  renderer: 'skyline',
  navigationStyle: 'custom',
  disableScroll: true,
  navigationBarTitleText: '个体'
})
