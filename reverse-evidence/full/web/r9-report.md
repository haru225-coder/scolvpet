# R9 公开管理端 / 编辑器 / 平台逆向报告

> 证据等级：**W**（公开 HTML + 生产 JS）+ **S**（App AOT WebView handlers）  
> 目标版本关联：宠舍管家 `2.15.0 (73)`（Web 资源为 2026-07-15 归档构建）  
> 约束：只读；未登录业务后台；未保存 Token/Cookie

## 1. 样本

| 资源 | 路径 | SHA-256（见 full/SHA256SUMS） |
|---|---|---|
| Admin JS | `reverse-evidence/web/cattery-admin.js` | 5572f703… |
| Editor JS | `reverse-evidence/web/cattery-editor.js` | 165b6369… |
| 脚本 URL | `script-urls.txt` | cdn.fanmeowy.com |
| HTML | pricing / trade / editor | 公开 200 |

## 2. 步骤完成情况

| 步骤 | 结果 |
|---|---|
| JS 切片与模块索引 | **完成** → `web/module-index.md` + catalogs |
| 路由/接口/权限/枚举 | **完成（W）** → routes/API/methods；Pinia store 名压缩丢失 |
| 官网/小程序/模板/审核/发布 | **完成（W）+ 回滚 B** |
| WebView Bridge 边界 | **完成（W+S）** → `bridge-catalog.csv` |
| AI Agent 工具目录 | **B/部分** — Agent 主路径在 App；Web 管理端未见完整工具清单 |
| App×Web API 交叉映射 | **完成** → `app-web-api-crossmap.csv` |

## 3. API 验收

- 基线 Web API：**231** 条全部进入 `api-catalog.csv`（API-WEB-*）
- 本轮 method 解析成功：**228/231**
- Admin named client 函数：226
- Editor API 字符串：6（以 fonts/DAM/COS/merchant 为主）

交叉统计：shared=49, web-only=181, app-only=201

## 4. Bridge 与鉴权边界（W）

请求拦截器逻辑（admin 明文片段）：

1. 默认 `localStorage.getItem("token")`
2. 若 `isInApp()` / Bridge 存在：`await getToken()` 覆盖为 App Token
3. UA 含 `catteryapp` / `flutter` 亦判定 App 环境
4. `__APP_DATA__` 携带 `platform` / `token` / `userInfo`

原生侧 handler（AOT，S）：`bridge_handler`, `cat_handler`, `device_handler`, `media_handler`, `store_trade_handler`, `template_handler`, `ui_handler`, `user_handler`

App 入口页（S，R1/R2 catalogs）：`membership_webview_page`, `editor_webview_page`, `pet_art_gallery_webview_page`, `pet_bean_webview_page`

## 5. docs/01 P2 关闭状态

| P2 项 | 状态 | 结论 |
|---|---|---|
| 官网与微信小程序内容模型是否共用 | **W 已验证（共用管理模型）** | 同一 admin SPA：`/ws/shop*`+SEO+文章+TabBar 与 `/ws/weixin/*`+`/api/admin/weixin/mini/*` 并存；店铺内容 API 共用，小程序多授权/审核/版本面 |
| 模板编辑器、审核、发布流程 | **W 已验证（主路径）** | 路由 `/ws/weixin/audit|version|mini`；API `mini/audit|publish|upload|version|template`；编辑器独立 `/editor` + fonts/DAM |
| 版本回滚 | **B** | 生产 JS 未见「回滚」明文或 rollback API；需动态或新构建补证 |
| App 内 WebView 与原生切换 | **S+W 部分** | Bridge 环境检测 + 多个 `*_webview_page`；完整切换序列仍待 R3 解除后 D 确认 |

详见 `web/p2-closure.md`。

## 6. AI Agent

- App：`AgentController` / `agent_workbench_page` / `agent_api_service`（S）
- Web 管理端：未提取到与 App 对等的 Agent 工具注册表；定价/订单等路径名含 detail 噪声
- 状态：**B** — 工具参数、写入确认、权益限制以 App 动态/R5–R7 为主，Web 侧本轮不假装完成

## 7. 数据模型边界结论

```text
共享（App + Web 管理端调用同一 /api/admin 域）：
  猫只、繁育 planes、文章、店铺、商品相关、队列/上门等大量 admin API

Web 侧重 / Web-only：
  微信小程序发布链、部分 SEO/装修、editor fonts、部分 DAM 模板路径

App 侧重 / App-only：
  大量移动端经营/健康/通知/会员 StoreKit 相关路由（见 crossmap app-only）

编辑器：
  主要为可视化装修运行时 + 字体/素材 API，不承载完整业务 CRUD
```

## 8. 敏感信息

- 未登录后台，无 Token
- 日志/报告不含用户业务数据
- 开发机路径泄漏（`/Users/jianghong/Desktop/fgoll/...`）仅作来源标记，不扩散
