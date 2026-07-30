# 客户微信手机号授权 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在客户详情与“我的预约”中以微信 `getPhoneNumber` 为主建立独立 Customer Session，并只在授权不可用时保留短信备用。

**Architecture:** `wx.login` 继续换取 OpenID 与 10 分钟一次性 ticket；App 私有保存 ticket，原生页面只把 `phone_code` 交给桥接。服务端在调用微信手机号 API 前原子消费 ticket，以 stable token 换取手机号，写入有效 OpenID↔手机号绑定并发放 `ct_*`；新增 endpoint 只由生成的 `CustomerApi` 调用。

**Tech Stack:** Go 1.26、PostgreSQL、OpenAPI Generator（Dart Dio / TypeScript Fetch）、Taro 4、原生混写 WXML、Vitest、Node Test。

---

## 文件结构

| 文件 | 责任 |
| --- | --- |
| `db/migrations/0045_customer_wechat_phone_unique.sql` | 建立有效手机号唯一不变量，拒绝静默选择历史绑定。 |
| `api/cmd/server/{config.go,main.go,config_test.go}` | 注入并在 production 强制微信手机号全局调用配额。 |
| `api/internal/wechat/{provider.go,http.go,phone.go,mock.go,phone_test.go}` | phone code、stable token、singleflight 与脱敏错误。 |
| `api/internal/httpapi/customer_wechat*.go` | 公开 endpoint、限流、ticket 原子消费、绑定冲突与集成测试。 |
| `specs/api/openapi.yaml` 与 `generated/{dart,ts}/` | 冻结 endpoint 并重新生成两端客户端。 |
| `apps/miniprogram-next/src/api/customer-client.ts` | 独立 CustomerApi 状态和错误码提取。 |
| `apps/miniprogram-next/src/app.ts` | 私有 ticket 和唯一原生桥接。 |
| `apps/miniprogram-next/src/pages/{detail,my-reservations}/` | 两个客户入口的授权优先与短信备用 UI。 |
| `apps/miniprogram-next/{tests,test}/` | 生成客户端桥接、凭证恢复和页面状态机测试。 |

### Task 1: 数据库不变量和生产配额

**Files:**

- Create: `db/migrations/0045_customer_wechat_phone_unique.sql`
- Modify: `api/cmd/server/config.go`
- Modify: `api/cmd/server/main.go`
- Modify: `api/cmd/server/config_test.go`
- Modify: `api/internal/httpapi/server.go`

- [ ] **Step 1: 写失败测试**

在 `config_test.go` 让 production fixture 缺少两项配额时失败、完整 fixture 成功并读取值；集成测试先断言有效手机号唯一索引存在。

```go
_, err := loadRuntimeConfigFrom(mapLookup(map[string]string{"APP_ENV": "production"}))
if err == nil || !strings.Contains(err.Error(), "WECHAT_PHONE_GLOBAL_PER_MINUTE") {
    t.Fatalf("missing phone quota must be rejected: %v", err)
}
```

- [ ] **Step 2: 确认 RED**

Run: `cd api && go test ./cmd/server ./internal/httpapi -run 'WechatPhone|CustomerWechatPhone' -count=1`

Expected: FAIL；运行时配置和索引尚不存在。

- [ ] **Step 3: 最小实现**

迁移不得擅自撤销历史身份。先检查数据、再建立索引：

```sql
BEGIN;
DO $$
BEGIN
  IF EXISTS (
    SELECT phone FROM customer_wechat_identity WHERE revoked_at IS NULL
    GROUP BY phone HAVING count(*) > 1
  ) THEN
    RAISE EXCEPTION 'cannot add active customer WeChat phone uniqueness: resolve duplicate active phone bindings first';
  END IF;
END $$;
CREATE UNIQUE INDEX ux_customer_wechat_identity_phone_active
  ON customer_wechat_identity (phone) WHERE revoked_at IS NULL;
COMMIT;
```

在 `runtimeConfig` 增加 `WechatPhoneGlobalPerMinute`、`WechatPhoneGlobalPerDay`。development/test 默认 `600`、`100000`；production 要求 `WECHAT_PHONE_GLOBAL_PER_MINUTE` 与 `WECHAT_PHONE_GLOBAL_PER_DAY` 为正整数。把它们赋给 `httpapi.Server`，并在 `server.go` 固定 `customerWechatPhoneIPMaxPerMinute = 10`。

- [ ] **Step 4: 验证 GREEN**

Run: `cd api && go test ./cmd/server -run 'RuntimeConfig|WechatPhone' -count=1 && cd .. && make db-verify`

Expected: PASS；fresh PostgreSQL 可应用 0045，production 只有完整配置才通过。

- [ ] **Step 5: 提交**

Run: `git add db/migrations/0045_customer_wechat_phone_unique.sql api/cmd/server/config.go api/cmd/server/main.go api/cmd/server/config_test.go api/internal/httpapi/server.go && git commit -m "feat(auth): configure customer WeChat phone quotas"`

### Task 2: stable token 与手机号 provider

**Files:**

- Modify: `api/internal/wechat/provider.go`
- Modify: `api/internal/wechat/http.go`
- Create: `api/internal/wechat/phone.go`
- Modify: `api/internal/wechat/mock.go`
- Create: `api/internal/wechat/phone_test.go`
- Modify: `api/go.mod`

- [ ] **Step 1: 写失败测试**

用 `httptest.Server` 断言 stable token 是 JSON POST，五个并发 `PhoneNumber` 只请求一次 token，到期前 300 秒会刷新，所有错误都不包含 code、token、secret 或完整手机号。

```go
phone, err := provider.PhoneNumber(context.Background(), "phone-code-1")
if err != nil || phone.CountryCode != "86" || phone.Number != "+8613800138000" {
    t.Fatalf("phone=%+v err=%v", phone, err)
}
if got := tokenCalls.Load(); got != 1 {
    t.Fatalf("stable token calls=%d, want 1", got)
}
```

- [ ] **Step 2: 确认 RED**

Run: `cd api && go test ./internal/wechat -run 'PhoneNumber|StableToken' -count=1`

Expected: FAIL；当前 `Provider` 只有 `Code2Session`。

- [ ] **Step 3: 最小实现**

在 `provider.go` 增加：

```go
type Phone struct { CountryCode string; Number string }
type Provider interface {
    Code2Session(ctx context.Context, jsCode string) (Session, error)
    PhoneNumber(ctx context.Context, phoneCode string) (Phone, error)
}
```

在 `phone.go` 为 `HTTPProvider` 添加 `StableTokenEndpoint`、`PhoneEndpoint`、带过期时间的 mutex 缓存和 `singleflight.Group`。`stable_token` 使用 body `{"grant_type":"client_credential","appid":...,"secret":...,"force_refresh":false}`，最多 3 次（200ms、400ms）且服从 `ctx`；仅微信明确 token 失效时清缓存并强制刷新一次。随后 POST `wxa/business/getuserphonenumber?access_token=<token>` 与 `{"code":phoneCode}`。Mock provider 返回 `{CountryCode:"86", Number:"+8613800138000"}`；任何 error 不格式化请求凭证。

- [ ] **Step 4: 验证 GREEN**

Run: `cd api && gofmt -w internal/wechat && go mod tidy && go test ./internal/wechat -count=1`

Expected: PASS；`golang.org/x/sync` 成为直接依赖，现有 `Code2Session` 测试仍通过。

- [ ] **Step 5: 提交**

Run: `git add api/go.mod api/go.sum api/internal/wechat/provider.go api/internal/wechat/http.go api/internal/wechat/phone.go api/internal/wechat/mock.go api/internal/wechat/phone_test.go && git commit -m "feat(auth): exchange WeChat phone credentials safely"`

### Task 3: 公开绑定 endpoint 与并发语义

**Files:**

- Modify: `api/internal/httpapi/customer_api.go`
- Modify: `api/internal/httpapi/customer_wechat.go`
- Modify: `api/internal/httpapi/customer_wechat_test.go`
- Create: `api/internal/httpapi/customer_wechat_phone_integration_test.go`

- [ ] **Step 1: 写失败测试**

无 DB 测试覆盖空 `phone_code` 为 422、nil provider 为 503。集成测试创建 ticket 后并发请求两次，要求一个 201、一个 422、fake provider 只调用一次；预置另一 OpenID 的相同手机号，要求 `409 PHONE_ALREADY_BOUND` 且旧绑定未撤销。

```go
statuses := make(chan int, 2)
for range 2 { go func() { statuses <- postPhoneBinding(handler, ticket, "phone-code").Code }() }
first, second := <-statuses, <-statuses
if !((first == 201 && second == 422) || (first == 422 && second == 201)) { t.Fatalf("statuses=%d,%d", first, second) }
if got := provider.phoneCalls.Load(); got != 1 { t.Fatalf("PhoneNumber calls=%d, want 1", got) }
```

- [ ] **Step 2: 确认 RED**

Run: `cd api && go test ./internal/httpapi -run 'CustomerWechatPhone|CustomerWechatBinding' -count=1`

Expected: FAIL；路由、request type 和原子 ticket 消费尚不存在。

- [ ] **Step 3: 最小实现**

注册 `POST /v1/public/customer/wechat-phone-bindings`，只解码 `wechat_ticket`、`phone_code`。body 合法后先在任何数据库访问前拒绝 nil provider 为 503，再按以下顺序执行；远程请求不放在数据库事务中：

```go
if retry, err := s.enforceRateLimit(ctx, "cust-wx-phone:ip:"+s.clientIP(r), 0, customerWechatPhoneIPMaxPerMinute, time.Minute); err != nil { /* 429 */ }
if retry, err := s.enforceRateLimit(ctx, "cust-wx-phone:global:minute", 0, s.WechatPhoneGlobalPerMinute, time.Minute); err != nil { /* 503 */ }
if retry, err := s.enforceRateLimit(ctx, "cust-wx-phone:global:day", 0, s.WechatPhoneGlobalPerDay, 24*time.Hour); err != nil { /* 503 */ }
err := s.Store.Pool.QueryRow(ctx, `
  UPDATE wechat_bind_ticket SET used_at=now()
  WHERE ticket_sha256=$1 AND used_at IS NULL AND expires_at > now()
  RETURNING openid, unionid
`, sha256Hex(request.WechatTicket)).Scan(&openID, &unionID)
```

只有 UPDATE 成功的请求调用 `s.Wechat.PhoneNumber`。`CountryCode != "86"` 返回 `422 UNSUPPORTED_PHONE_COUNTRY`；不确定或无效 phone code 返回 `WECHAT_PHONE_REAUTHORIZE` 且 ticket 保持已消费；唯一索引冲突返回 `409 PHONE_ALREADY_BOUND`；成功后插入 identity 并调用 `issueCustomerSessionData`。为三种 code 写专用 `apiError` 构造器，不依赖字符串匹配数据库错误。

- [ ] **Step 4: 验证 GREEN**

Run: `cd api && gofmt -w internal/httpapi && go test ./internal/httpapi -count=1`

Expected: PASS；无数据库 URL 时集成测试明确 SKIP，有 URL 时覆盖 migration、竞争、会话和冲突。

- [ ] **Step 5: 提交**

Run: `git add api/internal/httpapi/customer_api.go api/internal/httpapi/customer_wechat.go api/internal/httpapi/customer_wechat_test.go api/internal/httpapi/customer_wechat_phone_integration_test.go && git commit -m "feat(auth): bind customer phone through WeChat"`

### Task 4: OpenAPI 与生成客户端

**Files:**

- Modify: `specs/api/openapi.yaml`
- Modify: `generated/dart/scolvpet_api/`
- Modify: `generated/ts/scolvpet-api/`

- [ ] **Step 1: 先运行缺失 route 的 conformance**

Run: `make openapi-conformance`

Expected: FAIL，报告 Go 路由缺少 `/v1/public/customer/wechat-phone-bindings`。

- [ ] **Step 2: 写入契约并重新生成**

以 `customer` tag 加 `createCustomerWechatPhoneBinding`，请求模型固定为：

```yaml
type: object
required: [wechat_ticket, phone_code]
properties:
  wechat_ticket: { type: string, description: "wt_ 开头的一次性票据" }
  phone_code: { type: string, description: "微信 getPhoneNumber 返回的一次性凭证" }
```

成功 `201` 引用 `CustomerSessionResponse`，声明 `401`、`409`、`422`、`429`、`503`。运行 `make generate-client` 与 `make generate-ts-client`，确认生成 `CustomerApi.createCustomerWechatPhoneBinding`，不得手改 generated 代码。

- [ ] **Step 3: 验证生成和契约**

Run: `make openapi-lint openapi-conformance client-drift ts-client-drift`

Expected: PASS；Dart 和 TypeScript 均无漂移。

- [ ] **Step 4: 提交**

Run: `git add specs/api/openapi.yaml generated/dart/scolvpet_api generated/ts/scolvpet-api && git commit -m "feat(api): publish customer WeChat phone binding contract"`

### Task 5: CustomerApi、私有桥接与两页授权优先 UI

**Files:**

- Create: `apps/miniprogram-next/src/api/customer-client.ts`
- Modify: `apps/miniprogram-next/src/app.ts`
- Modify: `apps/miniprogram-next/tests/{app-glue,api-adapter}.test.ts`
- Modify: `apps/miniprogram-next/src/utils/wechat_login.js`
- Modify: `apps/miniprogram-next/test/wechat_flow.test.mjs`
- Modify: `apps/miniprogram-next/src/pages/detail/detail.{js,wxml}`
- Modify: `apps/miniprogram-next/src/pages/my-reservations/my-reservations.{js,wxml}`

- [ ] **Step 1: 写失败的桥接和状态机测试**

在 `app-glue.test.ts` mock `customer-client`，断言桥接成功只经 `saveCustomer` 持久化、返回值没有 token/ticket/phone，`taroGlobalData.globalData` 不再含 ticket。给 `wechat_flow.test.mjs` 新增状态机：拒绝和境外号码显示短信；重新授权显示主按钮且清空两个凭证；已绑定手机号提示原微信号解绑。

```ts
const result = await app.authorizeCustomerPhone('phone-code')
expect(result).toEqual({ ok: true })
expect(wx.storage.scolvpet_customer).toMatchObject({ customerToken: 'ct_fixture_token', phone: '+8613800138000' })
expect(result).not.toHaveProperty('token')
expect(app.taroGlobalData.globalData).not.toHaveProperty('wechatTicket')
```

```js
assert.deepEqual(resolvePhoneAuthorizationState({ code: 'WECHAT_PHONE_REAUTHORIZE' }), {
  showSmsFallback: false, reauthorize: true, message: '授权已超时，请重新授权手机号',
})
```

- [ ] **Step 2: 确认 RED**

Run: `cd apps/miniprogram-next && npm test -- tests/app-glue.test.ts tests/api-adapter.test.ts && node --test test/wechat_flow.test.mjs`

Expected: FAIL；专用 CustomerApi、`authorizeCustomerPhone` 和状态机尚不存在。

- [ ] **Step 3: 实现生成式 client 和桥接**

`customer-client.ts` 使用生成的 `CustomerApi`、`Configuration`、`createTaroFetch` 和独立 `customerAccessToken`，绝不调用 B 端 `setApiToken`：

```ts
await customerApi.createCustomerWechatPhoneBinding({
  createCustomerWechatPhoneBindingRequest: { wechatTicket, phoneCode }
})
```

用 `ResponseError.response.json()` 映射四种服务端 code。`App` 将 ticket 与获得时间改为私有字段；`silentWechatLogin` 只写私有字段；`authorizeCustomerPhone(phoneCode)` 先清空 ticket，再调用 CustomerApi，成功时调用 `saveCustomer` 与 customer token setter，返回 `{ok:true}`。失败时不重放 code；重授权错误先预取新 ticket 后返回 `{ok:false,code:'WECHAT_PHONE_REAUTHORIZE'}`。

`detail` 和 `my-reservations` 无 token 时均显示 `open-type="getPhoneNumber"` 主按钮，分别调用 `authorizeAndSubmit`、`authorizeAndLoad`。短信表单只在拒绝、无 phone code 或 `UNSUPPORTED_PHONE_COUNTRY` 后出现，并只调用既有 `createCustomerSession`；删除两页对 `wechatTicket`、`loginWithSms`、`bindWechatIdentity` 的读取。详情授权成功后复用预约提交；预约列表授权成功后自动 `loadList`。

- [ ] **Step 4: 验证 GREEN**

Run: `cd apps/miniprogram-next && npm test && node --test test/*.test.mjs && npm run lint && npx tsc --noEmit && npx taro build --type weapp --no-check`

Expected: PASS；两份 WXML 都含 `open-type="getPhoneNumber"`，客户原生页不再读取 ticket，B 端 `src/api/client.ts` token 测试不变。

- [ ] **Step 5: 提交**

Run: `git add apps/miniprogram-next/src/api/customer-client.ts apps/miniprogram-next/src/app.ts apps/miniprogram-next/tests apps/miniprogram-next/test/wechat_flow.test.mjs apps/miniprogram-next/src/utils/wechat_login.js apps/miniprogram-next/src/pages/detail apps/miniprogram-next/src/pages/my-reservations && git commit -m "feat(miniprogram): authorize customer phone before customer actions"`

### Task 6: 全量验证与交接记录

**Files:**

- Create: `开发日志/2026/07/2026-07-30 · 客户微信手机号授权.md`
- Modify: `开发日志/2026/07/INDEX.md`

- [ ] **Step 1: 运行仓库全量门禁**

Run: `make migration-drift openapi-lint openapi-conformance client-drift ts-client-drift api-test miniprogram-next-lint miniprogram-next-test miniprogram-next-build`

Expected: 全部 PASS；若真实 PostgreSQL 未注入导致集成测试 SKIP，记录为“待真库验证”，不能记作 PASS。

- [ ] **Step 2: 运行 production 配置门禁**

Run: `cd api && go test ./cmd/server -run 'Production.*WechatPhone|RuntimeConfig' -count=1 && make release-miniprogram-next`

Expected: 配置测试 PASS；正式小程序构建只在 AppID、正式域名和注入值齐全时通过。不得把凭据写入仓库。

- [ ] **Step 3: 写入日志和索引**

日志记录 endpoint、commit、`WECHAT_PHONE_GLOBAL_PER_MINUTE`、`WECHAT_PHONE_GLOBAL_PER_DAY`、自动化结果与尚未执行的真机九环；更新当月 `INDEX.md`，再按仓库 AGENTS 约定 rsync 至 LA1。

- [ ] **Step 4: 复查并提交记录**

Run: `git diff --check && git status --short`

Expected: 仅本任务代码、生成文件和日志；不含 AppSecret、正式凭据或构建产物。

Run: `git add 开发日志/2026/07/2026-07-30\ ·\ 客户微信手机号授权.md 开发日志/2026/07/INDEX.md && git commit -m "docs: record customer WeChat phone auth delivery"`
