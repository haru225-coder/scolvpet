# ScolvPet 双周迭代：RBAC 与跨端验证

- 日期：2026-07-27
- 自动化：熊舍管家 200% 双周迭代（Automation ID: 200）
- 状态：已写入 / 已验证 / 待确认

## 本轮目标

复核 I1 基线和工作区未提交改动，在不改变冻结领域模型的前提下，优先收口 owner 安全与可验证性：补齐敏感 GET 的 viewer/unknown 角色矩阵、同步 OpenAPI 生成客户端，并复验迁移、Outbox、Flutter、Web、小程序、媒体和公开预订链路。

## 已写入

1. `api/internal/httpapi/rbac.go`：GET/HEAD/OPTIONS 不再对所有角色直接放行；viewer 对合同、收据、会计、组织成员、数据中心等敏感路径按路径拒绝，unknown role 失败闭合，已保留普通运营读取。
2. `api/internal/httpapi/rbac_test.go`：新增 viewer 敏感读取拒绝和 unknown role GET 拒绝测试。
3. OpenAPI 重新生成 Dart 客户端，补齐 breeder WeChat identity/subscriptions 请求、响应及模型。
4. `docs/engineering/双周完成度.md`：完成度 108/200 → 116/200，新增分数绑定可运行验证证据。
5. `validation/biweekly-2026-07-27-rbac-flutter-report.txt`：记录命令、结果、阻断和待确认项。

## 已验证

- `go test ./... -count=1`：Go 全包通过。
- `make openapi-lint`、`make openapi-conformance`、`make migration-drift`：全部通过；OpenAPI 222 operations、Go mux 227 operations、允许差异 5、双向 gaps 0。
- `make db-verify`：全新库、复跑、seed replay、checksum drift 通过；45 migrations、78 tables、75 enums。
- I1 smoke、Outbox reliability、公开预订 smoke、媒体 smoke、objectstore 本地 suite：通过。
- Dart drift 1258 files、TS drift 864 files：通过。
- Flutter analyze、216 项测试：通过；临时卷 iOS Simulator 无签名构建通过。
- Web lint/test/build：16/16 测试通过并产出 server.mjs；旧小程序测试通过；小程序 next 38 passed、1 skipped，lint 通过。
- `git diff --check`：通过。

## 待确认

- 本机缺少 Android SDK，`flutter build apk --debug` 待 SDK 补齐后重跑。
- 工作区 iOS build/ 会受到 Finder 扩展属性影响；临时卷构建已验证，真机、正式签名和安装升级待确认。
- S3/MinIO live、LA1 staging 迁移/部署、正式微信与短信供应商、域名/CDN、备份恢复演练待外部环境。
- CSV session 全库化、繁育非 happy-path UI、健康纠错、模拟历史实体、导出/备份 worker 为下一双周候选。

## 相关证据

- [`validation/biweekly-2026-07-27-rbac-flutter-report.txt`](../../../validation/biweekly-2026-07-27-rbac-flutter-report.txt)
- [`docs/engineering/双周完成度.md`](../../../docs/engineering/双周完成度.md)
- [`api/internal/httpapi/rbac.go`](../../../api/internal/httpapi/rbac.go)
- [`api/internal/httpapi/rbac_test.go`](../../../api/internal/httpapi/rbac_test.go)
