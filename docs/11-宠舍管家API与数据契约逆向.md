# 11 · 宠舍管家 API 与数据契约逆向

> 生成时间：2026-07-17T02:20:05+08:00  
> 波次：**R10**  
> 证据等级：S（App AOT 路由）、W（公开 admin/editor JS）、I（命名/路径推断）、B（运行态未观测）

## 1. 范围与验收

- 原始路由总数：**481**（App 250 + Web 231）
- 规范化去重后：**408**（shared 52 / app-only 179 / web-only 177）
- 每条均有来源、模块、分析状态：见 `reverse-evidence/full/api-catalog.csv` 与 `api/api-normalized.csv`
- Method 已解析（W）：**306**；路径推断（I）：**41**；未知：**134**
- P0 契约行：**94**（字段级运行态均为 B 或 I，逐条标注）

机器可读目录：

```text
reverse-evidence/full/api/
├── api-normalized.csv      # 去重合并视图
├── api-dedup-map.csv       # 原始 id → 规范 key
├── p0-contracts.json       # P0/P1 契约骨架
├── p0-contracts.csv
├── error-auth-model.json
└── r10-meta.json
```

## 2. 认证与传输

### 2.1 认证（W + S）

| 通道 | 行为 | 等级 |
|---|---|---|
| Browser admin | `localStorage.token` → 请求拦截器注入 | W |
| App WebView | Bridge `getToken()` 覆盖 local token | W |
| UA 检测 | `catteryapp` / `flutter` 视为 App 环境 | W |
| HTTP 栈 | `Authorization` 头构造出现在打包的 axios/xhr 层 | W |
| 登录前 | `/api/admin/app/login`、`/api/admin/sms` 等 | I |

令牌生命周期、刷新与吊销：**B**（App 动态阻断，未见运行态）。

### 2.2 错误模型（W 片段 + B）

- 成功码线索：admin 出现 `code===0` 计数 1；编辑器字体接口注释式 `o.code===200`
- 业务错误字段：`message` 字符串广泛存在；统一 schema **B**
- HTTP 401/403：打包库中存在状态码分支，业务映射 **B**
- 取消：`Cancel` / `__CANCEL__`（axios 风格）

在动态补证前，所有 P0 的错误字段完整率按验收要求标记为 **B**（逐条见 `p0-contracts`）。

## 3. 分页 / 时间 / 空值

| 主题 | 结论 | 等级 |
|---|---|---|
| 分页 | admin 使用 `page` / `pageSize` / `total` 等；列表 GET 可能带分页 | W |
| 时间格式 | 未运行态确认；I 倾向 ISO-8601 字符串 | B/I |
| 空值 | 未确认 omit vs null vs 0 | B |
| 上传 | `FormData` / `multipart` 出现；COS/DAM 路径 | W |

## 4. 方法推断规则

1. **优先** Web admin `url+method` 命名请求（W）
2. App 与 Web 路径规范化匹配时复用 Web method（S+W）
3. 否则路径后缀启发式：`add/create→POST`，`update/confirm/archive→PUT`，`delete→DELETE`，`detail/list→GET`（I）
4. 仍无法判断 → method 空，status=`method-unknown`（进入 R3 后补 D）

启发式统计：{"path-heuristic-low": 3, "path-heuristic-medium": 38, "unknown": 134, "web-admin-named-request": 304, "web-editor-axios": 2}

## 5. 幂等与批处理 / 归档

| 行为 | 识别 | 等级 |
|---|---|---|
| GET 安全幂等 | method=GET | W/I |
| PUT 更新/确认/归档 | `/update` `/confirm` `/archive` | W/I |
| DELETE | `/delete` | W/I |
| POST 创建 | `/add` `/create` `/upload` `/record` | W/I |
| 繁育归档 | `/api/admin/cat/planes/archive` | W+S |
| 批量 | `batch` 实体/服务名存在；具体 API 体 B | S/B |
| 乐观锁 | 未见明确 version 字段证据 | B |
| 重复提交 | 未见客户端锁证据 | B |

## 6. P0 契约骨架（摘要）

完整 JSON：`reverse-evidence/full/api/p0-contracts.json`。

| 路由 | Method | Auth | 请求 | 响应 | 错误 |
|---|---|---|---|---|---|
| `/api/admin/account` | get | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/account/recover` | put | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/accounting/categories/` | get | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/accounting/categoriesr` | ∅ | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/accounting/daily-report` | ∅ | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/accounting/goods-sales-report` | ∅ | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/accounting/monthly-report` | ∅ | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/accounting/records` | ∅ | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/accounting/statisticsr` | ∅ | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/accounting/subcategories` | ∅ | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/app/login` | post | likely-public-or-pre-session | I: phone/code or apple credential fields | I: token + user profile likely; exact sc | I: invalid code / rate limit l |
| `/api/admin/breeding/invite/` | put | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/breeding/invite/:token/info` | get | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/breeding/invite/accept` | post | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/breeding/transaction/create` | post | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/breeding/transaction/list` | get | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/breeding/transaction/r` | put | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/cat/planes` | get | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/cat/planes/add` | post | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/cat/planes/archive/` | put | bearer-or-token-header | I: archive reason/flags possible; B | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/cat/planes/archive/:id` | put | bearer-or-token-header | I: archive reason/flags possible; B | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/cat/planes/breeding/` | put | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/cat/planes/breeding/:id` | put | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/cat/planes/breeding/:id/date` | put | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/cat/planes/confirm/` | put | bearer-or-token-header | I: ConfirmProduction-like payload; App h | I: updated plane + side effects; B | B-not-observed-runtime |
| `/api/admin/cat/planes/confirm/:id` | put | bearer-or-token-header | I: ConfirmProduction-like payload; App h | I: updated plane + side effects; B | B-not-observed-runtime |
| `/api/admin/cat/planes/delete/` | delete | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/cat/planes/delete/:id` | delete | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/cat/planes/detail/` | get | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/cat/planes/detail/:id` | get | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/cat/planes/remind/` | ∅ | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/cat/planes/update/` | put | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/cat/planes/update/:id/show` | put | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/cat/planes/update/cats/` | put | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/cat/planes/update/cats/:id` | put | bearer-or-token-header | B-not-observed-runtime | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/cat/planes/weights/` | post | bearer-or-token-header | I: weight records array/cat ids; B | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/cat/planes/weights/:id` | post | bearer-or-token-header | I: weight records array/cat ids; B | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/cat/planes/weights/:id/delete` | delete | bearer-or-token-header | I: weight records array/cat ids; B | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/cat/planes/weights/:id/update` | put | bearer-or-token-header | I: weight records array/cat ids; B | B-not-observed-runtime | B-not-observed-runtime |
| `/api/admin/cat/planes/weights/cat` | ∅ | bearer-or-token-header | I: weight records array/cat ids; B | B-not-observed-runtime | B-not-observed-runtime |

说明：验收要求 P0 字段完整率 100% **或** 逐条 B — 本轮采用后者（无运行态抓包）。

## 7. 实体 / Service 交叉引用

规范化目录的 `notes` / `p0-contracts.json` 含 `entities` 与 `services` 字段，
来自 AOT 路径 token 与路由段的静态重合（S），例如：

- `cats` → `cat` entity / `cat_api_service`
- `planes` → `breeding_plan*` entities / `breeding_plan_api_service`
- `entitlements` → membership 相关（字段级 B）

状态机四级枚举（Web 明文，W）：`待搭配 / 待生产 / 带娃中 / 已归档` — 与 docs/02 对齐，动作 API 见 planes confirm/archive/breeding。

## 8. 与 R9 交叉统计

- shared normalized keys: **52**
- app-only: **179**
- web-only: **177**

## 9. 缺口与补证

1. 解除 R3 FairPlay 阻断后，对 P0 做代理抓包，将 B 升级为 D。
2. 补齐 method-unknown 列表（见 `api/r10-meta.json`）。
3. 错误码表、分页默认值、时间/时区、乐观锁字段需运行态或更多前端解压。
4. App-only 路由的 method 目前大量依赖启发式（I），优先用真机日志校验。

## 10. 敏感信息

- 本文与目录不含 Token、Cookie、手机号或用户业务数据。

