// Tab 页一律不开 skyline（自绘底标会退化到文档流顶部，2026-08-02 真机复现）。
export default definePageConfig({
  navigationStyle: 'custom',
  backgroundColor: '#14110F',
  backgroundTextStyle: 'light',
  navigationBarTitleText: '试配'
})
