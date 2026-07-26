# 2026-07-27 · ScolvPet 小程序 B 端迁移 M0 基建(Taro 工程 + 设计规范 + mp-ui + 样例页)

**任务书**:`docs/32`(总纲)/ `docs/33`(M0 展开)
**分支**:`codex/openapi-p1-p2-contracts`
**范围**:M0-1 至 M0-6 全部代码侧;后端零改动;决策不重开。

## 交付

| 项 | 状态 | 说明 |
|---|---|---|
| M0-1 Taro 工程基座 | **已验证** | `apps/miniprogram-next`:Taro 4.2.1 + React + TS,weapp,webpack5;`npx taro build` 绿。分包地图:主包(登录/今日/mp-ui/C 端 7 页)+ 6 个 B 端分包位(animals/breeding/crm/contracts/finance/ai)。体积门禁 `scripts/check-mp-bundle-size.mjs`(单分包硬限 2MB/预警 1.6MB),当前主包 0.368MB、总 0.374MB |
| M0-1 fail-closed 构建 | **已验证** | `scripts/build-miniprogram-next.sh` 1:1 移植旧脚本全部校验(AppID 格式/https/禁 p.scolv.com/禁端口/防注入),`make release-miniprogram-next`;坏值 fixture 测试 8 例全过(`test/release_gate.test.mjs`) |
| M0-2 设计规范与 token | **已写入** | `docs/34-ScolvPet-小程序仿iOS设计规范.md`;TS token 真源 `packages/mp-ui/src/tokens.ts`(从 `ios_theme.dart` 手工换算导出,light/dark 色板 + 状态色 + 字阶 + 间距圆角 + 动效 90/280/320ms) |
| M0-3 mp-ui 组件库 | **已验证** | NavBar(大标题滚动收缩)/Section(List)/Cell/FormRow/SwipeAction/Sheet/ActionPanel/SegmentedControl/Button/Tag/Empty;vitest 快照 + token 对齐断言,18 测试全绿 |
| M0-4 TS 契约客户端 | **已验证** | `tools/generate-ts-client.sh`(固定 jar 7.23.0,typescript-fetch)→ `generated/ts/scolvpet-api`(844 文件);`tools/check-generated-ts-client.sh` drift 检查通过并入 `make ci`;`prepare-generated-ts.mjs` 补 Null 模型桩 + @ts-nocheck。Taro adapter `src/api/`(Taro.request 桥 + Bearer token + 写请求 Idempotency-Key),适配器单测 5 例 |
| M0-5 C 端 7 页混入 | **已验证** | 7 页原生文件原样并入 `src/pages/`(路径不变,保小程序码深链),Taro 混写管线编译进 dist;旧 `app.js` 逻辑移植 `app.ts`(globalData/saveCustomer/_launchEntry/静默登录),旧 `app.wxss` 并入 `app.css`;15 个迁移单测全过。**旧 `apps/miniprogram` 未删**(待真机回归 PASS) |
| M0-6 样例页 | **已写入** | 今日照护队列(主包,Skyline+自定义导航,SwipeAction/SegmentedControl/ActionPanel)+ 个体列表(animals 分包,Skyline);全假数据只读 |
| CI | **已验证** | `make miniprogram-next-test`(vitest 18 + 原生 15)、`make miniprogram-next-build`(taro build + 体积门禁)、`ts-client-drift` 均绿并已串入 `make ci`;`tsc --noEmit` 全绿 |

## 关键工程决策(M0 内自由度,未触碰 docs/32 拍板)

1. **原生混写走 Taro 混写管线**而非手工 copy:Taro 对 app.config 声明的原生页一等编译(utils require 一并打包),消除 copy 覆盖顺序风险。
2. **无 tabBar**:微信要求 tabBar ≥2 项,M0 主包只有今日+登录,真实 Tab 结构 M1 定。
3. `.npmrc` 固定 `legacy-peer-deps`(Taro peerOptional vite@4 与 vitest vite@5 冲突;编译走 webpack5 不受影响);webpack 按 taro-loader peer 锁 5.91.0。
4. 生成 TS 客户端统一盖 `@ts-nocheck`(生成物非 strict 设计),app 侧 tsconfig 保持全 strict。
5. 全局 window 沿用旧 C 端配置(绿底导航),新 B 端页一律 `navigationStyle: custom`;C 端观感零变化。

## 踩坑记录

- `@tarojs/taro-loader@4.2.1` 要求 webpack 精确 `5.91.0`(声明 5.97 会 ERESOLVE)。
- `babel-preset-taro` 的 `@babel/preset-react`/`preset-typescript` 在 legacy-peer-deps 下不会自动安装,需显式列入 devDependencies。
- 工程内 package(src 外)须加 `mini.compile.include`,否则 webpack 对 TS 报 ModuleParseError;`compile` 键在 `mini` 段内,不在顶层。
- openapi-generator 7.23 typescript-fetch 对 nullable oneOf 会 import `./Null` 但不生成该模型,且引用不存在的 `NullToJSONTyped`——prepare 脚本补桩解决。

## Gate 与后续

- **真机手感 Gate:待确认**(用户侧):微信开发者工具导入 `apps/miniprogram-next`,预览今日/个体两样例页,客户双机 + 开发机对照 Flutter 端验收滚动/转场/手势返回;C 端 7 页真机回归后方可删旧目录。
- Gate PASS → 开 M1(B 端登录、今日队列、任务、个体/笼舍浏览、快录)。
- 外部申请四项(ICP/AppID+类目/微信认证/短信签名/订阅消息模板)仍在用户侧,与代码不互相阻塞(docs/33 §4)。

## 提交

- `feat(contracts): typescript-fetch client generation with drift gate (M0-4)`
- `feat(miniprogram-next): Taro+Skyline base, mp-ui kit, blended C pages, sample screens (M0)`
- 本日志与 INDEX 更新单独提交;全部显式 pathspec。
