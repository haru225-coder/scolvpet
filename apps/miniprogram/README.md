# ScolvPet 客户侧微信小程序

真实客户交易入口（浏览熊舍/仓鼠 → 登录 → 预订 → 我的预订 → 合同/回执），与 App CRM 共享后端真源。

## 技术栈

- 微信原生小程序（WXML / WXSS / JS）
- 后端：`/v1/public/sites/{slug}/*` 公开 API + 后续微信登录绑定

## 目录

```
apps/miniprogram/
  app.js / app.json / app.wxss
  pages/
    index/          # 入口：输入或扫码熊舍 slug
    catalog/        # 公开仓鼠列表
    detail/         # 仓鼠详情 + 提交预订
    my-reservations/# 我的预订（手机号查询态）
    contract/       # 合同/回执 token 只读
  utils/
    api.js          # 请求封装
    auth.js         # 本地 session / 手机号缓存
```

## 本地开发

1. 安装[微信开发者工具](https://developers.weixin.qq.com/miniprogram/dev/devtools/download.html)。
2. 导入本目录为小程序项目（AppID 可用测试号）。
3. 在 `utils/config.js` 设置 `API_BASE`（开发环境指向本地或 `https://p.scolv.com:8443`）。
4. 开发阶段可关闭域名校验；生产必须配置合法 request 域名。

## 与后端对齐

| 能力 | API |
|---|---|
| 公开目录 | `GET /v1/public/sites/{slug}/catalog` |
| 提交预订 | `POST /v1/public/sites/{slug}/reservations` |
| 媒体 | `GET /v1/public/sites/{slug}/media/{media_id}` |
| 合同 token | 既有 public document token 链 |

微信登录 / openid 绑定、真机短信校验将在接入微信开放平台后替换当前手机号本地态。

## 验收 Gate

- 小程序能浏览已发布熊舍仓鼠
- 身份校验后提交预订，App CRM 出现 held 预订
- hold 过期自动释放；确认后客户侧状态更新
- 不使用后台 miniprogram release sandbox 冒充客户能力
