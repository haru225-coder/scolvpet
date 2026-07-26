# scolvpet-miniprogram-next · 工程简报

ScolvPet B 端小程序(docs/32 迁移总纲 / docs/33 M0 展开 / docs/34 设计规范)。
Taro 4.2.1 + React 18 + TypeScript,编译目标 weapp,Skyline 按页开启、可整页回退 WebView。

## 一屏状态

- **M0 已完成**(基建/规范/mp-ui/契约客户端/C 端混写/样例页),CI 面全绿。
- **出口 Gate:真机手感验收待确认**(见下方清单);PASS 后开 M1。
- 旧 `apps/miniprogram/` 在 C 端真机回归 PASS 前**不删**。

## 结构

```text
src/
  app.ts / app.config.ts   入口:移植旧 app.js(globalData/saveCustomer/_launchEntry/静默登录),
                            原生页 getApp() 兼容;分包地图与 Skyline 全局前置在 app.config
  pages/today, pages/login  主包 Taro 页(today=Skyline 样例;login=静态版式,M1 接线)
  pages/{index,catalog,detail,pedigree,simulate,my-reservations,contract}
                            C 端 7 页原生混写(与 apps/miniprogram 同源;路径不变保小程序码深链)
  utils/                    原生 CommonJS(config.js 为 fail-closed 构建注入点;api.js 仅服务混写页,不再增长)
  api/                      契约客户端 adapter:Taro.request 桥 + Bearer token + 写请求 Idempotency-Key
  packages/{animals,breeding,crm,contracts,finance,ai}
                            B 端分包位(animals 含个体列表样例;其余 M1+ 填充)
packages/mp-ui/             @scolvpet/mp-ui:tokens.ts(真源 ios_theme.dart)+ 11 个组件 + 快照测试
```

## 命令

| 命令 | 作用 |
|---|---|
| `npm run dev:weapp` / `build:weapp` | 开发/构建(开发默认 touristappid + staging) |
| `npm test` / `npm run test:native` | vitest(mp-ui + adapter)/ 迁移的 C 端原生单测 |
| `make miniprogram-next-test` | 上两者合并(已入 `make ci`) |
| `make miniprogram-next-build` | taro build + 分包体积门禁(单分包硬限 2MB/预警 1.6MB) |
| `make release-miniprogram-next` | fail-closed 注入(AppID/https/禁 staging/禁端口)+ 生产构建 + 门禁 |
| `make generate-ts-client` / `ts-client-drift` | 契约客户端再生成 / drift 检查(已入 `make ci`) |

微信开发者工具导入本目录,产物在 `dist/`。

## 硬约定

1. **接口只走 `@scolvpet/api-client`(generated)+ `src/api` adapter**;禁止手写 fetch/request 封装。契约改动:先改 `specs/api/openapi.yaml` → `make generate-ts-client`。
2. **视觉只走 tokens/mp-ui**,业务页不散落硬编码颜色/圆角/间距;改视觉先改 `ios_theme.dart` → 同步 `tokens.ts` → docs/34。
3. Skyline 按页 `renderer: 'skyline'`;不达标页删该行即回退 WebView,组件不感知引擎。
4. 提交必须显式 pathspec(仓库并行窗口纪律);`dist/`、`node_modules/` 不入库。
5. `.npmrc` 固定 legacy-peer-deps(Taro peerOptional vite@4 与 vitest vite@5 冲突;webpack5 路径不受影响);webpack 按 taro-loader peer 锁 5.91.0。

## 真机 Gate 清单(M0 出口,客户双机 + 开发机)

- [ ] 今日页:大标题随滚动滚入导航栏、小标题淡入;下拉刷新回弹;列表按压高亮;左滑操作与动作面板
- [ ] 个体页(分包):转场进入、手势返回、滚动橡皮筋
- [ ] 与 Flutter 端对照:滚动/转场/手势返回手感可接受(docs/16 口径)
- [ ] C 端 7 页真机回归(入口/目录/详情预订/血统/模拟/我的预订/合同),观感与旧版一致
- [ ] 低端机检查 Skyline 兼容;不达标页面记录并回退 WebView

## M1 交接(Gate PASS 后)

B 端登录接线(短信契约 + wx.login 三态镜像,后端解冻单独立项)、今日队列/任务真数据、
个体/笼舍浏览检索、体重/健康快录;Tab 结构与图标族选型在 M1 定。
已知天花板:SwipeAction 位移走 setState(见源码 ponytail 注释),真机不过再上 Skyline worklet。
