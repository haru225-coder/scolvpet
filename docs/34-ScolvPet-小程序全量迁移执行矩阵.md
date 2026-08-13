# ScolvPet 小程序 B 端全量迁移执行矩阵

本文件记录 `docs/32-ScolvPet-小程序B端全量迁移任务书.md` 的实际执行状态。页面只有在真实 API、写操作、错误/空态和测试都具备后，才标记为“已写入”；静态样例不计入完成。真实账号、后端配套和真机链路仍单独标为“待确认”。

| 期次 | 业务域 | 当前状态 | 小程序入口 |
| --- | --- | --- | --- |
| M1 | B 端短信登录与会话 | 已写入（含 wx.login 绑定；LA1 staging 路由已验证；真实账号/真机待确认） | `pages/login/index`、`api/internal/httpapi/breeder_wechat.go` |
| M1 | 今日照护队列、任务完成 | 已写入（真机待确认） | `pages/today/index` |
| M1 | 个体浏览与检索 | 已写入（真机待确认） | `packages/animals/index/index` |
| M1 | 体重/健康快录 | 已写入（真机待确认） | `packages/animals/detail/index` |
| M2 | 个体 CRUD、批量 | 已写入（个体完整档案字段、核心表型目录、头像媒体上传/移除已接入；真机待确认） | `packages/animals/*` |
| M2 | 窝次、性别、个体化 | 已写入（真机待确认） | `packages/litters/*` |
| M2 | 繁育向导与日历 | 已写入（真机待确认） | `packages/breeding/*`、`packages/reminders/*`（含日历聚合） |
| M2 | 订阅提醒、离线只读快照 | 已写入（授权同步、任务/预订事件队列与后台 worker；LA1 staging 0042–0044 与路由已验证；正式模板/配置及真机待确认） | `packages/reminders/*`、`src/offline/snapshots.ts`、`api/internal/httpapi/wechat_subscriptions.go`、`api/internal/worker/wechat_subscriptions.go` |
| M3 | CRM、合同、财务 | 已写入（合同/回执模板管理、记账分类与分类选择、PDF 字体配置及真机待确认） | `packages/crm/*`、`contracts/*`、`finance/*`、`api/internal/httpapi/document_pdf.go` |
| M3 | 公开主页、CSV | 已写入（CSV 导入；导出/备份入口已按 docs/28 Wave0 隐藏；真机及订阅配套待确认） | `public-site/*`、`data-center/*` |
| M4 | AI、遗传模拟、Stud | 已写入（AI 快捷问题/深链、遗传目录/目标交配/实际反馈/历史摘要、公开个体资料管理均接入；真机待确认） | `packages/ai/*`、`genetic/*`、`stud/*` |
| M4 | 数据中心汇总 | 已写入（CSV 映射、逐行结果、错误报告、重试；导出/备份创建入口已隐藏，worker 未做） | `packages/data-center/*` |

平台专属能力（IAP、WidgetKit、APNs）按总纲保留在 App；小程序侧以权益展示、订阅消息和引导完成替代。

范围收敛（2026-07-29）：笼舍管理、成员管理与增长获客不面向客户交付，取消其独立小程序入口与验收项；后端笼位数据和 RBAC 保留为内部基础设施。

## 本轮验证

- `npx tsc --noEmit`：通过。
- `npm run lint`：通过。
- `npm test -- --run`：6 个测试文件通过；37 项通过，1 项按环境跳过，含 owner/viewer/staff 能力门禁、关键迁移面和空任务队列入口回归。
- `make miniprogram-next-test`：通过；Vitest 37 项通过、原生迁移测试 18 项通过。
- `make api-test`：受控环境复跑全部通过，含 B 端微信与 PDF 渲染测试。
- `make openapi-lint`、`make openapi-conformance`：通过；当前 222 个 OpenAPI 操作与 227 个 Go 路由对照通过。
- `make ts-client-drift`：通过，864 个生成文件无漂移。
- `make miniprogram-next-build`：通过（Webpack 使用 `--no-check`，避免本机 Taro 配置检查 worker 异常），52 个构建入口。
- `make release-miniprogram-next`：使用正式 API 主机 `https://api.scolvpet.cn` 与工程 AppID 的生产构建通过；生产配置随后已恢复为开发默认，未上传代码包。
- 分包体积门禁：通过，总包约 1.152 MB。
- `node tools/mp-dist-smoke.mjs apps/miniprogram-next/dist`：通过，52 个页面入口。
- LA1 staging：迁移账本 45 条、最新 `0044_breeder_wechat_subscription_events.sql`；三张微信表存在；新 API 二进制哈希与本地交叉编译产物一致；`production-readiness-smoke.sh https://p.scolv.com:8443` 通过；微信登录/订阅路由返回业务级 4xx（非 404）。
- PDF 验证：内置 Helvetica 回退 PDF 与配置 Noto Sans CJK 的中文 PDF 均通过 `pdfinfo`/`pdftoppm`，渲染版式已目视检查。
- 微信开发者工具 Stable 2.01.2510290：已加载正确工程 `apps/miniprogram-next`，当前 `pages/today/index` 模拟页可见；运行时错误 0、Problems 面板 0，保留 9 条系统/渲染兼容提示；真实设备扫码/预览仍待确认。
- 开发者工具兼容收口：`tsconfig.json` 已按工具内置 TypeScript 4.1.2 调整为 `moduleResolution: node`，并移除项目未使用的 `resolveJsonModule`；本地 `npx tsc --noEmit` 通过。
