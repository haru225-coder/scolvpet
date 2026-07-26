# PublicGrowthApi

All URIs are relative to *https://api.scolvpet.cn/v1*

| Method | HTTP request | Description |
|------------- | ------------- | -------------|
| [**consultPublicGrowthAdvisor**](PublicGrowthApi.md#consultpublicgrowthadvisor) | **POST** /v1/public/sites/{slug}/consult | 向公开 AI 顾问咨询 |
| [**createPublicGrowthLead**](PublicGrowthApi.md#createpublicgrowthlead) | **POST** /v1/public/sites/{slug}/leads | 提交公开咨询线索 |
| [**createPublicGrowthReservation**](PublicGrowthApi.md#createpublicgrowthreservation) | **POST** /v1/public/sites/{slug}/reservations | 客户提交公开仓鼠预订 |
| [**getPublicGrowthCatalog**](PublicGrowthApi.md#getpublicgrowthcatalog) | **GET** /v1/public/sites/{slug}/catalog | 查看公开熊舍获客目录 |
| [**getPublicGrowthMedia**](PublicGrowthApi.md#getpublicgrowthmedia) | **GET** /v1/public/sites/{slug}/media/{media_id} | 读取公开仓鼠封面图片 |
| [**getPublicSiteHamsterPedigree**](PublicGrowthApi.md#getpublicsitehamsterpedigree) | **GET** /v1/public/sites/{slug}/hamsters/{hamster_id}/pedigree | 公开仓鼠血统（仅已发布档案名称） |
| [**postPublicSiteSimulate**](PublicGrowthApi.md#postpublicsitesimulateoperation) | **POST** /v1/public/sites/{slug}/simulate | 公开繁育模拟（权威表型表） |



## consultPublicGrowthAdvisor

> PublicGrowthConsultResponse consultPublicGrowthAdvisor(slug, publicGrowthConsultRequest)

向公开 AI 顾问咨询

### Example

```ts
import {
  Configuration,
  PublicGrowthApi,
} from '@scolvpet/scolvpet-api';
import type { ConsultPublicGrowthAdvisorRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const api = new PublicGrowthApi();

  const body = {
    // string
    slug: slug_example,
    // PublicGrowthConsultRequest
    publicGrowthConsultRequest: ...,
  } satisfies ConsultPublicGrowthAdvisorRequest;

  try {
    const data = await api.consultPublicGrowthAdvisor(body);
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
| **publicGrowthConsultRequest** | [PublicGrowthConsultRequest](PublicGrowthConsultRequest.md) |  | |

### Return type

[**PublicGrowthConsultResponse**](PublicGrowthConsultResponse.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | AI 顾问回答和公开资料匹配结果 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createPublicGrowthLead

> PublicGrowthLeadResponse createPublicGrowthLead(slug, publicGrowthLeadRequest, idempotencyKey)

提交公开咨询线索

### Example

```ts
import {
  Configuration,
  PublicGrowthApi,
} from '@scolvpet/scolvpet-api';
import type { CreatePublicGrowthLeadRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const api = new PublicGrowthApi();

  const body = {
    // string
    slug: slug_example,
    // PublicGrowthLeadRequest
    publicGrowthLeadRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies CreatePublicGrowthLeadRequest;

  try {
    const data = await api.createPublicGrowthLead(body);
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
| **publicGrowthLeadRequest** | [PublicGrowthLeadRequest](PublicGrowthLeadRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**PublicGrowthLeadResponse**](PublicGrowthLeadResponse.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 线索已进入 CRM 并记录来源 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createPublicGrowthReservation

> PublicGrowthReservationResponse createPublicGrowthReservation(slug, publicGrowthReservationRequest, idempotencyKey)

客户提交公开仓鼠预订

客户从前台对真实 hamster 创建统一 crm_reservation（status&#x3D;held）。 必须传 hamster_id；Backend 校验公开可订与排他；禁止手填品种/毛色。 需要客户短信验证后的 Bearer ct_* customer session。 

### Example

```ts
import {
  Configuration,
  PublicGrowthApi,
} from '@scolvpet/scolvpet-api';
import type { CreatePublicGrowthReservationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: customerBearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new PublicGrowthApi(config);

  const body = {
    // string
    slug: slug_example,
    // PublicGrowthReservationRequest
    publicGrowthReservationRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies CreatePublicGrowthReservationRequest;

  try {
    const data = await api.createPublicGrowthReservation(body);
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
| **publicGrowthReservationRequest** | [PublicGrowthReservationRequest](PublicGrowthReservationRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**PublicGrowthReservationResponse**](PublicGrowthReservationResponse.md)

### Authorization

[customerBearerAuth](../README.md#customerBearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 预订已创建，宠舍 App CRM 可见 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getPublicGrowthCatalog

> PublicGrowthCatalogResponse getPublicGrowthCatalog(slug, campaign)

查看公开熊舍获客目录

### Example

```ts
import {
  Configuration,
  PublicGrowthApi,
} from '@scolvpet/scolvpet-api';
import type { GetPublicGrowthCatalogRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const api = new PublicGrowthApi();

  const body = {
    // string
    slug: slug_example,
    // string (optional)
    campaign: campaign_example,
  } satisfies GetPublicGrowthCatalogRequest;

  try {
    const data = await api.getPublicGrowthCatalog(body);
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
| **campaign** | `string` |  | [Optional] [Defaults to `undefined`] |

### Return type

[**PublicGrowthCatalogResponse**](PublicGrowthCatalogResponse.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 公开主页、仓鼠目录和活动主题 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getPublicGrowthMedia

> Blob getPublicGrowthMedia(slug, mediaId)

读取公开仓鼠封面图片

匿名公开读取；仅允许读取已发布主页中已公开仓鼠当前选择的封面图片，撤下主页或公开资料后统一返回 404。

### Example

```ts
import {
  Configuration,
  PublicGrowthApi,
} from '@scolvpet/scolvpet-api';
import type { GetPublicGrowthMediaRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const api = new PublicGrowthApi();

  const body = {
    // string
    slug: slug_example,
    // string
    mediaId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies GetPublicGrowthMediaRequest;

  try {
    const data = await api.getPublicGrowthMedia(body);
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
| **mediaId** | `string` |  | [Defaults to `undefined`] |

### Return type

**Blob**

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `image/*`, `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 公开封面图片 |  * Cache-Control -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getPublicSiteHamsterPedigree

> getPublicSiteHamsterPedigree(slug, hamsterId, generations)

公开仓鼠血统（仅已发布档案名称）

### Example

```ts
import {
  Configuration,
  PublicGrowthApi,
} from '@scolvpet/scolvpet-api';
import type { GetPublicSiteHamsterPedigreeRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const api = new PublicGrowthApi();

  const body = {
    // string
    slug: slug_example,
    // string
    hamsterId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // number (optional)
    generations: 56,
  } satisfies GetPublicSiteHamsterPedigreeRequest;

  try {
    const data = await api.getPublicSiteHamsterPedigree(body);
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
| **hamsterId** | `string` |  | [Defaults to `undefined`] |
| **generations** | `number` |  | [Optional] [Defaults to `3`] |

### Return type

`void` (Empty response body)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 公开血统图节点与边 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## postPublicSiteSimulate

> postPublicSiteSimulate(slug, postPublicSiteSimulateRequest)

公开繁育模拟（权威表型表）

可对已发布仓鼠配对做只读表型推算；也可直接传 series + 父母表型。

### Example

```ts
import {
  Configuration,
  PublicGrowthApi,
} from '@scolvpet/scolvpet-api';
import type { PostPublicSiteSimulateOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const api = new PublicGrowthApi();

  const body = {
    // string
    slug: slug_example,
    // PostPublicSiteSimulateRequest
    postPublicSiteSimulateRequest: ...,
  } satisfies PostPublicSiteSimulateOperationRequest;

  try {
    const data = await api.postPublicSiteSimulate(body);
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
| **postPublicSiteSimulateRequest** | [PostPublicSiteSimulateRequest](PostPublicSiteSimulateRequest.md) |  | |

### Return type

`void` (Empty response body)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 模拟结果与为什么说明 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)

