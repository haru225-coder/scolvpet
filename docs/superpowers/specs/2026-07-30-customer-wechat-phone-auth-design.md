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

客户拒绝授权、基础库不支持或微信没有返回 `phone_code` 时，界面才展示“使用短信验证”入口。微信返回的非中国大陆手机号同样可以转入短信备用路径；其他 API 错误不自动发送短信。

流程中有两个独立的一次性凭证：服务端签发的 `wechat_ticket` 有效期固定为 10 分钟，微信客户端签发的 `phone_code` 有效期为 5 分钟。两者必须在同一次授权交互中配对使用。任一凭证已过期、已消费或微信端返回不确定结果时，客户端同时清除内存中的 ticket 与本次 phone code，重新执行 `wx.login` 并要求用户再次点击授权；不得仅重取 ticket 后复用旧的 phone code。此恢复路径显示“授权已超时，请重新授权手机号”，不是自动短信降级。

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

请求校验失败返回 422；微信凭证无效、已消费或网络结果不确定时返回带 `WECHAT_PHONE_REAUTHORIZE` 错误标识的 401/503，客户端必须整段重授权；微信 provider 未配置返回 503。微信返回 `countryCode` 非 `86` 时返回 422 和 `UNSUPPORTED_PHONE_COUNTRY`，前端提示“暂不支持非中国大陆手机号，请使用短信验证”并展示短信备用入口。

若手机号已绑定到其他有效 OpenID，返回 `PHONE_ALREADY_BOUND` 验证错误，前端提示“该手机号已绑定其他微信号，请先在原微信号解绑”；不接管绑定、不撤销旧会话，也不移除既有解绑接口。

该公开 endpoint 接入既有限流基础设施：来源 IP 每分钟最多 10 次，超出返回 429；微信手机号换取还受全局每分钟与每日配额熔断保护，触顶返回 503 且不调用微信。全局阈值由部署配置提供，生产环境缺失即拒绝启动；计数复用 `auth_rate_limit`，只使用固定的全局 bucket 与来源 IP bucket，不持久化 ticket 明文。429 和配额熔断均不自动显示短信备用入口。

### 微信 provider

`api/internal/wechat.Provider` 增加“用 `phone_code` 换取手机号”的能力；`HTTPProvider` 使用既有 AppID/Secret 调用微信 `stable_token` 获取小程序 access token，再调用微信 `wxa/business/getuserphonenumber`。返回值仅向 handler 提供经验证的 `+86` 手机号。

access token 只在进程内缓存，到期前 300 秒进入刷新窗口；刷新以 singleflight 合并同进程并发调用，并对获取 token 的瞬时失败最多执行 3 次、基数 200 毫秒的指数退避。多实例不引入共享缓存：`stable_token` 避免普通 `token` 接口刷新时使其他实例凭证失效。微信明确返回 token 失效错误码时，才作废缓存并强制刷新一次，避免刷新风暴。

Mock provider 为测试提供确定性手机号；HTTP provider 测试覆盖 stable token 获取、提前刷新、singleflight、手机号换取、微信错误码和敏感凭证不泄漏。`phone_code`、微信 access token、AppSecret、完整手机号和 ticket 明文不得进入日志、错误信息或链路追踪；确需记录手机号时只保留前 3 位和后 4 位。生产配置沿用既有 `WECHAT_PROVIDER=http`、`WECHAT_APPID`、`WECHAT_SECRET` 门禁，并新增全局调用配额配置，不新增明文凭据配置。

### 绑定与会话

handler 校验 `wt_` 前缀后，在调用微信前以 `UPDATE ... used_at IS NULL AND expires_at > now() RETURNING openid, unionid` 原子消费 ticket；因此并发请求中只有一个能调用微信手机号 API。远程调用结果不确定时 ticket 保持已消费，客户端必须整段重授权，不能重放 phone code。

手机号换取成功后写入 `customer_wechat_identity`，最后复用 `issueCustomerSessionData` 创建 Customer Session。数据库新增“有效手机号唯一”的部分索引（`phone WHERE revoked_at IS NULL`），确保同一手机号不会同时绑定两个有效 OpenID；冲突时拒绝并引导客户从原微信号使用既有解绑接口。OpenID 并发绑定同样返回明确验证错误，客户端重新执行 `wx.login` 后可获得静默 Session。数据库不新增 `superseded_by`、客户审计表、持久化 `session_key` 或前端手机号字段。

## 小程序设计

### 生成契约与 token 隔离

OpenAPI 重新生成 `generated/ts/scolvpet-api`。在 `apps/miniprogram-next/src/api/` 新增客户专用生成客户端入口，使用 `CustomerApi` 和 Taro fetch adapter；它维护独立的 customer access token，绝不读取或写入 `src/api/client.ts` 的繁育者 token。

原生混写页不能直接使用 ES module 客户端，因此由 `src/app.ts` 在 `taroGlobalData` 上暴露单一桥接函数。App 实例私有保存短时 ticket；原生页面不能读取它。该函数调用生成式 CustomerApi，成功后只通过既有 `saveCustomer` 持久化 Customer Session 与服务端返回的手机号。桥接入参仅接受 `phone_code`，返回值仅包含成功状态和可展示错误标识；ticket 明文与手机号不得作为返回值或新增可读取全局字段暴露给原生页面。现有 `globalData.customerToken` 保留为原生客户页面的既有会话读取面，桥接不返回 token，也不新增第二份 token 状态。

短信备用不再消费或绑定短时 ticket：`detail.js` 与 `my-reservations.js` 仅以既有验证码 endpoint 创建 Customer Session。这样授权拒绝后的备用路径不会把 ticket 暴露给原生页；客户下一次无 Customer Session 时仍可重新进行微信手机号授权。

### 预约页交互

未拥有 Customer Session 时，详情页显示主按钮“微信授权手机号并预约”，使用 `open-type="getPhoneNumber"`；处理函数先完成授权与建会话，再沿用现有预约提交逻辑。已有 Customer Session 的用户仍见“提交预约”。“我的预约”在无会话或会话过期时使用同一授权按钮恢复 Customer Session，成功后自动加载列表。

授权拒绝后，页面说明“未获得手机号，无法确认预约”，并显示次级的短信验证入口与验证码表单；非中国大陆手机号同样显示该入口。凭证超时、并发消费或网络结果不确定时，页面要求重新授权而不展示短信入口；不在初始页面展示短信表单，也不自动触发短信。所有提交路径继续使用现有 `busy` 状态，防止重复预约。

## 测试与验收

实现遵循测试先行：每个新行为先写失败测试并确认失败，再写最小实现。

1. Go provider 单测验证 stable token 请求、到期前 300 秒刷新、singleflight 下的单次请求、手机号 API 的请求、成功、错误码和敏感信息不泄漏。
2. Go handler 合约测试验证缺少 ticket/phone code、provider 不可用、无效微信凭证、非中国大陆手机号与手机号已被其他 OpenID 绑定；Postgres 集成测试验证有效手机号唯一约束、ticket 并发消费时恰好一个成功且微信 API 最多调用一次、OpenID 绑定和 `ct_*` 会话签发。
3. OpenAPI 重新生成 Dart 与 TypeScript 客户端，运行两端 client drift 检查，确认新 operation 位于 TypeScript `CustomerApi`。
4. 小程序单测验证“未绑定 → 授权建会话 → 持久化 customer token”、“拒绝授权/非中国大陆手机号 → 显示短信备用”与“任一凭证失效 → 清除二者并重新触发 getPhoneNumber”；原生混写测试验证页面只把 `phone_code` 交给最小桥接函数。
5. 运行 `make api-test`、`make miniprogram-next-test`、`make miniprogram-next-build` 与生产构建门禁。真机验收属于后续生产凭据与官方域名就绪后的独立步骤。

## 不采用的方案

不采用在每次授权时重新提交 `js_code + phone_code`：这会重复身份交换，且不复用已有的一次性身份边界。不保存 `session_key` 供后续手机号解密：会扩大敏感数据生命周期，并且微信当前手机号 API 已能由服务端 access token 完成换取。
