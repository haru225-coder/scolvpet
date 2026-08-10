# GeneticApi

All URIs are relative to *https://api.scolvpet.cn/v1*

| Method | HTTP request | Description |
|------------- | ------------- | -------------|
| [**compareGeneticActual**](GeneticApi.md#comparegeneticactual) | **POST** /v1/genetic/compare-actual | Compare actual litter phenotype counts to core table expectation |
| [**inferGeneticParents**](GeneticApi.md#infergeneticparents) | **POST** /v1/genetic/infer-parents | Infer parent genotypes from litter phenotype counts |
| [**listGeneticFeedbackSummary**](GeneticApi.md#listgeneticfeedbacksummary) | **GET** /v1/genetic/feedback-summary | Summarize historical phenotype prediction feedback |
| [**listGeneticPhenotypeCatalog**](GeneticApi.md#listgeneticphenotypecatalog) | **GET** /v1/genetic/phenotype-catalog | List phenotype series catalog from authority table |
| [**listGeneticTargetCrosses**](GeneticApi.md#listgenetictargetcrosses) | **GET** /v1/genetic/target-crosses | Rank parent pairs that can produce a target phenotype |



## compareGeneticActual

> { [key: string]: any; } compareGeneticActual(requestBody)

Compare actual litter phenotype counts to core table expectation

### Example

```ts
import {
  Configuration,
  GeneticApi,
} from '@scolvpet/scolvpet-api';
import type { CompareGeneticActualRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new GeneticApi(config);

  const body = {
    // { [key: string]: any; }
    requestBody: Object,
  } satisfies CompareGeneticActualRequest;

  try {
    const data = await api.compareGeneticActual(body);
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
| **requestBody** | `{ [key: string]: any; }` |  | |

### Return type

**{ [key: string]: any; }**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | Expected vs actual phenotype comparison |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## inferGeneticParents

> { [key: string]: any; } inferGeneticParents(requestBody)

Infer parent genotypes from litter phenotype counts

Bayesian reverse inference over locus-model genotype pairs given offspring phenotype tallies. Optional sire_genotype_key / dam_genotype_key fix one side.

### Example

```ts
import {
  Configuration,
  GeneticApi,
} from '@scolvpet/scolvpet-api';
import type { InferGeneticParentsRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new GeneticApi(config);

  const body = {
    // { [key: string]: any; }
    requestBody: Object,
  } satisfies InferGeneticParentsRequest;

  try {
    const data = await api.inferGeneticParents(body);
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
| **requestBody** | `{ [key: string]: any; }` |  | |

### Return type

**{ [key: string]: any; }**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | Ranked parent genotype hypotheses and marginals |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listGeneticFeedbackSummary

> { [key: string]: any; } listGeneticFeedbackSummary()

Summarize historical phenotype prediction feedback

### Example

```ts
import {
  Configuration,
  GeneticApi,
} from '@scolvpet/scolvpet-api';
import type { ListGeneticFeedbackSummaryRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new GeneticApi(config);

  try {
    const data = await api.listGeneticFeedbackSummary();
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

**{ [key: string]: any; }**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | Historical prediction deviation grouped by phenotype pair |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listGeneticPhenotypeCatalog

> { [key: string]: any; } listGeneticPhenotypeCatalog()

List phenotype series catalog from authority table

### Example

```ts
import {
  Configuration,
  GeneticApi,
} from '@scolvpet/scolvpet-api';
import type { ListGeneticPhenotypeCatalogRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new GeneticApi(config);

  try {
    const data = await api.listGeneticPhenotypeCatalog();
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

**{ [key: string]: any; }**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | Catalog of series and phenotypes (core breeding table) |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listGeneticTargetCrosses

> { [key: string]: any; } listGeneticTargetCrosses(series, phenotype)

Rank parent pairs that can produce a target phenotype

### Example

```ts
import {
  Configuration,
  GeneticApi,
} from '@scolvpet/scolvpet-api';
import type { ListGeneticTargetCrossesRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new GeneticApi(config);

  const body = {
    // string
    series: series_example,
    // string
    phenotype: phenotype_example,
  } satisfies ListGeneticTargetCrossesRequest;

  try {
    const data = await api.listGeneticTargetCrosses(body);
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
| **series** | `string` |  | [Defaults to `undefined`] |
| **phenotype** | `string` |  | [Defaults to `undefined`] |

### Return type

**{ [key: string]: any; }**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | Ranked crosses for target phenotype |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)

