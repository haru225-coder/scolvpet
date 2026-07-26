# 2026-07-27 · ScolvPet 审计 §8-D 工程面回收

## 目标

清掉 docs/31 §5.6–5.12 中可机械收口的工程面遗留（不含需产品决策的项）。

## 完成（6 个提交）

- **`c2cde66` §5.6+§5.7 移动端**：`I2Controller.resetForLogout()` 清空导入向导
  （importStage/importJob/importRows）、称重批次、快照/详情态与草稿；登出改走
  `AppServices.logout()` 统一收口（mine_page 注入回调，测试兜底回落 state.logout）。
  两处 `TextEditingController`（correction_reason_sheet、pedigree 填入面板）补
  `.whenComplete(dispose)`。新增 reset 单测。
- **`1903e23` §5.8 密钥面**：AI/XAI key 从全局 export 改为仅 `api-run`/`smoke`
  目标级导出（其余配方子进程不再见到付费 key）；release-android 的 keystore 密码
  **只允许来自环境变量**，从版本控制文件读密码的通道封死；.gitignore 补
  `*.jks/*.keystore/*.p12/**/key.properties`。
- **`f571e94` + `744abdc` §5.12**：新增每小时清理任务
  `CleanupExpiredAuthArtifacts`（idempotency_record / auth_public_idempotency /
  auth_rate_limit 48h / revoked_token），四张表不再无界增长；
  `ParseAccessTokenContext` 锁收窄到只护内存 map——解析/HMAC 纯计算无锁、
  持久层撤销查询移出锁外，**每个带 Bearer 请求的全局串行化解除**；
  `IsAccessTokenRevoked` 的每请求 DELETE 移除（语义不变：SELECT 本就过滤过期行）。
- **`a82c74c` §5.11 契约漂移**：`deleteCurrentSession` 的 Idempotency-Key 改为
  可选、删除 Idempotency-Replayed 响应头声明，与实现（登出天然幂等、不重放）对齐；
  顺带修掉 CustomerReservation 两处 3.0 `nullable`（P2 遗留，**openapi-lint 在
  HEAD 上本来就是红的**），dart client regenerate + client-drift PASS。

## 验证

```text
go build/vet/test 20 包            → 全绿
flutter analyze / test             → 零问题 / 216 全过
openapi-lint                       → 修复后 Valid（此前 2 错）
conformance / client-drift         → PASS / PASS（1228 文件）
```

**状态：已验证**（本地；DB 门禁用例由 CI 带 DATABASE_URL 复验）。

## 仍开放（全部需产品决策，非工程遗留）

RBAC GET 读矩阵（§5.2 另一半）、token 明文入 idempotency_record 的重放契约（§5.3）、
邀请显式接受端点、docs/28 P0-2/P0-4/P0-5 与健康/CRM/财务纠错、§5.9 测试剧场改写。
