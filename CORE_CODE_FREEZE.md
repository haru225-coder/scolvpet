# CORE CODE FREEZE PASS

**状态**：✅ **CORE CODE FREEZE PASS**  
**日期**：2026-07-26  
**包**：`ScolvPet_0.0.4+6_audit_round6_fixed_20260726.zip`（Wave G 后）  
**范围**：**业务核心源码冻结** — 不是 Production Code Freeze，也不是 Release Gate PASS。

---

## 阶段锁

```text
✅ CORE CODE FREEZE PASS
        ↓
Production Integration
  微信正式 AppID / wx.login / OpenID
  SMS 真实供应商 / 签名 / 模板
  正式域名 / applicationId / signing
        ↓
Production Code Freeze
        ↓
真机双端 E2E + 公网 production smoke
        ↓
RELEASE GATE PASS
```

---

## 冻结边界（In Scope · 已冻结）

以下业务主链视为**核心源码冻结**，默认不再改动：

| 域 | 冻结内容 |
|----|----------|
| 客户预订 Golden Path | 公开预订 → held → staff confirm → 合同/交付/回执 → 客户只读 |
| 客户身份 | verified phone / `ct_*` session / `RequireVerifiedPhone` |
| 文档真源 | `reservation_id` 为 contact / hamster / handover 唯一身份真源 |
| Public idempotency | claim-row 状态机（`0038`），禁止持 pool 连接跑嵌套 DB callback |
| Customer OpenAPI | 强类型 client（非 `void`） |
| Android release gate | `make release-android` fail-closed（正式 AppID / HTTPS / keystore） |
| 小程序基础 CI | JS syntax + JSON parse fixtures |
| 跨客户隔离 | 文档与客户数据不可跨绑定 |

### 可执行回归（优先于文档声明）

`scripts/public-reservation-smoke.sh` 钉死：

```text
reservation A + contact B              → reject
reservation A + handover(reservation=NULL) → reject
reservation A + handover(reservation B)    → reject
reservation A + fake hamster_name      → 使用 reservation 对应 hamster
正常 reservation → handover → contract/receipt → PASS
```

Store 并发（需 `DATABASE_URL`，CI 已注入，缺表 FAIL 不 SKIP）：

```text
TestRunPublicIdempotentConcurrentSendOnce
TestRunPublicIdempotentSameKeyNestedDBNoStarvation   # MaxConns=2
TestRunPublicIdempotentNoPoolStarvationUnderNestedDB
```

---

## 明确不在本冻结内（下一阶段）

| 项 | 说明 |
|----|------|
| 微信正式 AppID | 外部申请 + 配置 |
| `wx.login` / OpenID 绑定 | **需要源码接线**（Production Integration） |
| 真短信供应商 / 签名 / 模板 | 外部 + 接线 |
| 正式域名 / TLS / 部署 | 外部 |
| 商店 applicationId / signing / keystore | 外部 + 配置封板 |
| 真机双端 E2E | Release 前 |
| 公网 production smoke | Release 前 |
| CRM 历史手机号 dedupe | P1；生产若 **fresh DB** 可接受 0037 现状 |

---

## 解冻条件（仅此三种）

从本日起，**只有**下列情况允许改动业务核心源码：

1. **Production Integration** 暴露真实契约缺陷（接口/身份/幂等等无法在集成层单独修）；
2. **E2E / 真机** 发现 P0 或阻断主链的 P1；
3. **安全 / 数据隔离** 出现新的确定性漏洞。

否则禁止：顺手重构 repository、DTO、页面架构、状态管理、API 分层、风格统一等。

---

## Wave G 证据摘要（冻结依据）

- `RunPublicIdempotent`：claim → 释放连接 → `fn()` → complete；临时 Postgres 下 `MaxConns=2` 同 key 嵌套 DB 并发 PASS。
- CI：`api-test` 注入 `DATABASE_URL` + `AUTH_TEST_DATABASE_URL`；有 URL 缺表 → FAIL。
- Migration 含 `0038_public_idempotency_state.sql`。
- Reservation → Document 真源、typed Customer OpenAPI、Android fail-closed 维持 PASS。
- 本地 `go test ./...`（Go 1.26）PASS。

---

## 生产数据假设（P1 降级）

**生产从 fresh DB 起服**，不承诺迁移历史测试 CRM 手机号碎片。  
`0037` 仅做常见形态 canonicalization，不做 identity merge / UNIQUE。若日后要保留脏历史数据，必须另开 dedupe 任务并解冻相关迁移。

---

## 下一窗口入口

```text
Production Integration
  1. 微信 AppID + wx.login + OpenID 身份模型接线
  2. SMS 真实供应商
  3. 正式域名 / applicationId / signing
→ 再 Production Code Freeze → 真机 E2E → RELEASE GATE
```

**不再开新的业务功能 Wave。**
