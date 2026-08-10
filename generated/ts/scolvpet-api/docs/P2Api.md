# P2Api

All URIs are relative to *https://api.scolvpet.cn/v1*

| Method | HTTP request | Description |
|------------- | ------------- | -------------|
| [**assistantCapabilities**](P2Api.md#assistantcapabilities) | **GET** /v1/assistant/capabilities | 读取助手能力 |
| [**cancelAssistantAction**](P2Api.md#cancelassistantaction) | **POST** /v1/assistant/actions/{action_id}/cancel | 取消助手动作 |
| [**chatAssistant**](P2Api.md#chatassistant) | **POST** /v1/assistant/chat | 通用多轮对话 |
| [**confirmAssistantAction**](P2Api.md#confirmassistantaction) | **POST** /v1/assistant/actions/{action_id}/confirm | 确认并执行助手动作 |



## assistantCapabilities

> AssistantCapabilitiesResponse assistantCapabilities()

读取助手能力

需要 Bearer 令牌；当前熊舍成员可读取只读助手能力与可用模式。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { AssistantCapabilitiesRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  try {
    const data = await api.assistantCapabilities();
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

[**AssistantCapabilitiesResponse**](AssistantCapabilitiesResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 读取助手能力成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## cancelAssistantAction

> AssistantActionCancelResponse cancelAssistantAction(actionId, idempotencyKey)

取消助手动作

需要 Bearer 令牌；仅可取消当前 owner 的待确认动作。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { CancelAssistantActionRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  const body = {
    // string
    actionId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies CancelAssistantActionRequest;

  try {
    const data = await api.cancelAssistantAction(body);
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
| **actionId** | `string` |  | [Defaults to `undefined`] |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**AssistantActionCancelResponse**](AssistantActionCancelResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 动作已取消 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## chatAssistant

> AssistantChatResponse chatAssistant(assistantChatRequest, idempotencyKey)

通用多轮对话

需要 Bearer 令牌。主路径为 Grok Build 通用对话，并注入本舍结构化事实。 未传 session_id 时自动创建会话。LLM 失败时降级为规则答案。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { ChatAssistantRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  const body = {
    // AssistantChatRequest
    assistantChatRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies ChatAssistantRequest;

  try {
    const data = await api.chatAssistant(body);
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
| **assistantChatRequest** | [AssistantChatRequest](AssistantChatRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**AssistantChatResponse**](AssistantChatResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 对话成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## confirmAssistantAction

> AssistantActionConfirmResponse confirmAssistantAction(actionId, idempotencyKey)

确认并执行助手动作

需要 Bearer 令牌；仅可执行当前 owner 的待确认动作。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { ConfirmAssistantActionRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  const body = {
    // string
    actionId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies ConfirmAssistantActionRequest;

  try {
    const data = await api.confirmAssistantAction(body);
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
| **actionId** | `string` |  | [Defaults to `undefined`] |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**AssistantActionConfirmResponse**](AssistantActionConfirmResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 动作已执行 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)

