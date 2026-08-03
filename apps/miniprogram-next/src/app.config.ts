// 分包地图（docs/32 §1 / docs/33 M0-1 / UI 重组 v3）：
//   主包 = 登录 + 三个 Tab（今日/种群/经营）+ mp-ui + C 端 7 页原生混写（路径保持 pages/... 兼容既有小程序码深链）
//   「我的」不占 Tab，收进主视窗右上角头像 → packages/profile 分包
//   B 端各域分包路径一律不改，入口改为三栏 + 主视窗按钮（src/utils/tab-routes.ts）
// 体积门禁：单分包 <2MB，预警 1.6MB（scripts/check-mp-bundle-size.mjs）
export default defineAppConfig({
  pages: [
    'pages/today/index',
    'pages/population/index',
    'pages/business/index',
    'pages/login/index',
    // —— C 端原生混写页（原样并入，勿改路径）——
    'pages/index/index',
    'pages/catalog/catalog',
    'pages/detail/detail',
    'pages/pedigree/pedigree',
    'pages/simulate/simulate',
    'pages/my-reservations/my-reservations',
    'pages/contract/contract'
  ],
  // 三栏底部导航。custom: true = 自绘 TabBar（src/custom-tab-bar）；
  // iconPath 给基础库不支持自绘时的原生降级。
  tabBar: {
    custom: true,
    color: '#7A726A',
    selectedColor: '#E0A070',
    backgroundColor: '#14110F',
    borderStyle: 'black',
    list: [
      {
        pagePath: 'pages/today/index',
        text: '今日',
        iconPath: 'assets/tab/today.png',
        selectedIconPath: 'assets/tab/today-active.png'
      },
      {
        pagePath: 'pages/population/index',
        text: '种群',
        iconPath: 'assets/tab/population.png',
        selectedIconPath: 'assets/tab/population-active.png'
      },
      {
        pagePath: 'pages/business/index',
        text: '经营',
        iconPath: 'assets/tab/business.png',
        selectedIconPath: 'assets/tab/business-active.png'
      }
    ]
  },
  subPackages: [
    { root: 'packages/animals', pages: ['index/index', 'detail/index', 'create/index', 'batch-create/index'] },
    { root: 'packages/litters', pages: ['index/index', 'detail/index'] },
    { root: 'packages/reminders', pages: ['index/index', 'create/index', 'calendar/index', 'subscriptions/index'] },
    { root: 'packages/breeding', pages: ['index/index', 'detail/index', 'create/index'] },
    { root: 'packages/crm', pages: ['index/index', 'detail/index', 'create/index'] },
    { root: 'packages/contracts', pages: ['index/index', 'create/index', 'detail/index', 'templates/index'] },
    { root: 'packages/finance', pages: ['index/index', 'create/index', 'categories/index'] },
    { root: 'packages/genetic', pages: ['index/index', 'create/index'] },
    { root: 'packages/data-center', pages: ['index/index', 'actions/index'] },
    { root: 'packages/ai', pages: ['index/index'] },
    { root: 'packages/profile', pages: ['index/index'] }
  ],
  // 2026-08-03 C1：各业务页已统一关闭 page-level renderer:skyline，走 WebView，
  // 避免与 custom-tab-bar / 滚动手势行为不一致。glass-easel 仍保留（Taro/组件前置）。
  // rendererOptions.skyline 仅作框架占位；重新启用须逐页真机验证后再开。
  lazyCodeLoading: 'requiredComponents',
  componentFramework: 'glass-easel',
  rendererOptions: {
    skyline: {
      defaultDisplayBlock: true,
      defaultContentBox: true,
      disableABTest: true,
      sdkVersionBegin: '3.0.0',
      sdkVersionEnd: '15.255.255'
    }
  },
  // 全局 window 沿用旧 apps/miniprogram/app.json，保证 C 端混写页观感不变；
  // B 端新页一律 navigationStyle: custom + backgroundColor 按页覆盖为奶油深色。
  window: {
    navigationBarTitleText: 'ScolvPet 熊舍',
    navigationBarBackgroundColor: '#1F6B4A',
    navigationBarTextStyle: 'white',
    backgroundColor: '#F6F3EE'
  },
  style: 'v2',
  sitemapLocation: 'sitemap.json'
})
