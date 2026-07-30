# CustomerApi

All URIs are relative to *https://api.scolvpet.cn/v1*

| Method | HTTP request | Description |
|------------- | ------------- | -------------|
| [**cancelCustomerReservation**](CustomerApi.md#cancelcustomerreservation) | **POST** /v1/customer/reservations/{reservation_id}/cancel | 客户取消 held 预订 |
| [**createCustomerSession**](CustomerApi.md#createcustomersessionoperation) | **POST** /v1/public/customer/sessions | 客户验证码登录 |
| [**createCustomerWechatBinding**](CustomerApi.md#createcustomerwechatbindingoperation) | **POST** /v1/public/customer/wechat-bindings | 短信验证并绑定微信身份 |
| [**createCustomerWechatPhoneBinding**](CustomerApi.md#createcustomerwechatphonebindingoperation) | **POST** /v1/public/customer/wechat-phone-bindings | 微信授权手机号并创建客户会话 |
| [**createCustomerWechatSession**](CustomerApi.md#createcustomerwechatsessionoperation) | **POST** /v1/public/customer/wechat-sessions | 微信 wx.login 静默登录 |
| [**deleteCustomerSession**](CustomerApi.md#deletecustomersession) | **DELETE** /v1/customer/sessions/current | 客户退出当前会话 |
| [**deleteCustomerWechatBinding**](CustomerApi.md#deletecustomerwechatbinding) | **DELETE** /v1/customer/wechat-bindings/current | 解绑当前客户的微信身份 |
| [**getCustomerReservation**](CustomerApi.md#getcustomerreservation) | **GET** /v1/customer/reservations/{reservation_id} | 获取客户预订详情 |
| [**listCustomerReservations**](CustomerApi.md#listcustomerreservations) | **GET** /v1/customer/reservations | 列出当前客户预订 |
| [**sendCustomerVerificationCode**](CustomerApi.md#sendcustomerverificationcodeoperation) | **POST** /v1/public/customer/verification-codes | 客户侧发送登录验证码 |



## cancelCustomerReservation

> CustomerReservationResponse cancelCustomerReservation(reservationId)

客户取消 held 预订

### Example

```ts
import {
  Configuration,
  CustomerApi,
} from '@scolvpet/scolvpet-api';
import type { CancelCustomerReservationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: customerBearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new CustomerApi(config);

  const body = {
    // string
    reservationId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies CancelCustomerReservationRequest;

  try {
    const data = await api.cancelCustomerReservation(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **reservationId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**CustomerReservationResponse**](CustomerReservationResponse.md)

### Authorization

[customerBearerAuth](../README.md#customerBearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 已取消 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createCustomerSession

> CustomerSessionResponse createCustomerSession(createCustomerSessionRequest)

客户验证码登录

返回 ct_* customer access token（与 staff bearer 分离）。

### Example

```ts
import {
  Configuration,
  CustomerApi,
} from '@scolvpet/scolvpet-api';
import type { CreateCustomerSessionOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const api = new CustomerApi();

  const body = {
    // CreateCustomerSessionRequest
    createCustomerSessionRequest: ...,
  } satisfies CreateCustomerSessionOperationRequest;

  try {
    const data = await api.createCustomerSession(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **createCustomerSessionRequest** | [CreateCustomerSessionRequest](CreateCustomerSessionRequest.md) |  | |

### Return type

[**CustomerSessionResponse**](CustomerSessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 客户会话已创建 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createCustomerWechatBinding

> CustomerSessionResponse createCustomerWechatBinding(createCustomerWechatBindingRequest)

短信验证并绑定微信身份

消费 wechat-sessions 下发的一次性票据：短信验证通过后写入 openid↔phone 绑定 并发放 ct_* 会话。票据过期/已用返回 422，客户端应降级到普通验证码登录。

### Example

```ts
import {
  Configuration,
  CustomerApi,
} from '@scolvpet/scolvpet-api';
import type { CreateCustomerWechatBindingOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const api = new CustomerApi();

  const body = {
    // CreateCustomerWechatBindingRequest
    createCustomerWechatBindingRequest: ...,
  } satisfies CreateCustomerWechatBindingOperationRequest;

  try {
    const data = await api.createCustomerWechatBinding(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **createCustomerWechatBindingRequest** | [CreateCustomerWechatBindingRequest](CreateCustomerWechatBindingRequest.md) |  | |

### Return type

[**CustomerSessionResponse**](CustomerSessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 绑定成功并创建客户会话 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createCustomerWechatPhoneBinding

> CustomerSessionResponse createCustomerWechatPhoneBinding(createCustomerWechatPhoneBindingRequest)

微信授权手机号并创建客户会话

原子消费 wx.login 下发的 wt_ 一次性票据后，使用 getPhoneNumber 的 phone_code 从微信服务端换取手机号，写入 OpenID↔手机号有效绑定并发放 ct_* 会话。ticket 有效期为 10 分钟；任一凭证失效、ticket 已消费或远程结果不确定时，客户端必须 重新执行 wx.login 并由用户再次授权，不得重放旧 phone_code。

### Example

```ts
import {
  Configuration,
  CustomerApi,
} from '@scolvpet/scolvpet-api';
import type { CreateCustomerWechatPhoneBindingOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const api = new CustomerApi();

  const body = {
    // CreateCustomerWechatPhoneBindingRequest
    createCustomerWechatPhoneBindingRequest: ...,
  } satisfies CreateCustomerWechatPhoneBindingOperationRequest;

  try {
    const data = await api.createCustomerWechatPhoneBinding(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **createCustomerWechatPhoneBindingRequest** | [CreateCustomerWechatPhoneBindingRequest](CreateCustomerWechatPhoneBindingRequest.md) |  | |

### Return type

[**CustomerSessionResponse**](CustomerSessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 微信手机号已绑定并创建客户会话 |  -  |
| **409** | 手机号已绑定到另一有效微信身份 |  -  |
| **422** | 微信手机号凭证失效或手机号国家/地区不受支持 |  -  |
| **429** | 请求频率过高 |  * Retry-After - 建议重试等待秒数 <br>  |
| **503** | 微信手机号服务或其全局调用配额暂不可用 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createCustomerWechatSession

> CustomerWechatBindTicketResponse createCustomerWechatSession(createCustomerWechatSessionRequest)

微信 wx.login 静默登录

用 wx.login 的 js_code 换取身份：openid 已绑定手机号则直接发放 ct_* 会话（201）； 未绑定则返回一次性绑定票据（200，10 分钟有效），随后经短信验证完成绑定。 session_key 永不返回客户端。

### Example

```ts
import {
  Configuration,
  CustomerApi,
} from '@scolvpet/scolvpet-api';
import type { CreateCustomerWechatSessionOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const api = new CustomerApi();

  const body = {
    // CreateCustomerWechatSessionRequest
    createCustomerWechatSessionRequest: ...,
  } satisfies CreateCustomerWechatSessionOperationRequest;

  try {
    const data = await api.createCustomerWechatSession(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **createCustomerWechatSessionRequest** | [CreateCustomerWechatSessionRequest](CreateCustomerWechatSessionRequest.md) |  | |

### Return type

[**CustomerWechatBindTicketResponse**](CustomerWechatBindTicketResponse.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | openid 已绑定，静默发放客户会话 |  -  |
| **200** | openid 未绑定，需短信验证绑定 |  -  |
| **401** | 微信登录凭证无效 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |
| **429** | 频控 |  -  |
| **503** | 微信登录暂不可用，降级短信登录 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## deleteCustomerSession

> deleteCustomerSession()

客户退出当前会话

### Example

```ts
import {
  Configuration,
  CustomerApi,
} from '@scolvpet/scolvpet-api';
import type { DeleteCustomerSessionRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: customerBearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new CustomerApi(config);

  try {
    const data = await api.deleteCustomerSession();
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters

This endpoint does not need any parameter.

### Return type

`void` (Empty response body)

### Authorization

[customerBearerAuth](../README.md#customerBearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **204** | 已注销 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## deleteCustomerWechatBinding

> deleteCustomerWechatBinding()

解绑当前客户的微信身份

审计链保留绑定行（revoked_at），解绑后下次 wx.login 回到绑定流程。

### Example

```ts
import {
  Configuration,
  CustomerApi,
} from '@scolvpet/scolvpet-api';
import type { DeleteCustomerWechatBindingRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: customerBearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new CustomerApi(config);

  try {
    const data = await api.deleteCustomerWechatBinding();
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters

This endpoint does not need any parameter.

### Return type

`void` (Empty response body)

### Authorization

[customerBearerAuth](../README.md#customerBearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **204** | 已解绑 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getCustomerReservation

> CustomerReservationResponse getCustomerReservation(reservationId)

获取客户预订详情

### Example

```ts
import {
  Configuration,
  CustomerApi,
} from '@scolvpet/scolvpet-api';
import type { GetCustomerReservationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: customerBearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new CustomerApi(config);

  const body = {
    // string
    reservationId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies GetCustomerReservationRequest;

  try {
    const data = await api.getCustomerReservation(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **reservationId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**CustomerReservationResponse**](CustomerReservationResponse.md)

### Authorization

[customerBearerAuth](../README.md#customerBearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 预订详情 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listCustomerReservations

> CustomerReservationListResponse listCustomerReservations()

列出当前客户预订

### Example

```ts
import {
  Configuration,
  CustomerApi,
} from '@scolvpet/scolvpet-api';
import type { ListCustomerReservationsRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: customerBearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new CustomerApi(config);

  try {
    const data = await api.listCustomerReservations();
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters

This endpoint does not need any parameter.

### Return type

[**CustomerReservationListResponse**](CustomerReservationListResponse.md)

### Authorization

[customerBearerAuth](../README.md#customerBearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 客户预订列表 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## sendCustomerVerificationCode

> CustomerVerificationCodeResponse sendCustomerVerificationCode(sendCustomerVerificationCodeRequest, idempotencyKey)

客户侧发送登录验证码

不创建 staff account；仅创建 verification challenge。

### Example

```ts
import {
  Configuration,
  CustomerApi,
} from '@scolvpet/scolvpet-api';
import type { SendCustomerVerificationCodeOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const api = new CustomerApi();

  const body = {
    // SendCustomerVerificationCodeRequest
    sendCustomerVerificationCodeRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies SendCustomerVerificationCodeOperationRequest;

  try {
    const data = await api.sendCustomerVerificationCode(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **sendCustomerVerificationCodeRequest** | [SendCustomerVerificationCodeRequest](SendCustomerVerificationCodeRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**CustomerVerificationCodeResponse**](CustomerVerificationCodeResponse.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **202** | 验证码已接受 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |
| **429** | 频控 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)

