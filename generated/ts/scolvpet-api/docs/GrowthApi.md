# GrowthApi

All URIs are relative to *https://api.scolvpet.cn/v1*

| Method | HTTP request | Description |
|------------- | ------------- | -------------|
| [**archiveGrowthCampaign**](GrowthApi.md#archivegrowthcampaign) | **POST** /v1/growth/campaigns/{campaign_id}/archive | 归档获客活动 |
| [**generateGrowthCampaign**](GrowthApi.md#generategrowthcampaign) | **POST** /v1/growth/campaigns/generate | 生成并保存视频或直播脚本 |
| [**getGrowthCampaign**](GrowthApi.md#getgrowthcampaign) | **GET** /v1/growth/campaigns/{campaign_id} | 查看获客活动详情 |
| [**listGrowthCampaigns**](GrowthApi.md#listgrowthcampaigns) | **GET** /v1/growth/campaigns | 查看获客活动 |
| [**listGrowthLeads**](GrowthApi.md#listgrowthleads) | **GET** /v1/growth/leads | 查看获客线索及来源归因 |
| [**listGrowthOpportunities**](GrowthApi.md#listgrowthopportunities) | **GET** /v1/growth/opportunities | 查看 AI 内容机会 |
| [**listGrowthPublicHamsters**](GrowthApi.md#listgrowthpublichamsters) | **GET** /v1/growth/public-hamsters | 查看本舍仓鼠公开资料 |
| [**publishGrowthCampaign**](GrowthApi.md#publishgrowthcampaign) | **POST** /v1/growth/campaigns/{campaign_id}/publish | 发布获客活动 |
| [**upsertGrowthPublicHamster**](GrowthApi.md#upsertgrowthpublichamster) | **PUT** /v1/growth/public-hamsters/{hamster_id} | 保存仓鼠公开资料 |



## archiveGrowthCampaign

> GrowthCampaignResponse archiveGrowthCampaign(campaignId, idempotencyKey)

归档获客活动

### Example

```ts
import {
  Configuration,
  GrowthApi,
} from '@scolvpet/scolvpet-api';
import type { ArchiveGrowthCampaignRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new GrowthApi(config);

  const body = {
    // string
    campaignId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies ArchiveGrowthCampaignRequest;

  try {
    const data = await api.archiveGrowthCampaign(body);
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
| **campaignId** | `string` |  | [Defaults to `undefined`] |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**GrowthCampaignResponse**](GrowthCampaignResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 活动已归档 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## generateGrowthCampaign

> GrowthCampaignResponse generateGrowthCampaign(growthCampaignGenerateRequest, idempotencyKey)

生成并保存视频或直播脚本

### Example

```ts
import {
  Configuration,
  GrowthApi,
} from '@scolvpet/scolvpet-api';
import type { GenerateGrowthCampaignRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new GrowthApi(config);

  const body = {
    // GrowthCampaignGenerateRequest
    growthCampaignGenerateRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies GenerateGrowthCampaignRequest;

  try {
    const data = await api.generateGrowthCampaign(body);
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
| **growthCampaignGenerateRequest** | [GrowthCampaignGenerateRequest](GrowthCampaignGenerateRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**GrowthCampaignResponse**](GrowthCampaignResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 脚本活动已保存 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getGrowthCampaign

> GrowthCampaignResponse getGrowthCampaign(campaignId)

查看获客活动详情

### Example

```ts
import {
  Configuration,
  GrowthApi,
} from '@scolvpet/scolvpet-api';
import type { GetGrowthCampaignRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new GrowthApi(config);

  const body = {
    // string
    campaignId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies GetGrowthCampaignRequest;

  try {
    const data = await api.getGrowthCampaign(body);
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
| **campaignId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**GrowthCampaignResponse**](GrowthCampaignResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 获客活动详情 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listGrowthCampaigns

> GrowthCampaignListResponse listGrowthCampaigns()

查看获客活动

### Example

```ts
import {
  Configuration,
  GrowthApi,
} from '@scolvpet/scolvpet-api';
import type { ListGrowthCampaignsRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new GrowthApi(config);

  try {
    const data = await api.listGrowthCampaigns();
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

[**GrowthCampaignListResponse**](GrowthCampaignListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 获客活动列表 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listGrowthLeads

> GrowthLeadListResponse listGrowthLeads()

查看获客线索及来源归因

### Example

```ts
import {
  Configuration,
  GrowthApi,
} from '@scolvpet/scolvpet-api';
import type { ListGrowthLeadsRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new GrowthApi(config);

  try {
    const data = await api.listGrowthLeads();
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

[**GrowthLeadListResponse**](GrowthLeadListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 线索列表 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listGrowthOpportunities

> GrowthOpportunityListResponse listGrowthOpportunities()

查看 AI 内容机会

### Example

```ts
import {
  Configuration,
  GrowthApi,
} from '@scolvpet/scolvpet-api';
import type { ListGrowthOpportunitiesRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new GrowthApi(config);

  try {
    const data = await api.listGrowthOpportunities();
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

[**GrowthOpportunityListResponse**](GrowthOpportunityListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 基于公开资料生成的内容机会 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listGrowthPublicHamsters

> GrowthPublicHamsterListResponse listGrowthPublicHamsters()

查看本舍仓鼠公开资料

### Example

```ts
import {
  Configuration,
  GrowthApi,
} from '@scolvpet/scolvpet-api';
import type { ListGrowthPublicHamstersRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new GrowthApi(config);

  try {
    const data = await api.listGrowthPublicHamsters();
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

[**GrowthPublicHamsterListResponse**](GrowthPublicHamsterListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 公开资料列表 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## publishGrowthCampaign

> GrowthCampaignResponse publishGrowthCampaign(campaignId, idempotencyKey)

发布获客活动

### Example

```ts
import {
  Configuration,
  GrowthApi,
} from '@scolvpet/scolvpet-api';
import type { PublishGrowthCampaignRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new GrowthApi(config);

  const body = {
    // string
    campaignId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies PublishGrowthCampaignRequest;

  try {
    const data = await api.publishGrowthCampaign(body);
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
| **campaignId** | `string` |  | [Defaults to `undefined`] |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**GrowthCampaignResponse**](GrowthCampaignResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 活动已发布 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## upsertGrowthPublicHamster

> GrowthPublicHamsterResponse upsertGrowthPublicHamster(hamsterId, growthPublicHamsterRequest, idempotencyKey)

保存仓鼠公开资料

### Example

```ts
import {
  Configuration,
  GrowthApi,
} from '@scolvpet/scolvpet-api';
import type { UpsertGrowthPublicHamsterRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new GrowthApi(config);

  const body = {
    // string
    hamsterId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // GrowthPublicHamsterRequest
    growthPublicHamsterRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies UpsertGrowthPublicHamsterRequest;

  try {
    const data = await api.upsertGrowthPublicHamster(body);
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
| **hamsterId** | `string` |  | [Defaults to `undefined`] |
| **growthPublicHamsterRequest** | [GrowthPublicHamsterRequest](GrowthPublicHamsterRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**GrowthPublicHamsterResponse**](GrowthPublicHamsterResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 公开资料已保存 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)

