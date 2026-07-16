# docs/01 P2 清单关闭记录（R9）

> 不改写 docs/01 历史正文；以本文件作为勘误/关闭表。证据等级：W/S/B。

| # | P2 原文 | 关闭状态 | 证据 | 说明 |
|---|---|---|---|---|
| 1 | 宠舍官网与微信小程序的内容模型是否共用 | **已验证（W）— 共用管理端内容模型** | `web-routes.csv` `/ws/shop*`+`/ws/weixin/*`；`api-catalog` `/api/admin/shops*` 与 `/api/admin/weixin/mini/*` | 官网/店铺装修与小程序发布在同一 admin SPA；内容实体（店/商品/文章/导航/SEO）共享，小程序叠加微信审核发布链 |
| 2 | 模板编辑器、审核、发布和版本回滚流程 | **主路径已验证（W）；回滚 B** | 路由 audit/version/mini；API audit/publish/upload/version/template；editor SPA | 审核/发布/版本/体验者/模板 API 齐全；未见 rollback 明文或 API |
| 3 | （延伸）App WebView 与原生切换边界 | **部分 S+W；动态 B** | bridge-catalog + AOT webview pages/handlers | Bridge 与入口页明确；交互序列待 R3 解除 |

关联交付：`runtime/r3/`（App 动态阻断）、`web/r9-report.md`。
