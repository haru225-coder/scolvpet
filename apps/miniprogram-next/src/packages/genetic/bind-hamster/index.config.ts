// 自绘导航(mp-ui NavBar)必须配 navigationStyle: 'custom'，否则与原生导航栏叠加。
// 2026-08-12：此前整仓唯一缺失本文件的 B 端页，真机上双导航栏叠加。
export default definePageConfig({
  navigationStyle: 'custom',
  navigationBarTitleText: '绑定个体'
})
