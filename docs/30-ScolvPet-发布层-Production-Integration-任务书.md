# ScolvPet 发布层（Production Integration）任务书

**日期**：2026-07-26
**前置**：CORE CODE FREEZE PASS（`CORE_CODE_FREEZE.md`）。本任务书即冻结文档「下一窗口入口」的展开。
**性质**：发布工程 + 生产接线。不开新业务功能 Wave；涉及核心源码的改动仅限冻结文档解冻条件 1（生产集成暴露的真实契约缺陷）。

---

## 0. 目标与终点

```text
现状：功能层已验证（沙盒/testkey/touristappid/mock SMS/staging 域名）
终点：RELEASE GATE PASS —— 正式 AppID 小程序上架 + App 正式签名 + 真实短信 + 正式域名
```

**阶段锁**（沿用冻结文档）：

```text
P1 发布工程基座（纯代码，无外部依赖，可立即做）
P2 微信身份接线（依赖正式 AppID）
P3 真实短信供应商（依赖签名/模板审批）
P4 正式域名与部署（依赖 ICP 备案）
→ Production Code Freeze → P5 真机双端 E2E + 公网 smoke → RELEASE GATE PASS
```

**外部依赖先行**（今天就该发起申请，全部是周级周期，代码等它们，不是它们等代码）：

| 事项 | 周期 | 阻塞 |
|---|---|---|
| ICP 备案（正式域名） | 2–4 周 | P4、小程序 request 域名 |
| 微信小程序正式 AppID + 微信认证 | 1–2 周 | P2、上架 |
| 短信签名 + 模板审批（阿里云/腾讯云） | 3–7 天 | P3 |
| 商店 keystore / applicationId 封板 | 自控 | App 侧发布 |

---

## P1 · 发布工程基座（无外部依赖）

### P1-1 小程序构建期配置注入，fail-closed（修审计 P1-3.8）

现状：`apps/miniprogram/utils/config.js` 硬编码 `APP_ENV='development'` + staging 域名，
守卫恒为假；`project.config.json` appid 为 `touristappid`。照现状打包，真实客户数据打到 staging。

方案（对标 `make release-android` 的 fail-closed 标准）：

- `utils/config.js` 改为**构建产物**：新增 `scripts/build-miniprogram.sh`，从环境变量
  `MP_APP_ENV` / `MP_API_BASE` / `MP_APPID` 生成 `utils/config.js` 与 `project.config.json` 的 appid 字段；
  仓库内保留 `utils/config.js` 为开发默认值（现状），构建脚本覆盖。
- fail-closed 规则（production 构建时任一命中即退出非零）：
  - `MP_APPID` 为空 / `touristappid` / `wx` 开头长度不对
  - `MP_API_BASE` 命中 `p.scolv.com` 或带端口号（微信要求 443 默认端口）或非 https
  - `MP_APP_ENV != production`
- `Makefile` 增 `release-miniprogram` 目标；`miniprogram-test` 追加一条 fixture 测试：
  用 production 环境变量跑构建脚本 + 故意给坏值断言退出非零。

**验收**：`make release-miniprogram`（坏值）FAIL；（好值）产出的 config.js 无 staging 痕迹。

### P1-2 后端生产就绪自检收口

现状：`loadRuntimeConfigFrom` 已有 `APP_ENV=production` → 强制 `SMS_PROVIDER=http`、拒绝 mock code 等校验（`config_test.go`）。

补齐：

- `/readyz` 增加生产模式检查项输出（sms provider 类型、是否 mock、CORS origin 是否含 staging），
  部署 smoke 可断言。
- `deploy/vps/docker-compose.yml` 拆 `staging` / `production` 两套 env 模板（`.env.production.example`），
  production 模板中 `SMS_MOCK_CODE` 必须为空。

**验收**：production compose + mock SMS 启动直接失败；`/readyz` 断言进 smoke 脚本。

---

## P2 · 微信身份接线（依赖正式 AppID；接线可先用 mock code2Session 完成开发）

### P2-1 数据模型（新迁移 `0040_customer_wechat_identity.sql`）

```sql
customer_wechat_identity (
  id uuid PK,
  openid text UNIQUE NOT NULL,
  unionid text NULL,
  phone text NOT NULL,          -- 绑定时经短信验证的手机号（canonical 形态，复用 0037 规则）
  bound_at timestamptz NOT NULL,
  last_login_at timestamptz,
  revoked_at timestamptz NULL   -- 解绑不删行，审计链
)
```

身份规则：**openid 是登录凭证，phone 是业务真源**。预订/合同仍锚定 phone
（不动冻结的 `reservation_id` 真源模型）；openid 只免掉重复短信验证。

### P2-2 后端端点（`customer_api.go`）

- `POST /v1/public/customer/wechat-sessions`：body `{ js_code }`。
  服务端调 code2Session（AppID/Secret 仅存服务端 env；`APP_ENV=production` 强制非空——并入 P1-2 校验）。
  - openid 已绑定且未解绑 → 直接发 `ct_*` session（复用 0035 现有 session 机制）→ 静默登录
  - 未绑定 → 返回 `{ bind_required: true, wechat_ticket }`（短时一次性票据）
- `POST /v1/public/customer/wechat-bindings`：body `{ wechat_ticket, phone, verification_id, code }`。
  短信验证通过 → 写绑定 → 发 session。即：**首次仍走一次短信实名，之后 wx.login 静默**。
- `DELETE /v1/customer/wechat-bindings/current`：解绑（置 `revoked_at`）。
- code2Session 客户端做成 provider 接口（仿 `sms` 包）：`http` 真实现 + `mock` 测试实现，
  开发/CI 用 mock，不阻塞在 AppID 审批上。
- 频控：wechat-sessions 按 IP，bindings 复用现有验证码频控。

### P2-3 小程序端

- `app.js` 启动：有缓存 token → 校验；无 → `wx.login` → `wechat-sessions` → 静默登录或标记待绑定。
- `detail` / `my-reservations`：已登录态跳过验证码区块；`bind_required` 时展示现有短信流程并带 ticket 提交绑定。
- 短信流程整体保留为降级路径（code2Session 故障时可用）。

**验收**：mock code2Session 下——首次绑定走短信、二次进入静默登录、解绑后回到绑定流程；
契约进 OpenAPI + conformance PASS；fixture 测试覆盖三态。

### P2-4 契约

OpenAPI 补三个端点 + regenerate client（App 侧暂不消费，仅保持契约单一真源）。

---

## P3 · 真实短信供应商

- `sms` 包已有 `HTTPProvider`（webhook 契约 + bearer）。**方案 A（推荐）**：保持 http 契约不变，
  在 VPS 上部署一个薄适配器（阿里云/腾讯云 SDK → 本契约），核心源码零改动，不触冻结。
  **方案 B**：`sms` 包内新增 `aliyun` provider——多一种核心改动，仅当适配器运维成本不可接受再选。
- 验证码策略核对（现有实现逐项确认，缺则补）：有效期 ≤5min、单号频控（60s 重发 + 每日上限）、
  验证尝试次数上限、验证码不入日志。
- staging 保持 mock 不变。

**验收**：staging 用适配器 + 供应商沙箱号真发一条；production env 模板指向适配器。

---

## P4 · 正式域名与部署

- 正式 API 域名（备案完成后）：`Caddyfile` 增 production 站点（443 默认端口、自动 TLS）；
  staging `p.scolv.com:8443` 保留。
- 小程序后台配置 request 合法域名 = 正式 API 域名。
- Web SSR 正式域名同步；`b9cb02c` 已把交易入口指向小程序，Web 侧只读展示确认无预订 POST 残留。
- App（iOS/Android）`API_BASE` 走既有 runtime config 指向正式域名；Android 走 `make release-android` 既有门禁。

**验收**：`scripts/public-reservation-smoke.sh` 打正式域名全绿；小程序真机（体验版）请求不再需要关闭域名校验。

---

## P5 · 封板与 Release Gate

前置合入（并行审计任务负责，本任务书只作为 gate 依赖项跟踪）：

- [ ] 审计 P0-1（logout 幂等重放）已修复合入
- [ ] 审计 P0-2（租户劫持）已修复合入
- [ ] 审计 P1 中标记「发布前必须」项复核（含 P1-3.8 = 本书 P1-1）

Production Code Freeze 后执行：

| Gate | 内容 | 判据 |
|---|---|---|
| G1 | CI 全量（含新 release-miniprogram fixture） | 全绿 |
| G2 | 小程序真机（体验版→正式版）：目录→详情→wx.login 静默/绑定→预订→我的预订→合同 | 全链路人工 PASS |
| G3 | App 真机：CRM 出现 held 预订→确认→客户侧状态更新；hold 过期释放 | PASS |
| G4 | 公网 production smoke（隔离用例 + `/readyz` 断言） | PASS |
| G5 | 短信真发 + 60s 冷却 + 尝试上限真机验证 | PASS |

全过 → **RELEASE GATE PASS**，打 tag 封板。

---

## 排期与依赖图

```text
今天发起：ICP 备案｜AppID+认证｜短信签名/模板   （全部外部，周级）
     │
P1 基座（1 个窗口，纯代码）──────────────┐
P2 微信身份（mock 下 1–2 个窗口）────────┤ 代码全部可在资质到位前完成
P3 短信适配器（0.5 个窗口）─────────────┘
     │  ← 等外部资质到位
P4 域名/部署接线（0.5 个窗口）
     │
Production Code Freeze → P5 Gate → RELEASE GATE PASS
```

**关键路径是 ICP 备案，不是代码。**

## 边界

- 不动冻结域：预订 Golden Path、`reservation_id` 真源、public idempotency、跨客户隔离。
  P2 的 session 发放复用 0035 现有机制，不改预订链。
- 不做：支付、微信手机号一键获取（`getPhoneNumber` 需企业认证后另评估，当前短信绑定已满足实名）、
  CRM 历史手机号 dedupe（维持冻结文档 P1 降级）。
