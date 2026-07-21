# 26 · ScolvPet v0.04（零零四）发布封板

> 封板日期：2026-07-22  
> 仓库：`/Users/snowchan27/Documents/scolvpet`  
> 分支：`codex/openapi-p1-p2-contracts`  
> 移动端版本：`0.0.4+5`  
> 任务性质：在 P0/P1/P2 生产收口完成后，进入零零四版本封板

---

## 0. 一句话

```text
零零四 = 移动端 0.0.4+5：交付→自动记账、助手 confirm 幂等、生产 0033 账本与超时链路已生产验证；
本地全量门禁绿；真机装新包与正式签名仍为待确认。
```

---

## 1. 相对 0.0.4+4 的增量

| 域 | 内容 |
|----|------|
| 财务 | `completeCrmHandover` 完成后按已签发 receipt 写 income，`notes=handover:{id}` 幂等 |
| 助手 | confirm 强制 Idempotency-Key；executed 安全重放 `replayed:true`；tool loop 有写草案时提前返回 |
| 超时 | API `WriteTimeout` 15s→120s；Caddy reverse_proxy read/write 120s |
| 数据 | 生产 ledger 登记 0033；audit/repair 脚本入库 |
| 冒烟 | `public-reservation-smoke` 补 If-Match，receipt 在 complete 前签发，断言 accounting |

---

## 2. 发布门禁（本机 · 封板时）

| 门禁 | 结果 |
|------|------|
| `dart format --set-exit-if-changed lib test` | 0 changed |
| `flutter analyze` | No issues found |
| `flutter test --no-pub` | **187/187** |
| `go test ./...` | ok |
| `git diff --check` | rc=0 |
| `make openapi-lint` | valid |
| `make client-drift` | 1172 files |
| `make db-verify` | 67 tables / 34 migrations / last=0033 / assistant_tables=3 |
| `make reservation-smoke` | PASS（含 income `handover:{id}`） |

---

## 3. 生产已验证（LA1）

| 项 | 证据 |
|----|------|
| healthz | `https://p.scolv.com:8443/healthz` ok |
| ledger | 34 条，last=`0033_assistant_chat.sql`，checksum MATCH |
| 财务 UAT | complete → income 88000，二次 complete 不双记 |
| 助手写路径 | chat 草案 200（local+Caddy）→ confirm 422/200/replayed |
| API 哈希 | `a64147eb9504f805b5a3a0fe139669211f9d66b88c7c524935baf9416805248a`（封板前生产二进制；若后续再部署以新哈希为准） |

---

## 4. 已知限制 / 待确认

1. **真机新包**：需 Flutter 构建装包验收助手 UI；用户偏好非必要不装 iOS SDK，可用现有 Release 验服务端，新客户端能力需 0.0.4+5 包。
2. **正式签名 / Bundle ID**：仍为开发标识 `cn.scolvpet.dev`（见 `mobile-identifiers.properties`）。
3. **生产 Web**：Cloudflare 1000 / 未跑 Web 容器 — 不在本版范围。
4. **代码提交**：工作树功能与 gen 仍可能未拆分 commit；封板不强制 push。
5. **docs/25 v0.05**：全量功能收口任务书仍指向后续 `0.0.5+5` 波次，不阻塞零零四封板。

---

## 5. 回滚

- API：`/opt/scolvpet/bin/scolvpet-api.bak.*` + `docker restart scolvpet-api`
- Caddy：`/etc/caddy/Caddyfile.bak-scolvpet-timeout-*` + reload
- 账本 0033：仅删 `schema_migrations` 行（表保留）或从 `backups/scolvpet-pre-0033-ledger-*.sql.gz` 恢复 meta

---

## 6. 交付状态

- **已写入**：版本 `0.0.4+5`、smoke 对齐、Dart format、超时与财务/助手链路
- **已验证**：本机门禁 + 生产 UAT/助手探针（上一轮）
- **待确认**：真机 0.0.4+5 装包、正式签名、拆分 commit/push
