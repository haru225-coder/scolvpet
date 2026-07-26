# ScolvPet 小程序仿 iOS 设计规范(M0)

**日期**:2026-07-27
**性质**:docs/32 §2 的 M0 交付物。小程序 B 端(Taro + Skyline)视觉与交互规范,手感对标 Flutter 端 iOS HIG 体系(docs/16)。
**真源链**:`apps/mobile/lib/ui/theme/ios_theme.dart`(视觉唯一真源)→ `apps/miniprogram-next/packages/mp-ui/src/tokens.ts`(TS 导出)→ 本文(人读规范)。改视觉先改 Dart 端,再同步 tokens.ts 与本文,禁止三处漂移。
**原型缺口**:`prototype/figma-import` 只画了 Flutter 五导航,小程序画板缺;M0 以本规范 + 样例页代替,Figma 补板不阻塞(docs/33 M0-2)。

---

## 1. 基调

> **方向变更(2026-07-27,用户 Gate 裁定,留痕)**:初版 iOS 素面(奶油底+暖橙)被判「AI 味/不过」。小程序端在 iOS 交互结构之上叠加**「蜡笔手账」表层**:纸纹底、蜡笔描边、四角不等的手绘圆角(wobble)、蜡笔波浪下划线、手绘贴纸(金丝熊/爪印/瓜子,内联 SVG 零外部资源)、贴纸微歪。docs/16 §4.1「不新增手绘 SVG 图标」约束在**小程序端解除**(用户拍板);Flutter 端不受影响。真源:`packages/mp-ui/src/tokens.ts` 的 `crayon` 段 + `theme.ts` 的 `wobble/paperGrain/crayonUnderline`。

基底仍是暖咖色族(牛皮纸 `#FBF2E3`、深咖 `#46362A`、蜡笔橙 `#E08A4F`,辅以苔绿/奶油黄/砖红做贴纸语义色);状态色仅表达真实语义;不引入 AI 紫、霓虹、玻璃拟态、过量阴影、三等分模板卡片。交互硬约束(触target/导航语义/动效强度)不变。

单位约定:Taro `designWidth: 375`,源码写 px 即 iOS pt(1px 源码 = 2rpx)。时长单位 ms。

## 2. 色彩 token

### 2.1 语义色板(light / dark)

| token | light | dark |
|---|---|---|
| groupedBackground | `#FFF8EF` | `#14110F` |
| secondaryGroupedBackground | `#FFFFFF` | `#1E1A17` |
| systemBackground | `#FFF8EF` | `#14110F` |
| secondarySystemBackground | `#FFFFFF` | `#1E1A17` |
| label | `#3A2F29` | `#F5EEE2` |
| secondaryLabel | `#7A6E66` | `#AFA69C` |
| tertiaryLabel | `#A0958C` | `#7A726A` |
| quaternaryLabel | `#C4BAB2` | `#524C46` |
| separator | `#E8DFD6` | `rgba(59,61,61,0.15)` |
| opaqueSeparator | `#D9CFC5` | `#3B3834` |
| fill | `rgba(58,47,41,0.14)` | `rgba(245,238,226,0.21)` |
| secondaryFill | `rgba(58,47,41,0.09)` | `rgba(245,238,226,0.14)` |
| tertiaryFill | `rgba(58,47,41,0.06)` | `rgba(245,238,226,0.08)` |
| accent | `#D98B55` | `#E0A070` |
| accentSoft | `#FBE8D8` | `rgba(217,139,85,0.20)` |
| tabBarBackground | `rgba(255,253,249,0.97)` | `rgba(20,17,15,0.94)` |
| navBarBackground | `rgba(255,253,249,0.97)` | `rgba(20,17,15,0.93)` |

M0 说明:小程序端暂只出 light(微信 DarkMode 适配列入 M2 评估);tokens.ts 已同时导出 dark 供后续接 `darkmode: true` + variables。

### 2.2 状态色(两模式共用)

success `#6B7D6B`(柔和绿)/ danger `#E2685B`(克制砖红)/ warning = accent `#D98B55` / 信息蓝 `#007AFF` 仅链接语义。灰阶 systemGray `#8E8E93`、systemGray5 `#E5E5EA`、systemGray6 `#F2F2F7`。

## 3. 字阶

系统字体(不引私有字体名)。fontSize/pt · weight · letterSpacing · lineHeight:

| token | 用途 | 值 |
|---|---|---|
| displayMedium | NavBar 大标题 | 32 · 700 · -0.4 · 1.10 |
| titleLarge | 页面节标题 | 22 · 600 · -0.3 · 1.18 |
| titleMedium | 卡片/行标题、NavBar 收缩标题(17 · 600 · -0.41) | 17 · 600 · -0.24 · 1.26 |
| titleSmall | 次级标题 | 15 · 600 · -0.16 · 1.28 |
| bodyLarge | 正文/列表主文 | 17 · 400 · -0.16 · 1.52 |
| bodyMedium | 次要正文(secondaryLabel) | 15 · 400 · -0.08 · 1.56 |
| bodySmall | 说明文(secondaryLabel) | 13 · 400 · 0 · 1.48 |
| labelMedium | 标签/徽标(secondaryLabel) | 13 · 500 · 0 · 1.38 |
| labelSmall | 辅助微字(tertiaryLabel) | 12 · 500 · 0.05 · 1.36 |

完整字阶(display/headline 全档)见 `tokens.ts`。

## 4. 间距 / 圆角 / 尺寸

- 间距只用 4/8/12/16/24/32;页边距 16,节间距 24,列表间距 12,卡片内边距 16,行内垂直 12,底部安全余量 32。
- 圆角三档:small 8(标签/小件)、continuous 16(卡片/输入框/按钮)、large 24(Sheet/大容器);胶囊 980。
- 行最小高 48(触控目标 ≥44pt);发丝线 0.5;NavBar 高 44(不含状态栏),TabBar 高 64。

## 5. 动效强度

- press 90ms:按压反馈,仅轻微缩放(≤0.97)/变色,无涟漪(NoSplash 对齐)。
- spring 280ms:层级/状态转换(Sheet 弹出、SwipeAction 回弹),Skyline 用 worklet spring。
- page 320ms:页面转场,Skyline 自定义路由对齐 Cupertino 水平推入 + 边缘手势返回。
- 尊重系统"减弱动态效果";动画仅用于层级、反馈、状态转换。

## 6. 导航模式

- B 端页一律 `navigationStyle: custom` + mp-ui `NavBar`:大标题(displayMedium 32)随滚动收缩为居中标题(17/600/-0.41),背景 navBarBackground 半透明,返回箭头 accent 色、图标 22。
- Skyline 页开启手势返回(自定义路由);WebView 回退页用系统左滑/返回键,NavBar 观感不变。
- C 端混写 7 页维持旧系统导航(绿底白字),M0 不动,保证回归口径。

## 7. Skyline 策略

- 按页面粒度声明 `renderer: 'skyline'`(样例页:今日队列、个体列表);前置:`componentFramework: glass-easel` + `lazyCodeLoading: requiredComponents`(已在 app.config 全局)。
- 回退:低端机手感/兼容不达标的页面删除 `renderer` 声明即整页回退 WebView 渲染(docs/32 §9),组件不感知渲染引擎。
- 真机 Gate 判据(M0-6):客户双机 + 开发机,滚动/转场/手势返回与 Flutter 端对照可接受。

## 8. 组件清单(@scolvpet/mp-ui)

M0 最小集(样例页用到的优先):

| 组件 | 要点 |
|---|---|
| NavBar | 大标题滚动收缩、自定义导航、返回/操作位 |
| SectionList | 分组列表容器,组头 labelMedium 大写间距,圆角 16 分组卡 |
| Cell | 列表行:标题 bodyLarge、副文 bodyMedium、右侧 value/chevron、行高 ≥48、发丝分隔 |
| FormRow | 表单行:标签不只靠 placeholder,校验错误贴字段显示 |
| SwipeAction | 行左滑操作,danger/普通两档,spring 回弹 |
| Sheet / ActionPanel | 底部弹层 large 24 圆角、拖拽指示条、动作面板破坏项红字 + 取消分离 |
| SegmentedControl | 9px 圆角、选中白底浮起(dark: secondaryGroupedBackground) |
| Button | filled(accent 底、52 高、圆角 16、17/600)/ outlined(胶囊、opaqueSeparator 描边)/ text(accent 17) |
| Tag | 胶囊小标签 13/500,secondaryFill 底;语义色仅真实状态 |
| Empty | 空态:插画位可选、说明文 bodyMedium、主操作按钮;数据密集页保持原生列表层级 |

后续(M1+):日历、图表容器、大列表虚滚。

## 9. 状态与文案

每个业务页必须补齐:加载/空/错误/离线/无权限/成功/部分数据。文案简洁中文,无营销口吻与内部术语;同一操作在导航、按钮、空态中命名一致(docs/16 §4.3)。

## 10. 真机 Gate 验收清单(M0 出口判据展开)

客户双机 + 开发机,对照 Flutter 端逐项体验:

1. **滚动**:橡皮筋回弹自然;大标题随内容滚入导航栏、17px 小标题在约 44px 行程内淡入;快滚不掉帧。
2. **下拉刷新**:回弹曲线不生硬,刷新指示与页面底色一致。
3. **触反馈**:列表行按压高亮(≈90ms 消退);按钮按压轻微缩放;无涟漪效果。
4. **转场与返回**:进入分包页水平推入;Skyline 页边缘手势返回可用且跟手;返回箭头整槽可点。
5. **弹层**:Sheet/ActionPanel 弹入 280ms spring,遮罩点击可关,破坏项红字、取消分离。
6. **一致性**:与 Flutter 端同屏对照,色彩/字阶/间距无可感偏差;C 端 7 页观感与旧版一致。

任一项不达标:先按页回退 WebView 复测;仍不达标记录到开发日志并在 M1 排期修复。

## 11. 边界

- 业务页禁止散落硬编码颜色/圆角/间距,一律经 tokens/mp-ui。
- 插画只用于品牌、引导、加载、空态。
- 图标:优先微信生态可用的统一图标族(M0 样例先用文本/内置符号,图标族选型 M1 定,不引手绘 SVG)。
