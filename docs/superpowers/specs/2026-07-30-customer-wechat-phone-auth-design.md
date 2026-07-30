# 客户微信手机号授权设计

**状态：已确认，待实施**

## 目标与边界

让未绑定的真实微信客户通过“微信授权手机号”建立 `ct_*` Customer Session；客户浏览公开个体不需要先授权，首次预约时才请求手机号。既有客户继续由 `wx.login` 静默恢复 Customer Session。

本批次只覆盖客户身份链：小程序授权入口、微信手机号凭证换取、OpenID 与手机号绑定、Customer Session 和短信备用路径。不改变繁育者端登录、预约数据结构、订阅消息、正式部署凭据或发布配置。

## 已确认的流程

```text
wx.login
  -> POST /v1/public/customer/wechat-sessions
  -> 已绑定：签发 ct_* Customer Session
  -> 未绑定：返回短时一次性 wechat_ticket

客户点击“微信授权手机号”
  -> getPhoneNumber 返回 phone_code
  -> POST /v1/public/customer/wechat-phone-bindings
       { wechat_ticket, phone_code }
  -> 服务端用微信 access token 换取手机号
  -> 原子消费 ticket，绑定 OpenID <-> 手机号，签发 ct_* Customer Session
  -> 客户提交预约
```

客户拒绝授权、基础库不支持或微信没有返回 `phone_code` 时，界面才展示“使用短信验证”入口。网络暂时不可用或服务端未知错误保留重试，不自动发送短信。ticket 已过期或已消费时，客户端清除 ticket，提示重新进入授权；用户仍可主动选择短信备用登录。

`session_key` 仅在服务端 `wx.login` 交换过程中存在，不保存、不返回客户端。微信手机号凭证、OpenID、Customer Session 与繁育者的 Bearer Token 始终隔离。

## 服务端设计

### API 契约

在 OpenAPI 新增 `POST /v1/public/customer/wechat-phone-bindings`，归属 `customer` tag，operationId 为 `createCustomerWechatPhoneBinding`。

请求体：

```json
{
  "wechat_ticket": "wt_<uuid>",
  "phone_code": "微信 getPhoneNumber 返回的一次性凭证"
}
```

成功响应与既有 `CustomerSessionResponse` 完全一致：`access_token` 必为 `ct_*`，并包含规范化后的中国大陆 `phone` 与过期秒数。请求不接受前端传来的手机号，避免伪造身份。

请求校验失败返回 422；微信凭证无效或手机号换取失败返回 401；微信 provider 未配置返回 503。前端只将“用户拒绝/无凭证”视为短信备用条件；其余 API 错误呈现可重试提示。

### 微信 provider

`api/internal/wechat.Provider` 增加“用 `phone_code` 换取手机号”的能力；`HTTPProvider` 使用既有 AppID/Secret 获取并缓存小程序 access token，再调用微信 `wxa/business/getuserphonenumber`。返回值仅向 handler 提供经验证的 `+86` 手机号。

Mock provider 为测试提供确定性手机号；HTTP provider 测试覆盖 token 获取、手机号换取、微信错误码和敏感凭证不泄漏。生产配置沿用既有 `WECHAT_PROVIDER=http`、`WECHAT_APPID`、`WECHAT_SECRET` 门禁，不新增明文凭据配置。

### 绑定与会话

handler 按 ticket 的 SHA-256 查询、校验 `wt_` 前缀、有效期和未使用状态；手机号换取成功后，以 `UPDATE ... used_at IS NULL AND expires_at > now()` 原子消费 ticket，再写入 `customer_wechat_identity`，最后复用 `issueCustomerSessionData` 创建 Customer Session。

若 OpenID 已经被并发绑定，返回可理解的验证错误，客户端重新执行 `wx.login` 后将得到静默 Session。数据库不新增持久化 `session_key` 或前端手机号字段。

## 小程序设计

### 生成契约与 token 隔离

OpenAPI 重新生成 `generated/ts/scolvpet-api`。在 `apps/miniprogram-next/src/api/` 新增客户专用生成客户端入口，使用 `CustomerApi` 和 Taro fetch adapter；它维护独立的 customer access token，绝不读取或写入 `src/api/client.ts` 的繁育者 token。

原生混写页不能直接使用 ES module 客户端，因此由 `src/app.ts` 在 `taroGlobalData` 上暴露单一桥接函数。该函数读取内存中的 `wechatTicket`，调用生成式 CustomerApi，成功后只通过既有 `saveCustomer` 持久化 Customer Session 与服务端返回的手机号。`detail.js` 只向桥接函数传递 `getPhoneNumber` 的 `code`，不自行拼接新 endpoint 或解析敏感数据。

### 预约页交互

未拥有 Customer Session 时，详情页显示主按钮“微信授权手机号并预约”，使用 `open-type="getPhoneNumber"`；处理函数先完成授权与建会话，再沿用现有预约提交逻辑。已有 Customer Session 的用户仍见“提交预约”。

授权拒绝后，页面说明“未获得手机号，无法确认预约”，并显示次级的短信验证入口与验证码表单；不在初始页面展示短信表单，也不自动触发短信。所有提交路径继续使用现有 `busy` 状态，防止重复预约。

## 测试与验收

实现遵循测试先行：每个新行为先写失败测试并确认失败，再写最小实现。

1. Go provider 单测验证微信 access token 与手机号 API 的请求、成功、错误码和敏感信息不泄漏。
2. Go handler 合约测试验证缺少 ticket/phone code、provider 不可用与无效微信凭证；Postgres 集成测试验证 ticket 单次消费、OpenID 绑定和 `ct_*` 会话签发。
3. OpenAPI 生成后运行 TypeScript client drift 检查，确认新 operation 位于 `CustomerApi`。
4. 小程序单测验证“未绑定 → 授权建会话 → 持久化 customer token”与“拒绝授权 → 显示短信备用”；原生混写测试验证页面只把 `phone_code` 交给 app bridge。
5. 运行 `make api-test`、`make miniprogram-next-test`、`make miniprogram-next-build` 与生产构建门禁。真机验收属于后续生产凭据与官方域名就绪后的独立步骤。

## 不采用的方案

不采用在每次授权时重新提交 `js_code + phone_code`：这会重复身份交换，且不复用已有的一次性身份边界。不保存 `session_key` 供后续手机号解密：会扩大敏感数据生命周期，并且微信当前手机号 API 已能由服务端 access token 完成换取。
