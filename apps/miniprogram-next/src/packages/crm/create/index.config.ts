// 自绘导航(mp-ui NavBar)必须配 navigationStyle: 'custom'，否则与原生导航栏叠加。
// Skyline 按页开启；低端机不达标时删掉 renderer 即整页回退 WebView。
export default definePageConfig({
  renderer: 'skyline',
  navigationStyle: 'custom',
  navigationBarTitleText: '新建客户'
})
