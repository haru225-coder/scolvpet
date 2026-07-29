# P2Api

All URIs are relative to *https://api.scolvpet.cn/v1*

| Method | HTTP request | Description |
|------------- | ------------- | -------------|
| [**askAssistant**](P2Api.md#askassistant) | **POST** /v1/assistant/ask | 向只读助手提问 |
| [**assistantCapabilities**](P2Api.md#assistantcapabilities) | **GET** /v1/assistant/capabilities | 读取助手能力 |
| [**auditMiniprogramRelease**](P2Api.md#auditminiprogramreleaseoperation) | **POST** /v1/miniprogram/releases/{release_id}/audit | 审核小程序版本 |
| [**cancelAssistantAction**](P2Api.md#cancelassistantaction) | **POST** /v1/assistant/actions/{action_id}/cancel | 取消助手动作 |
| [**cancelStudDeal**](P2Api.md#cancelstuddeal) | **POST** /v1/stud/deals/{deal_id}/cancel | 取消跨舍借配单 |
| [**chatAssistant**](P2Api.md#chatassistant) | **POST** /v1/assistant/chat | 通用多轮对话 |
| [**completeStudDeal**](P2Api.md#completestuddeal) | **POST** /v1/stud/deals/{deal_id}/complete | 完成跨舍借配单 |
| [**confirmAssistantAction**](P2Api.md#confirmassistantaction) | **POST** /v1/assistant/actions/{action_id}/confirm | 确认并执行助手动作 |
| [**confirmStudDeal**](P2Api.md#confirmstuddeal) | **POST** /v1/stud/deals/{deal_id}/confirm | 确认跨舍借配单 |
| [**createAssistantSession**](P2Api.md#createassistantsession) | **POST** /v1/assistant/sessions | 创建会话 |
| [**createMiniprogramRelease**](P2Api.md#createminiprogramreleaseoperation) | **POST** /v1/miniprogram/releases | 创建小程序版本 |
| [**createStudDeal**](P2Api.md#createstuddealoperation) | **POST** /v1/stud/deals | 创建跨舍借配单 |
| [**createStudListing**](P2Api.md#createstudlistingoperation) | **POST** /v1/stud/listings | 创建种公借配挂牌 |
| [**getMiniprogramConfig**](P2Api.md#getminiprogramconfig) | **GET** /v1/miniprogram/config | 读取小程序配置 |
| [**getOwnerPublicSite**](P2Api.md#getownerpublicsite) | **GET** /v1/public-site | 读取熊舍公开主页草稿 |
| [**getPublicSiteBySlug**](P2Api.md#getpublicsitebyslug) | **GET** /v1/public/sites/{slug} | 读取公开主页投影 |
| [**listAssistantMessages**](P2Api.md#listassistantmessages) | **GET** /v1/assistant/sessions/{session_id}/messages | 列出会话消息 |
| [**listAssistantSessions**](P2Api.md#listassistantsessions) | **GET** /v1/assistant/sessions | 列出会话 |
| [**listMiniprogramReleases**](P2Api.md#listminiprogramreleases) | **GET** /v1/miniprogram/releases | 列出小程序版本 |
| [**listStudDeals**](P2Api.md#liststuddeals) | **GET** /v1/stud/deals | 列出跨舍借配单 |
| [**listStudListings**](P2Api.md#liststudlistings) | **GET** /v1/stud/listings | 列出种公借配挂牌 |
| [**publishMiniprogramRelease**](P2Api.md#publishminiprogramrelease) | **POST** /v1/miniprogram/releases/{release_id}/publish | 发布小程序版本 |
| [**publishOwnerPublicSite**](P2Api.md#publishownerpublicsite) | **POST** /v1/public-site/publish | 发布熊舍公开主页 |
| [**rollbackMiniprogramRelease**](P2Api.md#rollbackminiprogramrelease) | **POST** /v1/miniprogram/releases/{release_id}/rollback | 回滚小程序版本 |
| [**startStudDeal**](P2Api.md#startstuddeal) | **POST** /v1/stud/deals/{deal_id}/start | 开始跨舍借配单 |
| [**submitMiniprogramRelease**](P2Api.md#submitminiprogramrelease) | **POST** /v1/miniprogram/releases/{release_id}/submit | 提交小程序审核 |
| [**unpublishOwnerPublicSite**](P2Api.md#unpublishownerpublicsite) | **POST** /v1/public-site/unpublish | 撤下熊舍公开主页 |
| [**unpublishStudListing**](P2Api.md#unpublishstudlisting) | **POST** /v1/stud/listings/{listing_id}/unpublish | 撤下种公挂牌 |
| [**upsertMiniprogramConfig**](P2Api.md#upsertminiprogramconfigoperation) | **PUT** /v1/miniprogram/config | 保存小程序配置 |
| [**upsertOwnerPublicSite**](P2Api.md#upsertownerpublicsite) | **PUT** /v1/public-site | 保存熊舍公开主页 |



## askAssistant

> AssistantAnswerResponse askAssistant(assistantAskRequest, idempotencyKey)

向只读助手提问

需要 Bearer 令牌；当前熊舍成员可查询本舍结构化数据；助手不修改业务数据。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { AskAssistantRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  const body = {
    // AssistantAskRequest
    assistantAskRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies AskAssistantRequest;

  try {
    const data = await api.askAssistant(body);
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
| **assistantAskRequest** | [AssistantAskRequest](AssistantAskRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**AssistantAnswerResponse**](AssistantAnswerResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 向只读助手提问成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


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


## auditMiniprogramRelease

> MiniprogramReleaseResponse auditMiniprogramRelease(releaseId, auditMiniprogramReleaseRequest, idempotencyKey)

审核小程序版本

需要 Bearer 令牌；当前熊舍成员可在沙箱审核流水中通过或驳回版本。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { AuditMiniprogramReleaseOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  const body = {
    // string | 版本 ID
    releaseId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // AuditMiniprogramReleaseRequest
    auditMiniprogramReleaseRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies AuditMiniprogramReleaseOperationRequest;

  try {
    const data = await api.auditMiniprogramRelease(body);
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
| **releaseId** | `string` | 版本 ID | [Defaults to `undefined`] |
| **auditMiniprogramReleaseRequest** | [AuditMiniprogramReleaseRequest](AuditMiniprogramReleaseRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**MiniprogramReleaseResponse**](MiniprogramReleaseResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 审核小程序版本成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
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


## cancelStudDeal

> StudDealResponse cancelStudDeal(dealId, idempotencyKey)

取消跨舍借配单

需要 Bearer 令牌；当前熊舍成员可推进本舍借配履约状态。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { CancelStudDealRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  const body = {
    // string | 借配单 ID
    dealId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies CancelStudDealRequest;

  try {
    const data = await api.cancelStudDeal(body);
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
| **dealId** | `string` | 借配单 ID | [Defaults to `undefined`] |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**StudDealResponse**](StudDealResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 取消跨舍借配单成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
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


## completeStudDeal

> StudDealResponse completeStudDeal(dealId, idempotencyKey)

完成跨舍借配单

需要 Bearer 令牌；当前熊舍成员可推进本舍借配履约状态。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { CompleteStudDealRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  const body = {
    // string | 借配单 ID
    dealId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies CompleteStudDealRequest;

  try {
    const data = await api.completeStudDeal(body);
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
| **dealId** | `string` | 借配单 ID | [Defaults to `undefined`] |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**StudDealResponse**](StudDealResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 完成跨舍借配单成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
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


## confirmStudDeal

> StudDealResponse confirmStudDeal(dealId, idempotencyKey)

确认跨舍借配单

需要 Bearer 令牌；当前熊舍成员可推进本舍借配履约状态。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { ConfirmStudDealRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  const body = {
    // string | 借配单 ID
    dealId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies ConfirmStudDealRequest;

  try {
    const data = await api.confirmStudDeal(body);
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
| **dealId** | `string` | 借配单 ID | [Defaults to `undefined`] |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**StudDealResponse**](StudDealResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 确认跨舍借配单成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createAssistantSession

> AssistantSessionResponse createAssistantSession(assistantSessionCreateRequest)

创建会话

需要 Bearer 令牌；可空 body。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { CreateAssistantSessionRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  const body = {
    // AssistantSessionCreateRequest (optional)
    assistantSessionCreateRequest: ...,
  } satisfies CreateAssistantSessionRequest;

  try {
    const data = await api.createAssistantSession(body);
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
| **assistantSessionCreateRequest** | [AssistantSessionCreateRequest](AssistantSessionCreateRequest.md) |  | [Optional] |

### Return type

[**AssistantSessionResponse**](AssistantSessionResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 已创建 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createMiniprogramRelease

> MiniprogramReleaseResponse createMiniprogramRelease(createMiniprogramReleaseRequest, idempotencyKey)

创建小程序版本

需要 Bearer 令牌；当前熊舍成员可创建小程序草稿版本。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { CreateMiniprogramReleaseOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  const body = {
    // CreateMiniprogramReleaseRequest
    createMiniprogramReleaseRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies CreateMiniprogramReleaseOperationRequest;

  try {
    const data = await api.createMiniprogramRelease(body);
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
| **createMiniprogramReleaseRequest** | [CreateMiniprogramReleaseRequest](CreateMiniprogramReleaseRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**MiniprogramReleaseResponse**](MiniprogramReleaseResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 创建小程序版本成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createStudDeal

> StudDealResponse createStudDeal(createStudDealRequest, idempotencyKey)

创建跨舍借配单

需要 Bearer 令牌；当前熊舍成员可创建借配履约记录。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { CreateStudDealOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  const body = {
    // CreateStudDealRequest
    createStudDealRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies CreateStudDealOperationRequest;

  try {
    const data = await api.createStudDeal(body);
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
| **createStudDealRequest** | [CreateStudDealRequest](CreateStudDealRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**StudDealResponse**](StudDealResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 创建跨舍借配单成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createStudListing

> StudListingResponse createStudListing(createStudListingRequest, idempotencyKey)

创建种公借配挂牌

需要 Bearer 令牌；当前熊舍成员可创建本舍种公挂牌。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { CreateStudListingOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  const body = {
    // CreateStudListingRequest
    createStudListingRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies CreateStudListingOperationRequest;

  try {
    const data = await api.createStudListing(body);
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
| **createStudListingRequest** | [CreateStudListingRequest](CreateStudListingRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**StudListingResponse**](StudListingResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 创建种公借配挂牌成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getMiniprogramConfig

> MiniprogramConfigResponse getMiniprogramConfig()

读取小程序配置

需要 Bearer 令牌；当前熊舍成员可读小程序配置。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { GetMiniprogramConfigRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  try {
    const data = await api.getMiniprogramConfig();
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

[**MiniprogramConfigResponse**](MiniprogramConfigResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 读取小程序配置成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getOwnerPublicSite

> PublicSiteResponse getOwnerPublicSite()

读取熊舍公开主页草稿

需要 Bearer 令牌；当前熊舍成员可读本舍公开主页配置。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { GetOwnerPublicSiteRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  try {
    const data = await api.getOwnerPublicSite();
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

[**PublicSiteResponse**](PublicSiteResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 读取熊舍公开主页草稿成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getPublicSiteBySlug

> PublicSiteViewResponse getPublicSiteBySlug(slug)

读取公开主页投影

匿名公开读取；仅返回 published&#x3D;true 的主页投影，未发布或不存在统一返回 404。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { GetPublicSiteBySlugRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const api = new P2Api();

  const body = {
    // string
    slug: slug_example,
  } satisfies GetPublicSiteBySlugRequest;

  try {
    const data = await api.getPublicSiteBySlug(body);
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
| **slug** | `string` |  | [Defaults to `undefined`] |

### Return type

[**PublicSiteViewResponse**](PublicSiteViewResponse.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 读取公开主页投影成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listAssistantMessages

> AssistantMessageListResponse listAssistantMessages(sessionId)

列出会话消息

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { ListAssistantMessagesRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  const body = {
    // string
    sessionId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies ListAssistantMessagesRequest;

  try {
    const data = await api.listAssistantMessages(body);
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
| **sessionId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**AssistantMessageListResponse**](AssistantMessageListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 消息列表 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listAssistantSessions

> AssistantSessionListResponse listAssistantSessions()

列出会话

需要 Bearer 令牌；按 owner_id 隔离。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { ListAssistantSessionsRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  try {
    const data = await api.listAssistantSessions();
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

[**AssistantSessionListResponse**](AssistantSessionListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 会话列表 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listMiniprogramReleases

> MiniprogramReleaseListResponse listMiniprogramReleases()

列出小程序版本

需要 Bearer 令牌；当前熊舍成员可读小程序发布流水。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { ListMiniprogramReleasesRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  try {
    const data = await api.listMiniprogramReleases();
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

[**MiniprogramReleaseListResponse**](MiniprogramReleaseListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 列出小程序版本成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listStudDeals

> StudDealListResponse listStudDeals()

列出跨舍借配单

需要 Bearer 令牌；当前熊舍成员可读本舍借配履约记录。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { ListStudDealsRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  try {
    const data = await api.listStudDeals();
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

[**StudDealListResponse**](StudDealListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 列出跨舍借配单成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listStudListings

> StudListingListResponse listStudListings(mine)

列出种公借配挂牌

需要 Bearer 令牌；当前成员可读公开挂牌及自己的未公开挂牌。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { ListStudListingsRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  const body = {
    // '0' | '1' | 仅查看自己的挂牌时传 1 (optional)
    mine: mine_example,
  } satisfies ListStudListingsRequest;

  try {
    const data = await api.listStudListings(body);
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
| **mine** | `0`, `1` | 仅查看自己的挂牌时传 1 | [Optional] [Defaults to `undefined`] [Enum: 0, 1] |

### Return type

[**StudListingListResponse**](StudListingListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 列出种公借配挂牌成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## publishMiniprogramRelease

> MiniprogramReleaseResponse publishMiniprogramRelease(releaseId, idempotencyKey)

发布小程序版本

需要 Bearer 令牌；当前熊舍成员可发布已审核通过版本。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { PublishMiniprogramReleaseRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  const body = {
    // string | 版本 ID
    releaseId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies PublishMiniprogramReleaseRequest;

  try {
    const data = await api.publishMiniprogramRelease(body);
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
| **releaseId** | `string` | 版本 ID | [Defaults to `undefined`] |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**MiniprogramReleaseResponse**](MiniprogramReleaseResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 发布小程序版本成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## publishOwnerPublicSite

> PublicSiteResponse publishOwnerPublicSite(idempotencyKey)

发布熊舍公开主页

需要 Bearer 令牌；当前熊舍成员可发布本舍公开主页。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { PublishOwnerPublicSiteRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  const body = {
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies PublishOwnerPublicSiteRequest;

  try {
    const data = await api.publishOwnerPublicSite(body);
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
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**PublicSiteResponse**](PublicSiteResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 发布熊舍公开主页成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## rollbackMiniprogramRelease

> MiniprogramReleaseResponse rollbackMiniprogramRelease(releaseId, idempotencyKey)

回滚小程序版本

需要 Bearer 令牌；当前熊舍成员可回滚线上版本。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { RollbackMiniprogramReleaseRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  const body = {
    // string | 版本 ID
    releaseId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies RollbackMiniprogramReleaseRequest;

  try {
    const data = await api.rollbackMiniprogramRelease(body);
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
| **releaseId** | `string` | 版本 ID | [Defaults to `undefined`] |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**MiniprogramReleaseResponse**](MiniprogramReleaseResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 回滚小程序版本成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## startStudDeal

> StudDealResponse startStudDeal(dealId, idempotencyKey)

开始跨舍借配单

需要 Bearer 令牌；当前熊舍成员可推进本舍借配履约状态。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { StartStudDealRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  const body = {
    // string | 借配单 ID
    dealId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies StartStudDealRequest;

  try {
    const data = await api.startStudDeal(body);
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
| **dealId** | `string` | 借配单 ID | [Defaults to `undefined`] |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**StudDealResponse**](StudDealResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 开始跨舍借配单成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## submitMiniprogramRelease

> MiniprogramReleaseResponse submitMiniprogramRelease(releaseId, idempotencyKey)

提交小程序审核

需要 Bearer 令牌；当前熊舍成员可提交草稿或驳回版本。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { SubmitMiniprogramReleaseRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  const body = {
    // string | 版本 ID
    releaseId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies SubmitMiniprogramReleaseRequest;

  try {
    const data = await api.submitMiniprogramRelease(body);
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
| **releaseId** | `string` | 版本 ID | [Defaults to `undefined`] |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**MiniprogramReleaseResponse**](MiniprogramReleaseResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 提交小程序审核成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## unpublishOwnerPublicSite

> PublicSiteResponse unpublishOwnerPublicSite(idempotencyKey)

撤下熊舍公开主页

需要 Bearer 令牌；当前熊舍成员可撤下本舍公开主页。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { UnpublishOwnerPublicSiteRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  const body = {
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies UnpublishOwnerPublicSiteRequest;

  try {
    const data = await api.unpublishOwnerPublicSite(body);
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
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**PublicSiteResponse**](PublicSiteResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 撤下熊舍公开主页成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## unpublishStudListing

> StudListingResponse unpublishStudListing(listingId, idempotencyKey)

撤下种公挂牌

需要 Bearer 令牌；当前熊舍成员可撤下自己的种公挂牌。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { UnpublishStudListingRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  const body = {
    // string | 挂牌 ID
    listingId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies UnpublishStudListingRequest;

  try {
    const data = await api.unpublishStudListing(body);
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
| **listingId** | `string` | 挂牌 ID | [Defaults to `undefined`] |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**StudListingResponse**](StudListingResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 撤下种公挂牌成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## upsertMiniprogramConfig

> MiniprogramConfigResponse upsertMiniprogramConfig(upsertMiniprogramConfigRequest, idempotencyKey)

保存小程序配置

需要 Bearer 令牌；当前熊舍成员可保存小程序配置。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { UpsertMiniprogramConfigOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  const body = {
    // UpsertMiniprogramConfigRequest
    upsertMiniprogramConfigRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies UpsertMiniprogramConfigOperationRequest;

  try {
    const data = await api.upsertMiniprogramConfig(body);
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
| **upsertMiniprogramConfigRequest** | [UpsertMiniprogramConfigRequest](UpsertMiniprogramConfigRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**MiniprogramConfigResponse**](MiniprogramConfigResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 保存小程序配置成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## upsertOwnerPublicSite

> PublicSiteResponse upsertOwnerPublicSite(upsertPublicSiteRequest, idempotencyKey)

保存熊舍公开主页

需要 Bearer 令牌；当前熊舍成员可保存本舍公开主页配置。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P2Api,
} from '@scolvpet/scolvpet-api';
import type { UpsertOwnerPublicSiteRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P2Api(config);

  const body = {
    // UpsertPublicSiteRequest
    upsertPublicSiteRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies UpsertOwnerPublicSiteRequest;

  try {
    const data = await api.upsertOwnerPublicSite(body);
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
| **upsertPublicSiteRequest** | [UpsertPublicSiteRequest](UpsertPublicSiteRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**PublicSiteResponse**](PublicSiteResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 保存熊舍公开主页成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)

