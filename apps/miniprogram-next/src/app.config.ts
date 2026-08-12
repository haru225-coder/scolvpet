// 分包地图（docs/32 §1 / docs/33 M0-1 / UI 重组 v3 · 轻量化 ④）：
//   主包 = 登录 + 两栏 Tab（种群 / 试配）+ 共享依赖
//   今日 / 经营：已下 tabBar，路径不变，迁入独立分包（旧深链 / 主视窗入口仍 navigateTo）
//   C 端 7 页原生混写：路径保持 pages/...（兼容小程序码 scene），各自独立分包，B 端冷启动不背
//   「我的」→ packages/profile；其余 B 域分包路径不变
// 体积门禁：单分包 <2MB，预警 1.6MB（scripts/check-mp-bundle-size.mjs）
export default defineAppConfig({
  pages: [
    // 首屏 = 种群（管理）；trial = 试配推理器（tabBar 只能指主包页）
    'pages/population/index',
    'pages/trial/index',
    'pages/login/index'
  ],
  // 三栏底部导航。custom: true = 自绘 TabBar（src/custom-tab-bar）；
  // iconPath 给基础库不支持自绘时的原生降级。
  tabBar: {
    custom: true,
    color: '#7A726A',
    selectedColor: '#E0A070',
    backgroundColor: '#14110F',
    borderStyle: 'black',
    // 2026-08-04：客户验收只要「管理 + 试配 + 族谱」。
    // 今日 / 经营 不再占 Tab（页面保留，从主视窗入口进）。
    list: [
      {
        pagePath: 'pages/population/index',
        text: '种群',
        iconPath: 'assets/tab/population.png',
        selectedIconPath: 'assets/tab/population-active.png'
      },
      {
        pagePath: 'pages/trial/index',
        text: '试配',
        // 与 custom-tab-bar 一致：用 today 资产区分种群，避免两栏同图标
        iconPath: 'assets/tab/today.png',
        selectedIconPath: 'assets/tab/today-active.png'
      }
    ]
  },
  subPackages: [
    // —— 离栏 B 端页（路径不变）——
    { root: 'pages/today', pages: ['index'] },
    { root: 'pages/business', pages: ['index'] },
    // —— C 端原生混写（路径 pages/... 不变，兼容既有小程序码）——
    { root: 'pages/index', pages: ['index'] },
    { root: 'pages/catalog', pages: ['catalog'] },
    { root: 'pages/detail', pages: ['detail'] },
    { root: 'pages/pedigree', pages: ['pedigree'] },
    { root: 'pages/simulate', pages: ['simulate'] },
    { root: 'pages/my-reservations', pages: ['my-reservations'] },
    { root: 'pages/contract', pages: ['contract'] },
    // —— B 端业务域 ——
    { root: 'packages/animals', pages: ['index/index', 'detail/index', 'create/index', 'batch-create/index', 'pedigree/index'] },
    { root: 'packages/litters', pages: ['index/index', 'detail/index', 'weight/index'] },
    { root: 'packages/reminders', pages: ['index/index', 'create/index', 'calendar/index', 'subscriptions/index'] },
    { root: 'packages/breeding', pages: ['index/index', 'detail/index', 'create/index'] },
    { root: 'packages/crm', pages: ['index/index', 'detail/index', 'create/index'] },
    { root: 'packages/contracts', pages: ['index/index', 'create/index', 'detail/index', 'templates/index'] },
    { root: 'packages/finance', pages: ['index/index', 'create/index', 'categories/index'] },
    { root: 'packages/genetic', pages: ['index/index', 'create/index', 'bind-hamster/index'] },
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
