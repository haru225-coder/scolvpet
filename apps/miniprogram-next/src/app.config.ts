// 分包地图(docs/32 §1 / docs/33 M0-1):
//   主包 = 登录 + 今日 Tab + mp-ui + C 端 7 页原生混写(路径保持 pages/... 兼容既有小程序码深链)
//   B 端各域预留分包位:个体/繁育/CRM/合同/财务/AI(M1 起填充业务页)
// 体积门禁:单分包 <2MB,预警 1.6MB(scripts/check-mp-bundle-size.mjs)
export default defineAppConfig({
  pages: [
    'pages/today/index',
    'pages/login/index',
    // —— C 端原生混写页(原样并入,勿改路径)——
    'pages/index/index',
    'pages/catalog/catalog',
    'pages/detail/detail',
    'pages/pedigree/pedigree',
    'pages/simulate/simulate',
    'pages/my-reservations/my-reservations',
    'pages/contract/contract'
  ],
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
    { root: 'packages/ai', pages: ['index/index'] }
  ],
  // Skyline 按页面粒度声明(renderer: 'skyline' 写在各页 config),
  // glass-easel + 按需注入是 Skyline 前置条件。
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
  // 全局 window 沿用旧 apps/miniprogram/app.json,保证 C 端混写页观感不变;
  // 新 B 端页一律 navigationStyle: custom(mp-ui NavBar)按页覆盖。
  window: {
    navigationBarTitleText: 'ScolvPet 熊舍',
    navigationBarBackgroundColor: '#1F6B4A',
    navigationBarTextStyle: 'white',
    backgroundColor: '#F6F3EE'
  },
  style: 'v2',
  sitemapLocation: 'sitemap.json'
})
