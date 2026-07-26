# P1CRMApi

All URIs are relative to *https://api.scolvpet.cn/v1*

| Method | HTTP request | Description |
|------------- | ------------- | -------------|
| [**cancelCrmReservation**](P1CRMApi.md#cancelcrmreservation) | **POST** /v1/crm/reservations/{reservation_id}/cancel | 取消客户预订 |
| [**completeCrmHandover**](P1CRMApi.md#completecrmhandover) | **POST** /v1/crm/handovers/{handover_id}/complete | 完成客户交付 |
| [**confirmCrmReservation**](P1CRMApi.md#confirmcrmreservation) | **POST** /v1/crm/reservations/{reservation_id}/confirm | 确认客户预订 |
| [**createCrmContact**](P1CRMApi.md#createcrmcontactoperation) | **POST** /v1/crm/contacts | 创建 CRM 客户 |
| [**createCrmHandover**](P1CRMApi.md#createcrmhandoveroperation) | **POST** /v1/crm/handovers | 创建交付记录 |
| [**createCrmReservation**](P1CRMApi.md#createcrmreservationoperation) | **POST** /v1/crm/reservations | 创建客户预订 |
| [**listCrmContacts**](P1CRMApi.md#listcrmcontacts) | **GET** /v1/crm/contacts | 列出 CRM 客户 |
| [**listCrmHandovers**](P1CRMApi.md#listcrmhandovers) | **GET** /v1/crm/handovers | 列出交付记录 |
| [**listCrmReservations**](P1CRMApi.md#listcrmreservations) | **GET** /v1/crm/reservations | 列出客户预订 |



## cancelCrmReservation

> CrmReservationResponse cancelCrmReservation(reservationId, idempotencyKey)

取消客户预订

需要 Bearer 令牌；当前熊舍成员可取消预订。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1CRMApi,
} from '@scolvpet/scolvpet-api';
import type { CancelCrmReservationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1CRMApi(config);

  const body = {
    // string | 预订 ID
    reservationId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies CancelCrmReservationRequest;

  try {
    const data = await api.cancelCrmReservation(body);
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
| **reservationId** | `string` | 预订 ID | [Defaults to `undefined`] |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**CrmReservationResponse**](CrmReservationResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 取消客户预订成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## completeCrmHandover

> CrmHandoverResponse completeCrmHandover(handoverId, idempotencyKey)

完成客户交付

需要 Bearer 令牌；当前熊舍成员可完成交付并闭合关联预订。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1CRMApi,
} from '@scolvpet/scolvpet-api';
import type { CompleteCrmHandoverRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1CRMApi(config);

  const body = {
    // string | 交付 ID
    handoverId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies CompleteCrmHandoverRequest;

  try {
    const data = await api.completeCrmHandover(body);
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
| **handoverId** | `string` | 交付 ID | [Defaults to `undefined`] |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**CrmHandoverResponse**](CrmHandoverResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 完成客户交付成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## confirmCrmReservation

> CrmReservationResponse confirmCrmReservation(reservationId, idempotencyKey)

确认客户预订

需要 Bearer 令牌；当前熊舍成员可推进预订状态。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1CRMApi,
} from '@scolvpet/scolvpet-api';
import type { ConfirmCrmReservationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1CRMApi(config);

  const body = {
    // string | 预订 ID
    reservationId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies ConfirmCrmReservationRequest;

  try {
    const data = await api.confirmCrmReservation(body);
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
| **reservationId** | `string` | 预订 ID | [Defaults to `undefined`] |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**CrmReservationResponse**](CrmReservationResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 确认客户预订成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createCrmContact

> CrmContactResponse createCrmContact(createCrmContactRequest, idempotencyKey)

创建 CRM 客户

需要 Bearer 令牌；当前熊舍成员可创建客户档案。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1CRMApi,
} from '@scolvpet/scolvpet-api';
import type { CreateCrmContactOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1CRMApi(config);

  const body = {
    // CreateCrmContactRequest
    createCrmContactRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies CreateCrmContactOperationRequest;

  try {
    const data = await api.createCrmContact(body);
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
| **createCrmContactRequest** | [CreateCrmContactRequest](CreateCrmContactRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**CrmContactResponse**](CrmContactResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 创建 CRM 客户成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createCrmHandover

> CrmHandoverResponse createCrmHandover(createCrmHandoverRequest, idempotencyKey)

创建交付记录

需要 Bearer 令牌；当前熊舍成员可创建交付记录。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1CRMApi,
} from '@scolvpet/scolvpet-api';
import type { CreateCrmHandoverOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1CRMApi(config);

  const body = {
    // CreateCrmHandoverRequest
    createCrmHandoverRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies CreateCrmHandoverOperationRequest;

  try {
    const data = await api.createCrmHandover(body);
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
| **createCrmHandoverRequest** | [CreateCrmHandoverRequest](CreateCrmHandoverRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**CrmHandoverResponse**](CrmHandoverResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 创建交付记录成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createCrmReservation

> CrmReservationResponse createCrmReservation(createCrmReservationRequest, idempotencyKey)

创建客户预订

需要 Bearer 令牌；当前熊舍成员可创建预订记录。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1CRMApi,
} from '@scolvpet/scolvpet-api';
import type { CreateCrmReservationOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1CRMApi(config);

  const body = {
    // CreateCrmReservationRequest
    createCrmReservationRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies CreateCrmReservationOperationRequest;

  try {
    const data = await api.createCrmReservation(body);
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
| **createCrmReservationRequest** | [CreateCrmReservationRequest](CreateCrmReservationRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**CrmReservationResponse**](CrmReservationResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 创建客户预订成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listCrmContacts

> CrmContactListResponse listCrmContacts()

列出 CRM 客户

需要 Bearer 令牌；当前熊舍成员可读客户档案。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1CRMApi,
} from '@scolvpet/scolvpet-api';
import type { ListCrmContactsRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1CRMApi(config);

  try {
    const data = await api.listCrmContacts();
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

[**CrmContactListResponse**](CrmContactListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 列出 CRM 客户成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listCrmHandovers

> CrmHandoverListResponse listCrmHandovers()

列出交付记录

需要 Bearer 令牌；当前熊舍成员可读交付记录。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1CRMApi,
} from '@scolvpet/scolvpet-api';
import type { ListCrmHandoversRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1CRMApi(config);

  try {
    const data = await api.listCrmHandovers();
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

[**CrmHandoverListResponse**](CrmHandoverListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 列出交付记录成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listCrmReservations

> CrmReservationListResponse listCrmReservations()

列出客户预订

需要 Bearer 令牌；当前熊舍成员可读预订记录。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1CRMApi,
} from '@scolvpet/scolvpet-api';
import type { ListCrmReservationsRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1CRMApi(config);

  try {
    const data = await api.listCrmReservations();
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

[**CrmReservationListResponse**](CrmReservationListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 列出客户预订成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)

