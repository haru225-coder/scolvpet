# 24 · ScolvPet 通用 AI 助手实施任务书

> 产品决策日期：2026-07-22  
> 仓库：`~/Documents/scolvpet` · 分支建议 `codex/openapi-p1-p2-contracts` 或新开 `codex/assistant-general-agent`  
> 模型：**保持 `grok-build-0.1`**（`AI_BASE_URL` + `AI_API_KEY` / Grok2API）  
> 定位：**通用对话 + 本舍数据可核验**（不是纯 ChatGPT，也不是旧版规则模板）  
> 写操作：**业务面全开**（见 §3 工具清单；破坏性操作须二次确认后执行）

---

## 0. 一句话目标

```text
用户在 App 里像聊通用助手一样提问；
涉及本舍时通过 tool 读真数据；
需要改数据时通过 tool 写真库（确认后执行），模型禁止编造数量/ID。
```

---

## 1. 已拍板决策

| 项 | 决策 |
|----|------|
| 形态 | 通用对话主路径 + 本舍 tool 核验 |
| 模型 | **Grok Build 0.1**（`AI_MODEL=grok-build-0.1`），不换品牌 |
| 规则层 | 仅 timeout/429/无 Key 时兜底，不再当主路径 |
| 写操作 | **全量业务写能力**（任务/仓鼠/笼舍/繁育/CRM/财务/健康/称重…） |
| 执行策略 | 默认「草案 → 用户点确认 → 服务端执行」；导航类无确认 |
| 旧接口 | 保留 `GET/POST /v1/assistant/capabilities|ask` 兼容一版 |
| 获客 Growth | 独立领域（`docs/17`），助手可 tool 跳转/起草，不吞掉 growth 编排 |

### 安全底线（写全开仍要守）

1. 所有 tool **强制 owner_id 隔离**，禁止跨舍。  
2. 破坏性：`delete_*` / `archive_*` / 状态不可逆迁移 → **必须** `requires_confirmation=true`。  
3. 无「任意 SQL / 任意 shell」工具。  
4. 审计：`assistant_action_log` 记录 tool 名、payload 摘要、执行结果。  
5. Rate limit：每 owner 每分钟 ask/chat 次数上限（建议 20）。

---

## 2. 目标架构

```text
Mobile Assistant UI（多轮会话）
    │  POST /v1/assistant/chat
    │  POST /v1/assistant/actions/{id}/confirm
    ▼
httpapi (鉴权 / 会话 / 编排入口)
    ▼
aicore/orchestrator
    ├─ system prompt（通用 + 本舍纪律）
    ├─ history (session messages)
    ├─ tools schema → Grok chat/completions（tool_calls）
    ├─ tool runtime → 复用现有 store/handler 逻辑（禁止复制一套 SQL 业务）
    └─ fallback：AnswerFromSnapshot（仅降级）
    ▼
Grok2API  AI_BASE_URL + grok-build-0.1
```

### 2.1 System prompt 纪律（必须写死）

- 你是「熊舍管家」App 内通用助手：可闲聊、可答养宠通识、可协助经营文案。  
- **任何本舍数量、个体、任务、金额、状态** 必须以 tool 结果为准；没有 tool 结果就说「我去查一下」并调 tool，禁止猜。  
- 写操作：先说明将做什么 → 产出确认卡；用户确认前不得声称「已创建/已删除」。  
- 输出：正常中文对话；需要动作时附结构化 `actions`（或走 tool_calls 协议）。

---

## 3. 工具面（写全开 · 白名单）

> 实现方式：每个 tool = 薄封装，内部调用已有 service/SQL 路径（i2/i3/i5/p1…），**不**在 aicore 重写业务。

### 3.1 只读

| tool | 说明 |
|------|------|
| `get_overview` | 在养/笼/窝/待办/逾期/繁育中/套餐 |
| `search_hamsters` | name/code/status/sex |
| `get_hamster` | 单只档案摘要 |
| `list_enclosures` | 笼盒列表/状态 |
| `list_tasks` | 待办筛选 |
| `list_breeding_plans` | 繁育计划 |
| `list_litters` | 窝次 |
| `list_crm_contacts` | 客户 |
| `list_accounting_summary` | 财务摘要（按日/月） |
| `search_docs` | 合同/回执标题检索 |

### 3.2 写入（确认后执行）

| tool | 对应现有能力 |
|------|----------------|
| `create_task` / `complete_task` / `update_task` | i5 tasks |
| `create_hamster` / `update_hamster` | i2 hamsters |
| `create_enclosure` / `update_enclosure` / `create_enclosure_stay` | i2 enclosures |
| `create_weight_record` | i2 weights |
| `create_health_record` | i5 health |
| `create_breeding_plan` / `transition_breeding` | i3（严格状态机） |
| `create_crm_contact` / `create_reservation` / `create_handover` | p1 crm |
| `create_accounting_record` | p1 accounting |
| `create_contract` / `create_receipt` | p1 contracts（签发类仍走既有校验） |
| `delete_*` / `soft_delete_*` | 各域删除；**强制确认** |

### 3.3 导航（无确认）

`open_hamster` · `open_enclosure` · `open_tasks` · `open_breeding` · `open_crm` · `open_data_center` · `open_growth`

P0 可先实现只读全集 + 写入：`create_task` / `complete_task` / `create_hamster` / `update_hamster` / `create_weight_record`；其余按 P1 加。

---

## 4. API 契约（OpenAPI 必改）

### 4.1 新接口

```http
POST /v1/assistant/sessions              → {data: {id}}
GET  /v1/assistant/sessions              → 列表
GET  /v1/assistant/sessions/{id}/messages
POST /v1/assistant/chat
  body: {
    session_id?: uuid,
    message: string,
    prefer_llm?: true,          # 默认 true
    client_context?: object     # 当前页 hamster_id 等可选
  }
  response: {
    data: {
      session_id, message_id,
      answer, mode,              # rules | llm
      facts[],                   # 本轮引用
      actions[],                 # 待确认写操作 + 导航
      tool_trace[]?              # debug/可选，生产可关
    }
  }

POST /v1/assistant/actions/{action_id}/confirm
POST /v1/assistant/actions/{action_id}/cancel
```

### 4.2 修正旧契约债

- `AssistantAnswer.mode`：`rules | llm`（**不要** wire 层 `agent`）  
- **增加** `actions` 数组（type/label/summary/requires_confirmation/payload/action_id/status）  
- `mode_default`：const `rules` 或改为 enum `rules|llm`（二选一；推荐 **enum + 真实默认 llm** 时再 gen）  
- 再生 `generated/dart/scolvpet_api`，App **禁止**再写死 `actions: const []`

### 4.3 兼容

- 旧 `POST /v1/assistant/ask`：内部转单轮 chat 或继续 rules；**新 UI 只用 chat**。

---

## 5. 数据表（建议 migration `0033_assistant_chat.sql`）

```sql
assistant_session (
  id, owner_id, title, created_at, updated_at, deleted_at
)
assistant_message (
  id, session_id, owner_id, role, content, mode, facts_json, created_at
)
assistant_action (
  id, session_id, owner_id, message_id,
  type, payload_json, requires_confirmation,
  status pending|confirmed|cancelled|executed|failed,
  result_json, created_at, executed_at
)
assistant_action_log (可选，或与 action 合并)
```

---

## 6. 移动端

| 改动 | 说明 |
|------|------|
| 会话 UI | 多轮气泡；输入中 loading；错误文案区分超时/鉴权/格式 |
| confirm 卡 | `requires_confirmation` 动作出 BottomSheet → confirm API → 刷新 |
| 超时 | chat receiveTimeout ≥ 45s；服务端 LLM HTTP timeout 25–30s |
| 默认 | `preferLlm=true`；capabilities.llm_available=false 时提示降级 |
| 入口 | 保持现有助手页升级，不新开壳页冒充 |

---

## 7. 服务端实现切片（工程顺序）

### Slice A · 会话 + Chat 主路径（P0 核心）
1. migration + store  
2. `orchestrator.Chat`：history + system + **无 tool 先通** 通用对话  
3. `POST /v1/assistant/chat` + OpenAPI + gen  
4. 移动端接 chat（可先不接 confirm）  
5. 超时/429 → 降级 rules overview 一句 + 提示「智能服务繁忙」

### Slice B · Tool 只读
1. tool registry + JSON schema  
2. Grok tool_calls 循环（max 4 rounds）  
3. facts 回填 UI  

### Slice C · Tool 写入 + confirm
1. `assistant_action` pending  
2. confirm 路由调现有 create/update  
3. 移动端确认卡  

### Slice D · 写全开扩展
按 §3.2 逐个挂工具；每加一个 tool = 单测 + 权限 + 审计。

### Slice E · 稳上游
1. grok2api 延迟/429 监控  
2. 重试 1 次（仅 429/502）  
3. 可选流式（P1+）

---

## 8. 验收标准

### P0（Slice A+B+C 最小闭环）
- [ ] 闲聊：「帮我写一段幼崽护理提示」→ 有正常长文，不炸  
- [ ] 核验：「现在有多少只在养」→ 数字与列表页一致（tool）  
- [ ] 写入：「给雪团建一个一小时后的称重任务」→ 确认卡 → 确认后任务列表可见  
- [ ] 上游挂：仍返回可读降级，不「助手请求失败」卡死  
- [ ] mode 永不返回非法枚举；gen client 解析 100%  

### P1
- [ ] 仓鼠创建/更新、称重、健康、CRM 联系人 可经确认执行  
- [ ] 会话历史可回看  
- [ ] 审计可查  

### P2
- [ ] 繁育状态机、合同签发等重工具  
- [ ] 流式输出  
- [ ] Pro/用量门禁（若需要）

---

## 9. 明确不做

- 任意 SQL / 上传并执行代码  
- 无确认的批量删除全库  
- 把 Growth 脚本生成整坨塞进 assistant 单文件（用 tool 调 growth API）  
- 为「通用」再引入第二套模型品牌（本任务书锁 Grok Build 0.1）

---

## 10. 工作量粗估

| Slice | 人天 |
|-------|------|
| A 会话+Chat | 3–4 |
| B 只读 tools | 2–3 |
| C 写入+confirm | 2–3 |
| D 写全开扩展 | 4–6（按工具数） |
| E 稳上游+流式 | 2–3 |
| 移动端+OpenAPI | 3–4 |
| **合计** | **约 16–23** |

---

## 11. 给执行 Agent 的开场指令

```text
读 docs/24-ScolvPet-通用AI助手-实施任务书.md
决策：通用对话+本舍可核验；模型 grok-build-0.1；写操作全开但确认后执行。
先做 Slice A，不要一口气写全 D。
红线：owner 隔离；无任意 SQL；OpenAPI 先改再 gen；复用现有 create/update handler。
隔离脏文件（media/ios 等）勿混 commit。
```

---

## 12. 交付状态

- **已写入** 本任务书（本机 `docs/24-…`）  
- **待确认**：是否立刻开工 Slice A（migration + chat API + 最小 UI）  
- 实现代码 **未开始**（本文件仅为颁布用规格）
