# C 端开发一键测试登录设计

**状态：已确认，待实施**

## 背景

桌面「小程序助手」不会为 `getPhoneNumber` 事件返回 `e.detail.code`。C 端“我的预订”因此必然进入短信备用表单；当前页面没有与 B 端相同的开发测试入口，导致开发人员无法在桌面环境完成客户会话与预约列表的端到端验证。

已在 staging 验证客户短信链路：项目开发账号可请求验证码、创建 `ct_*` Customer Session，并成功读取空预约列表。该临时会话已撤销。

## 目标与边界

在 `APP_ENV=development` 且 `DEV_LOGIN_PHONE`、`DEV_LOGIN_CODE` 都存在时，让 C 端“我的预订”提供显式的“一键测试登录”按钮。按钮使用已有客户验证码和 Customer Session API 创建真实 staging Customer Session，保存既有 customer token，并刷新预约列表。

本次不改生产认证、微信授权、短信备用、API 契约、服务端、OpenAPI 或发布脚本。生产语义下配置已将开发凭据置空，入口必须同时检查环境和两项凭据，确保 fail-closed。

## 方案选择

1. **推荐：开发态显式一键登录。** 在 C 端页面复用现有 `sendCustomerCode` 与 `createCustomerSession`，仅开发环境显示。测试最直接，且与 B 端既有模式一致。
2. 让桌面助手模拟 `getPhoneNumber` 回传。该行为依赖微信工具能力，当前工具不会回传一次性 code，无法作为稳定测试路径。
3. 在开发态自动填充短信表单。仍要求人工点击和输入验证码，且会把开发特例隐藏在正式交互中，不采用。

## 交互与数据流

```text
开发构建、未持有 customer token
  -> 显示「一键测试登录」
  -> POST /v1/public/customer/verification-codes
  -> POST /v1/public/customer/sessions
  -> saveCustomer({ phone, customerToken })
  -> GET /v1/customer/reservations
  -> 显示预约列表或「暂无预订记录」
```

按钮只在未登录时出现；进行中禁用以避免重复请求。成功后隐藏短信备用区并复用既有 `loadList()`；失败时复用页面现有错误呈现，不泄露验证码或 token。正式环境中不会渲染该按钮或调用此路径。

## 文件与测试

| 文件 | 改动 |
| --- | --- |
| `apps/miniprogram-next/src/pages/my-reservations/my-reservations.js` | 计算开发入口可用性并实现一次性测试会话创建。 |
| `apps/miniprogram-next/src/pages/my-reservations/my-reservations.wxml` | 在未登录状态渲染开发一键登录按钮。 |
| `apps/miniprogram-next/test/customer-dev-quick-login.test.mjs` | 用页面真实定义与注入的 API 假件覆盖开发态成功路径、生产态隐藏和失败提示。 |

实现按红绿测试进行：先让新测试因入口和处理函数不存在而失败，再写最小页面改动使其通过。随后运行该测试、原生小程序测试集和一次小程序构建；最后在微信开发者工具中点击入口，确认真实 staging 会话能加载预约列表。测试产生的临时 Customer Session 在验证后主动注销。

## 验收标准

1. 开发构建的“我的预订”页在无 token 时显示“一键测试登录”。
2. 点击后按验证码请求、Customer Session、预约列表的顺序完成真实调用，并显示列表或“暂无预订记录”。
3. 生产配置与缺失任一开发凭据时，入口不可见且处理函数不发起请求。
4. 短信备用和正式微信手机号授权行为保持不变。
