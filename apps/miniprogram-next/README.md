# scolvpet-miniprogram-next · 工程简报

ScolvPet B 端小程序(docs/32 迁移总纲 / docs/33 M0 展开 / docs/34 设计规范)。
Taro 4.2.1 + React 18 + TypeScript,编译目标 weapp,Skyline 按页开启、可整页回退 WebView。

## 一屏状态

- **M0 已验证**(基建/规范/mp-ui/契约客户端/C 端混写/样例页),CI 面全绿。
- **M1–M4 前端业务页已写入**：真实 API、写操作、权限/会话、错误态、空态、离线只读快照和数据中心入口均已接入；个体完整档案字段与核心表型目录、个体头像媒体上传/移除、AI 任务草案预填、遗传目标交配与反馈闭环、公开个体资料管理、记账分类管理、合同/回执模板管理与 CRM 关联选择也已接入。
- **B 端微信登录已写入**：`wx.login` → 服务端 `bwt_*` 一次性绑定票据 → 手机号验证码绑定；已绑定身份直接复用 staff Bearer 会话，和 C 端 `ct_*` 隔离。
- **全量出口 Gate 待确认**：LA1 staging 已完成 0042–0044 迁移、API 二进制更新和 readiness/路由验证；正式环境的 HTTP/微信模板配置、真实账号和客户双机真机链路仍需外部验收。合同/回执 PDF、订阅授权同步、任务/预订事件队列与服务端 worker 已写入；AI 页已补齐 Flutter 对照的快捷问题、清空和业务深链入口。
- 旧 `apps/miniprogram/` 在 C 端真机回归 PASS 前**不删**。
- **产品范围**：不建设面向客户的笼舍管理、成员管理或增长获客入口；后端笼位数据与 RBAC 仅作为内部基础设施保留。

## 结构

```text
src/
  app.ts / app.config.ts   入口:移植旧 app.js(globalData/saveCustomer/_launchEntry/静默登录),
                            原生页 getApp() 兼容;分包地图与 Skyline 全局前置在 app.config
  pages/today, pages/login  主包 Taro 页(today/登录真实接线)
  pages/{index,catalog,detail,pedigree,simulate,my-reservations,contract}
                            C 端 7 页原生混写(与 apps/miniprogram 同源;路径不变保小程序码深链)
  utils/                    原生 CommonJS(config.js 为 fail-closed 构建注入点;api.js 仅服务混写页,不再增长)
  api/                      契约客户端 adapter:Taro.request 桥 + Bearer token + 写请求 Idempotency-Key
  packages/{animals,litters,reminders,breeding,crm,contracts,finance,
            genetic,data-center,ai}
                            B 端 M1–M4 分包业务页
packages/mp-ui/             @scolvpet/mp-ui:tokens.ts(真源 ios_theme.dart)+ 11 个组件 + 快照测试
```

## 命令

| 命令 | 作用 |
|---|---|
| `npm run dev:weapp` / `build:weapp` | 开发/构建（开发配置读取 `project.config.json`，API 默认 staging） |
| `npm run lint` / `make miniprogram-next-lint` | ESLint 静态检查 |
| `npm test` / `npm run test:native` | vitest(mp-ui + adapter + M1–M4 迁移面)/ 迁移的 C 端原生单测 |
| `make miniprogram-next-test` | 上两者合并(已入 `make ci`) |
| `make miniprogram-next-build` | taro build + 分包体积门禁(单分包硬限 2MB/预警 1.6MB) |
| `make release-miniprogram-next` | fail-closed 注入(AppID/https/禁 staging/禁端口)+ 生产构建 + 门禁 |
| `scripts/package-miniprogram-next.sh OUTPUT.zip` | 源码交付包；显式排除 `dist/`、`project.private.config.json`、`node_modules/` |
| `make generate-ts-client` / `ts-client-drift` | 契约客户端再生成 / drift 检查(已入 `make ci`) |

微信开发者工具导入本目录,产物在 `dist/`。

### 微信合法域名清单

发布前必须在微信开发者工具之外登记三类通道的域名；`urlCheck` 不只校验普通 API 请求：

| 通道 | 代码入口 | 登记口径 |
|---|---|---|
| `request` | `src/api/taro-fetch.ts`、原生页 `src/utils/api.js` | 正式 API：`https://api.scolvpet.cn`（由 `API_BASE` 注入） |
| `downloadFile` | `src/api/client.ts`、`packages/data-center/actions` | 登记 API 域名；若 `downloadUrl` 返回绝对对象存储 URL，还要登记该 URL 的 origin |
| `uploadFile` | `packages/animals/detail`、`packages/data-center/actions` | 每个预签名 `uploadUrl` 的 origin 都必须登记；对象存储 endpoint 随部署配置注入，不能假设与 API 同域 |

`downloadFile` / `uploadFile` 的域名应从正式接口响应中的 `downloadUrl` / `uploadUrl` 逐一核对。数据中心下载完成后使用微信 `FileSystemManager.saveFile`，不再调用已废弃的 `Taro.saveFile`。

## 开发环境一键登录

开发配置下，登录页会显示“开发环境一键登录（免扫码）”。点击后会使用演示账号
`13800138000` 和 staging Mock 验证码自动换取真实 B 端会话，再进入今日页；后续页面
仍然请求真实 staging API。若在登录页先填写其他测试手机号，则一键入口会使用该手机号。

该入口只由 `APP_ENV=development` 控制显示；`make release-miniprogram-next` 生成生产配置后
不会显示开发入口。

## 硬约定

1. **接口只走 `@scolvpet/api-client`(generated)+ `src/api` adapter**;禁止手写 fetch/request 封装。契约改动:先改 `specs/api/openapi.yaml` → `make generate-ts-client`。
2. **视觉只走 tokens/mp-ui**,业务页不散落硬编码颜色/圆角/间距;改视觉先改 `ios_theme.dart` → 同步 `tokens.ts` → docs/34。
3. Skyline 按页 `renderer: 'skyline'`;不达标页删该行即回退 WebView,组件不感知引擎。
4. 提交必须显式 pathspec(仓库并行窗口纪律);`dist/`、`node_modules/` 不入库。
5. `.npmrc` 固定 legacy-peer-deps(Taro peerOptional vite@4 与 vitest vite@5 冲突;webpack5 路径不受影响);webpack 按 taro-loader peer 锁 5.91.0。

## 真机 Gate 清单(全量迁移出口,客户双机 + 开发机)

- [ ] 今日页:大标题随滚动滚入导航栏、小标题淡入;下拉刷新回弹;列表按压高亮;左滑操作与动作面板
- [ ] 个体页(分包):转场进入、手势返回、滚动橡皮筋
- [ ] 与 Flutter 端对照:滚动/转场/手势返回手感可接受(docs/16 口径)
- [ ] C 端 7 页真机回归(入口/目录/详情预订/血统/模拟/我的预订/合同),观感与旧版一致
- [ ] 低端机检查 Skyline 兼容;不达标页面记录并回退 WebView

## 发布门禁（fail-closed）

三道阁，缺一道都不允许开发配置漏到生产：

1. **构建时**（`config/index.ts` 的 `assertBuildConfig()`）：每次 `taro build/dev` 先跑。校 `APP_ENV` 合法、生产下 `API_BASE` 必须 https + 无显式端口 + 非 staging、`DEV_LOGIN_*` 必须为空、`urlCheck` 必须为 true、`uploadWithSourceMap` 必须为 false、appid 形状合法；并校 `generated/ts/scolvpet-api/src` 存在（本应用无法在 monorepo 外构建，缺失时直接报错并提示 `make generate-ts-client`）。
2. **发布流水线**：设 `MP_REQUIRE_PRODUCTION_CONFIG=1`，若 `src/utils/config.js` 仍是开发默认值（注入脚本未跑或跑失败），构建直接崩。
3. **运行时**（`config.assertRuntimeConfig()`，`app.ts onLaunch`）：`APP_ENV` 非法值或生产指向非正式主机时抛错。另外 `config.js` 在 `APP_ENV !== 'development'` 时导出的 `DEV_LOGIN_PHONE/CODE` 被强制清空，即使注入脚本漏改，登录页的开发一键入口也不会出现、且无内置回退凭据。

`src/sitemap.json` 只开放 C 端页；`packages/*`、`pages/today/index`、`pages/login/index` 均 disallow，避免 B 端经营页被微信索引。

## 当前待确认项

- B 端订阅授权登记、投递审计与 Mock/正式 HTTP 通道已写入；正式环境需在微信公众平台申请任务/预订模板，并配置 `WECHAT_SUBSCRIPTION_PROVIDER=http`、`WECHAT_TASK_TEMPLATE_ID`、`WECHAT_RESERVATION_TEMPLATE_ID`。
- PDF 服务端生产环境需设置 `SCOLVPET_PDF_FONT_PATH` 指向可读的 CJK 字体（当前仓库验收使用 `apps/mobile/assets/fonts/NotoSansSC-Variable.ttf`），否则保留 ASCII 业务标识并使用内置 Helvetica。
- 微信正式 AppID、认证、订阅模板、request 合法域名和客户真机账号需要在开发者工具之外完成。
- LA1 staging 当前仍使用 mock SMS/微信通道；正式环境需另行配置真实凭据、迁移 0042–0044 和任务/预订模板 ID。
- 乐观并发：`animals/detail`、`breeding/detail`、`litters/detail`、`data-center/actions`、`contracts/*` 已带 `ifMatch`；`finance/*`、`crm/create`、`reminders/*` 的写操作目前不传版本号，需先根据 `specs/api/openapi.yaml` 确认这些端点是否要求 If-Match，再补。
- 本应用的 `npm test`（vitest）与 `npm run test:native` 需在 monorepo 内执行；`test/release_gate.test.mjs` 在拿不到 `scripts/build-miniprogram-next.sh` 时会自动 skip（不再以退出码 127 失败）。
- 开发者工具已可导入本目录并编译；当前已复核 `pages/today/index` 模拟页、运行时错误 0、Problems 面板 0。正式构建门禁已用 `https://api.scolvpet.cn` 通过；上传/提交审核前仍需完成微信后台正式配置和真实设备验收。

本项目的微信开发者工具���入路径是 `/Users/snowchan27/Documents/scolvpet/apps/miniprogram-next`；仓库根目录的 `project.config.json` 是旧 C 端混写入口，不用于本轮 B 端全量验收。
