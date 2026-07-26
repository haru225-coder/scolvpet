# 2026-07-27 · ScolvPet 审计 §8-B 回收与 staging 对账

## 目标

继续 docs/31 收口清单：B 组安全必修项 + staging 部署对账。

## 完成（代码，5 个提交）

- **`92f7d71` Web SVG XSS（§5.1）**：媒体代理改光栅白名单（avif/webp/png/jpeg/gif），
  `image/svg+xml` 拒绝；`sendBinary` 加 `X-Content-Type-Options: nosniff`。回归测试：SVG 上游 → 404 且载荷不回显。
- **`85663cd` XFF 信任（§5.4）**：`clientIP` 重写为可信代理模型——仅当直连 peer 在
  `TRUSTED_PROXY_CIDRS`（默认回环+内网段，可配置）内才采信转发头，且从右向左取第一个
  非代理 IP（右侧为自有代理追加，客户端不可伪造）；所有返回值均为解析后的 IP，
  顺带消灭 varchar(200) 溢出 500。3 条单测覆盖伪造/信任/垃圾头。
- **`2e5fa34` 复合外键（§5.5）**：迁移 0041 重建 12 条 `ON DELETE SET NULL` 约束为
  显式列清单（只清可空引用列，不再碰 NOT NULL owner_id）；db-verify 断言更新 42 迁移。
- **`0a7c451` 移动端构建守卫（§3 ⚠️）**：新增 `make release-ios`（与 release-android 同规则
  fail-closed）；两个 release 目标都强制注入并校验 `API_BASE_URL` + `PUBLIC_SITE_HOST`
  （后者此前连 Android 门禁都漏注入，staging 默认值会进正式包）；README 加警告。
- **`38accc4` assistant confirm 越权（§5.2 半项）**：confirm 执行前把 action 类型映射回
  等价直连路由重跑 `principalCanRequest`，未知类型对非 owner fail-closed 拒绝。
  staff 不能再经 confirm 执行直连会被拒的 enclosure/weight/task 写操作。

## 完成（LA1 staging 对账，详见运维日志 2026-07-27）

- 备份后应用迁移 0034–0041（0000–0033 checksum 零漂移）；账本 42 行 / 74 表
- **事实修正**：审计"无迁移账本"判错（账本在 scolvpet_meta schema），docs/31 §6 已更正
- 交叉编译部署 `38accc4` 二进制；`/readyz` staging 自检输出正确；
  `production-readiness-smoke.sh https://p.scolv.com:8443` PASS；db-verify（LA1 临时容器）全绿
- 近一周全部工作（P0 修复 / Wave1 / P2 微信 mock 链路）现已在 staging 生效

## 验证

```text
go build/vet/test 19 包                  → 全绿
apps/web 16/16 + lint                    → 全绿
make miniprogram-test 15/15              → 全绿
release-ios/release-android 门禁反例      → 全部非零退出、报错精确
LA1: migrate + db-verify + smoke         → 全绿（见运维日志）
```

**状态：已验证**。**待确认**：RBAC GET 全放行（§5.2 另一半）需产品定义 viewer/角色读边界；
token 明文落库（§5.3）需幂等重放契约决策——两项均未动，留给产品决策。

## 备注

- §5.2 的"GET 全角色放行"与 §5.3"token 明文入 idempotency_record"是有意未修：
  前者要先定义各角色读矩阵（影响现有客户端行为），后者改法在"不重放（409）/短 TTL/
  脱敏存储"之间需要拍板，都不是可机械收口的项。
