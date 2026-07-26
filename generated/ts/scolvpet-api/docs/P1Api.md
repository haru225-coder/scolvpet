# P1Api

All URIs are relative to *https://api.scolvpet.cn/v1*

| Method | HTTP request | Description |
|------------- | ------------- | -------------|
| [**checkEntitlement**](P1Api.md#checkentitlement) | **POST** /v1/entitlements/check | 检查功能或指标权益 |
| [**createAccountingCategory**](P1Api.md#createaccountingcategoryoperation) | **POST** /v1/accounting/categories | 创建记账分类 |
| [**createAccountingRecord**](P1Api.md#createaccountingrecordoperation) | **POST** /v1/accounting/records | 创建记账流水 |
| [**createContract**](P1Api.md#createcontractoperation) | **POST** /v1/contracts | 创建合同单据 |
| [**createContractTemplate**](P1Api.md#createcontracttemplate) | **POST** /v1/contracts/templates | 创建合同模板 |
| [**createGeneticProfile**](P1Api.md#creategeneticprofileoperation) | **POST** /v1/genetic/profiles | 创建遗传档案 |
| [**createPushMessage**](P1Api.md#createpushmessageoperation) | **POST** /v1/push/messages | 创建推送消息 |
| [**createReceipt**](P1Api.md#createreceiptoperation) | **POST** /v1/receipts | 创建回执单据 |
| [**createReceiptTemplate**](P1Api.md#createreceipttemplate) | **POST** /v1/receipts/templates | 创建回执模板 |
| [**disablePushDevice**](P1Api.md#disablepushdevice) | **DELETE** /v1/push/devices/{device_id} | 停用推送设备 |
| [**getAccountingSummary**](P1Api.md#getaccountingsummary) | **GET** /v1/accounting/summary | 读取记账汇总 |
| [**getCurrentEntitlement**](P1Api.md#getcurrententitlement) | **GET** /v1/entitlements/current | 读取当前权益快照 |
| [**getEntitlementCatalog**](P1Api.md#getentitlementcatalog) | **GET** /v1/entitlements/catalog | 读取权益套餐目录 |
| [**inviteOrganizationMember**](P1Api.md#inviteorganizationmemberoperation) | **POST** /v1/organization-members | 邀请熊舍成员 |
| [**issueContract**](P1Api.md#issuecontract) | **POST** /v1/contracts/{document_id}/issue | 签发合同 |
| [**issueReceipt**](P1Api.md#issuereceipt) | **POST** /v1/receipts/{document_id}/issue | 签发回执 |
| [**listAccountingCategories**](P1Api.md#listaccountingcategories) | **GET** /v1/accounting/categories | 列出记账分类 |
| [**listAccountingRecords**](P1Api.md#listaccountingrecords) | **GET** /v1/accounting/records | 列出记账流水 |
| [**listContractTemplates**](P1Api.md#listcontracttemplates) | **GET** /v1/contracts/templates | 列出合同模板 |
| [**listContracts**](P1Api.md#listcontracts) | **GET** /v1/contracts | 列出合同单据 |
| [**listGeneticLoci**](P1Api.md#listgeneticloci) | **GET** /v1/genetic/loci | 列出遗传位点 |
| [**listGeneticProfiles**](P1Api.md#listgeneticprofiles) | **GET** /v1/genetic/profiles | 列出遗传档案 |
| [**listOrganizationMembers**](P1Api.md#listorganizationmembers) | **GET** /v1/organization-members | 列出熊舍成员 |
| [**listPushDevices**](P1Api.md#listpushdevices) | **GET** /v1/push/devices | 列出推送设备 |
| [**listPushMessages**](P1Api.md#listpushmessages) | **GET** /v1/push/messages | 列出推送消息 |
| [**listReceiptTemplates**](P1Api.md#listreceipttemplates) | **GET** /v1/receipts/templates | 列出回执模板 |
| [**listReceipts**](P1Api.md#listreceipts) | **GET** /v1/receipts | 列出回执单据 |
| [**revokeContract**](P1Api.md#revokecontract) | **POST** /v1/contracts/{document_id}/revoke | 撤销合同 |
| [**revokeOrganizationMember**](P1Api.md#revokeorganizationmember) | **POST** /v1/organization-members/{member_id}/revoke | 撤销熊舍成员 |
| [**revokeReceipt**](P1Api.md#revokereceipt) | **POST** /v1/receipts/{document_id}/revoke | 撤销回执 |
| [**sandboxActivatePlan**](P1Api.md#sandboxactivateplanoperation) | **POST** /v1/entitlements/sandbox/activate | 沙箱激活权益套餐 |
| [**simulateGeneticBreeding**](P1Api.md#simulategeneticbreeding) | **POST** /v1/genetic/simulate | 模拟遗传配对 |
| [**updateOrganizationMember**](P1Api.md#updateorganizationmemberoperation) | **PATCH** /v1/organization-members/{member_id} | 更新熊舍成员 |
| [**upsertPushDevice**](P1Api.md#upsertpushdeviceoperation) | **PUT** /v1/push/devices | 登记推送设备 |



## checkEntitlement

> EntitlementCheckResponse checkEntitlement(entitlementCheckRequest, idempotencyKey)

检查功能或指标权益

需要 Bearer 令牌；当前熊舍成员可检查本舍功能与指标门限。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { CheckEntitlementRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  const body = {
    // EntitlementCheckRequest
    entitlementCheckRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies CheckEntitlementRequest;

  try {
    const data = await api.checkEntitlement(body);
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
| **entitlementCheckRequest** | [EntitlementCheckRequest](EntitlementCheckRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**EntitlementCheckResponse**](EntitlementCheckResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 检查功能或指标权益成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createAccountingCategory

> AccountingCategoryResponse createAccountingCategory(createAccountingCategoryRequest, idempotencyKey)

创建记账分类

需要 Bearer 令牌；当前熊舍成员可创建记账分类。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { CreateAccountingCategoryOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  const body = {
    // CreateAccountingCategoryRequest
    createAccountingCategoryRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies CreateAccountingCategoryOperationRequest;

  try {
    const data = await api.createAccountingCategory(body);
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
| **createAccountingCategoryRequest** | [CreateAccountingCategoryRequest](CreateAccountingCategoryRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**AccountingCategoryResponse**](AccountingCategoryResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 创建记账分类成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createAccountingRecord

> AccountingRecordResponse createAccountingRecord(createAccountingRecordRequest, idempotencyKey)

创建记账流水

需要 Bearer 令牌；当前熊舍成员可创建记账流水。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { CreateAccountingRecordOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  const body = {
    // CreateAccountingRecordRequest
    createAccountingRecordRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies CreateAccountingRecordOperationRequest;

  try {
    const data = await api.createAccountingRecord(body);
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
| **createAccountingRecordRequest** | [CreateAccountingRecordRequest](CreateAccountingRecordRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**AccountingRecordResponse**](AccountingRecordResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 创建记账流水成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createContract

> DocumentResponse createContract(createContractRequest, idempotencyKey)

创建合同单据

需要 Bearer 令牌；当前熊舍成员可创建合同草稿。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { CreateContractOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  const body = {
    // CreateContractRequest
    createContractRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies CreateContractOperationRequest;

  try {
    const data = await api.createContract(body);
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
| **createContractRequest** | [CreateContractRequest](CreateContractRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**DocumentResponse**](DocumentResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 创建合同单据成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createContractTemplate

> DocumentTemplateResponse createContractTemplate(createDocumentTemplateRequest, idempotencyKey)

创建合同模板

需要 Bearer 令牌；当前熊舍成员可创建合同模板。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { CreateContractTemplateRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  const body = {
    // CreateDocumentTemplateRequest
    createDocumentTemplateRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies CreateContractTemplateRequest;

  try {
    const data = await api.createContractTemplate(body);
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
| **createDocumentTemplateRequest** | [CreateDocumentTemplateRequest](CreateDocumentTemplateRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**DocumentTemplateResponse**](DocumentTemplateResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 创建合同模板成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createGeneticProfile

> GeneticProfileResponse createGeneticProfile(createGeneticProfileRequest, idempotencyKey)

创建遗传档案

需要 Bearer 令牌；当前熊舍成员可创建遗传档案。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { CreateGeneticProfileOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  const body = {
    // CreateGeneticProfileRequest
    createGeneticProfileRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies CreateGeneticProfileOperationRequest;

  try {
    const data = await api.createGeneticProfile(body);
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
| **createGeneticProfileRequest** | [CreateGeneticProfileRequest](CreateGeneticProfileRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**GeneticProfileResponse**](GeneticProfileResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 创建遗传档案成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createPushMessage

> PushMessageResponse createPushMessage(createPushMessageRequest, idempotencyKey)

创建推送消息

需要 Bearer 令牌；当前熊舍成员可发送测试或业务推送。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { CreatePushMessageOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  const body = {
    // CreatePushMessageRequest
    createPushMessageRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies CreatePushMessageOperationRequest;

  try {
    const data = await api.createPushMessage(body);
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
| **createPushMessageRequest** | [CreatePushMessageRequest](CreatePushMessageRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**PushMessageResponse**](PushMessageResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 创建推送消息成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createReceipt

> DocumentResponse createReceipt(createReceiptRequest, idempotencyKey)

创建回执单据

需要 Bearer 令牌；当前熊舍成员可创建回执草稿。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { CreateReceiptOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  const body = {
    // CreateReceiptRequest
    createReceiptRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies CreateReceiptOperationRequest;

  try {
    const data = await api.createReceipt(body);
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
| **createReceiptRequest** | [CreateReceiptRequest](CreateReceiptRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**DocumentResponse**](DocumentResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 创建回执单据成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createReceiptTemplate

> DocumentTemplateResponse createReceiptTemplate(createDocumentTemplateRequest, idempotencyKey)

创建回执模板

需要 Bearer 令牌；当前熊舍成员可创建回执模板。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { CreateReceiptTemplateRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  const body = {
    // CreateDocumentTemplateRequest
    createDocumentTemplateRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies CreateReceiptTemplateRequest;

  try {
    const data = await api.createReceiptTemplate(body);
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
| **createDocumentTemplateRequest** | [CreateDocumentTemplateRequest](CreateDocumentTemplateRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**DocumentTemplateResponse**](DocumentTemplateResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 创建回执模板成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## disablePushDevice

> PushDeviceResponse disablePushDevice(deviceId, idempotencyKey)

停用推送设备

需要 Bearer 令牌；当前熊舍成员可停用自己的推送设备。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { DisablePushDeviceRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  const body = {
    // string | 设备 ID
    deviceId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies DisablePushDeviceRequest;

  try {
    const data = await api.disablePushDevice(body);
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
| **deviceId** | `string` | 设备 ID | [Defaults to `undefined`] |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**PushDeviceResponse**](PushDeviceResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 停用推送设备成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getAccountingSummary

> AccountingSummaryResponse getAccountingSummary(entryType, from, to)

读取记账汇总

需要 Bearer 令牌；当前熊舍成员可读收支汇总。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { GetAccountingSummaryRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  const body = {
    // 'income' | 'expense' | 按收支类型筛选 (optional)
    entryType: entryType_example,
    // Date | 起始时间 (optional)
    from: 2013-10-20T19:20:30+01:00,
    // Date | 结束时间 (optional)
    to: 2013-10-20T19:20:30+01:00,
  } satisfies GetAccountingSummaryRequest;

  try {
    const data = await api.getAccountingSummary(body);
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
| **entryType** | `income`, `expense` | 按收支类型筛选 | [Optional] [Defaults to `undefined`] [Enum: income, expense] |
| **from** | `Date` | 起始时间 | [Optional] [Defaults to `undefined`] |
| **to** | `Date` | 结束时间 | [Optional] [Defaults to `undefined`] |

### Return type

[**AccountingSummaryResponse**](AccountingSummaryResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 读取记账汇总成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getCurrentEntitlement

> EntitlementSnapshotResponse getCurrentEntitlement()

读取当前权益快照

需要 Bearer 令牌；当前熊舍成员可读本舍权益与用量门限。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { GetCurrentEntitlementRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  try {
    const data = await api.getCurrentEntitlement();
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

[**EntitlementSnapshotResponse**](EntitlementSnapshotResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 读取当前权益快照成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getEntitlementCatalog

> EntitlementCatalogResponse getEntitlementCatalog()

读取权益套餐目录

需要 Bearer 令牌；当前熊舍成员可读公开套餐与功能目录。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { GetEntitlementCatalogRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  try {
    const data = await api.getEntitlementCatalog();
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

[**EntitlementCatalogResponse**](EntitlementCatalogResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 读取权益套餐目录成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## inviteOrganizationMember

> OrganizationMemberResponse inviteOrganizationMember(inviteOrganizationMemberRequest, idempotencyKey)

邀请熊舍成员

需要 Bearer 令牌；仅舍主可邀请成员。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { InviteOrganizationMemberOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  const body = {
    // InviteOrganizationMemberRequest
    inviteOrganizationMemberRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies InviteOrganizationMemberOperationRequest;

  try {
    const data = await api.inviteOrganizationMember(body);
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
| **inviteOrganizationMemberRequest** | [InviteOrganizationMemberRequest](InviteOrganizationMemberRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**OrganizationMemberResponse**](OrganizationMemberResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 邀请熊舍成员成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **403** | 当前成员角色缺少执行该操作的权限 |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## issueContract

> DocumentResponse issueContract(documentId, ifMatch, idempotencyKey)

签发合同

需要 Bearer 令牌；当前熊舍成员可签发合同草稿。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { IssueContractRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  const body = {
    // string | 合同单据 ID
    documentId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。 
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
  } satisfies IssueContractRequest;

  try {
    const data = await api.issueContract(body);
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
| **documentId** | `string` | 合同单据 ID | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |

### Return type

[**DocumentResponse**](DocumentResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 签发合同成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## issueReceipt

> DocumentResponse issueReceipt(documentId, ifMatch, idempotencyKey)

签发回执

需要 Bearer 令牌；当前熊舍成员可签发回执草稿。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { IssueReceiptRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  const body = {
    // string | 回执单据 ID
    documentId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。 
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
  } satisfies IssueReceiptRequest;

  try {
    const data = await api.issueReceipt(body);
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
| **documentId** | `string` | 回执单据 ID | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |

### Return type

[**DocumentResponse**](DocumentResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 签发回执成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listAccountingCategories

> AccountingCategoryListResponse listAccountingCategories(entryType)

列出记账分类

需要 Bearer 令牌；当前熊舍成员可读记账分类。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { ListAccountingCategoriesRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  const body = {
    // 'income' | 'expense' | 按收入或支出筛选 (optional)
    entryType: entryType_example,
  } satisfies ListAccountingCategoriesRequest;

  try {
    const data = await api.listAccountingCategories(body);
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
| **entryType** | `income`, `expense` | 按收入或支出筛选 | [Optional] [Defaults to `undefined`] [Enum: income, expense] |

### Return type

[**AccountingCategoryListResponse**](AccountingCategoryListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 列出记账分类成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listAccountingRecords

> AccountingRecordListResponse listAccountingRecords(entryType, from, to)

列出记账流水

需要 Bearer 令牌；当前熊舍成员可读记账流水。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { ListAccountingRecordsRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  const body = {
    // 'income' | 'expense' | 按收支类型筛选 (optional)
    entryType: entryType_example,
    // Date | 起始时间 (optional)
    from: 2013-10-20T19:20:30+01:00,
    // Date | 结束时间 (optional)
    to: 2013-10-20T19:20:30+01:00,
  } satisfies ListAccountingRecordsRequest;

  try {
    const data = await api.listAccountingRecords(body);
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
| **entryType** | `income`, `expense` | 按收支类型筛选 | [Optional] [Defaults to `undefined`] [Enum: income, expense] |
| **from** | `Date` | 起始时间 | [Optional] [Defaults to `undefined`] |
| **to** | `Date` | 结束时间 | [Optional] [Defaults to `undefined`] |

### Return type

[**AccountingRecordListResponse**](AccountingRecordListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 列出记账流水成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listContractTemplates

> DocumentTemplateListResponse listContractTemplates()

列出合同模板

需要 Bearer 令牌；当前熊舍成员可读合同模板。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { ListContractTemplatesRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  try {
    const data = await api.listContractTemplates();
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

[**DocumentTemplateListResponse**](DocumentTemplateListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 列出合同模板成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listContracts

> DocumentListResponse listContracts()

列出合同单据

需要 Bearer 令牌；当前熊舍成员可读合同单据。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { ListContractsRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  try {
    const data = await api.listContracts();
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

[**DocumentListResponse**](DocumentListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 列出合同单据成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listGeneticLoci

> GeneticLocusListResponse listGeneticLoci()

列出遗传位点

需要 Bearer 令牌；当前熊舍成员可读系统遗传位点目录。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { ListGeneticLociRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  try {
    const data = await api.listGeneticLoci();
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

[**GeneticLocusListResponse**](GeneticLocusListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 列出遗传位点成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listGeneticProfiles

> GeneticProfileListResponse listGeneticProfiles()

列出遗传档案

需要 Bearer 令牌；当前熊舍成员可读遗传档案。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { ListGeneticProfilesRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  try {
    const data = await api.listGeneticProfiles();
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

[**GeneticProfileListResponse**](GeneticProfileListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 列出遗传档案成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listOrganizationMembers

> OrganizationMemberListResponse listOrganizationMembers()

列出熊舍成员

需要 Bearer 令牌；仅舍主和具备成员管理权限的成员可读。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { ListOrganizationMembersRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  try {
    const data = await api.listOrganizationMembers();
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

[**OrganizationMemberListResponse**](OrganizationMemberListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 列出熊舍成员成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listPushDevices

> PushDeviceListResponse listPushDevices()

列出推送设备

需要 Bearer 令牌；当前熊舍成员可读自己的推送设备。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { ListPushDevicesRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  try {
    const data = await api.listPushDevices();
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

[**PushDeviceListResponse**](PushDeviceListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 列出推送设备成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listPushMessages

> PushMessageListResponse listPushMessages()

列出推送消息

需要 Bearer 令牌；当前熊舍成员可读推送审计记录。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { ListPushMessagesRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  try {
    const data = await api.listPushMessages();
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

[**PushMessageListResponse**](PushMessageListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 列出推送消息成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listReceiptTemplates

> DocumentTemplateListResponse listReceiptTemplates()

列出回执模板

需要 Bearer 令牌；当前熊舍成员可读回执模板。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { ListReceiptTemplatesRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  try {
    const data = await api.listReceiptTemplates();
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

[**DocumentTemplateListResponse**](DocumentTemplateListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 列出回执模板成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listReceipts

> DocumentListResponse listReceipts()

列出回执单据

需要 Bearer 令牌；当前熊舍成员可读回执单据。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { ListReceiptsRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  try {
    const data = await api.listReceipts();
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

[**DocumentListResponse**](DocumentListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 列出回执单据成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## revokeContract

> DocumentResponse revokeContract(documentId, ifMatch, idempotencyKey)

撤销合同

需要 Bearer 令牌；撤销已签发合同并立即使客户公开链接失效。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { RevokeContractRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  const body = {
    // string | 合同单据 ID
    documentId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。 
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
  } satisfies RevokeContractRequest;

  try {
    const data = await api.revokeContract(body);
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
| **documentId** | `string` | 合同单据 ID | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |

### Return type

[**DocumentResponse**](DocumentResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 撤销合同成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## revokeOrganizationMember

> OrganizationMemberResponse revokeOrganizationMember(memberId, ifMatch, idempotencyKey)

撤销熊舍成员

需要 Bearer 令牌；仅舍主可撤销成员。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { RevokeOrganizationMemberRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  const body = {
    // string | 成员 ID
    memberId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | 可选的当前资源版本 ETag；传入时用于乐观并发控制。 (optional)
    ifMatch: ifMatch_example,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies RevokeOrganizationMemberRequest;

  try {
    const data = await api.revokeOrganizationMember(body);
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
| **memberId** | `string` | 成员 ID | [Defaults to `undefined`] |
| **ifMatch** | `string` | 可选的当前资源版本 ETag；传入时用于乐观并发控制。 | [Optional] [Defaults to `undefined`] |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**OrganizationMemberResponse**](OrganizationMemberResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 撤销熊舍成员成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **403** | 当前成员角色缺少执行该操作的权限 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## revokeReceipt

> DocumentResponse revokeReceipt(documentId, ifMatch, idempotencyKey)

撤销回执

需要 Bearer 令牌；撤销已签发回执并立即使客户公开链接失效。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { RevokeReceiptRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  const body = {
    // string | 回执单据 ID
    documentId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。 
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
  } satisfies RevokeReceiptRequest;

  try {
    const data = await api.revokeReceipt(body);
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
| **documentId** | `string` | 回执单据 ID | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |

### Return type

[**DocumentResponse**](DocumentResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 撤销回执成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## sandboxActivatePlan

> EntitlementSnapshotResponse sandboxActivatePlan(sandboxActivatePlanRequest, idempotencyKey)

沙箱激活权益套餐

需要 Bearer 令牌；仅写入 sandbox 来源的权益记录，不代表正式支付或生产订阅。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { SandboxActivatePlanOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  const body = {
    // SandboxActivatePlanRequest
    sandboxActivatePlanRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies SandboxActivatePlanOperationRequest;

  try {
    const data = await api.sandboxActivatePlan(body);
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
| **sandboxActivatePlanRequest** | [SandboxActivatePlanRequest](SandboxActivatePlanRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**EntitlementSnapshotResponse**](EntitlementSnapshotResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 沙箱激活权益套餐成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## simulateGeneticBreeding

> GeneticSimulationResponse simulateGeneticBreeding(geneticSimulationRequest, idempotencyKey)

模拟遗传配对

需要 Bearer 令牌；当前熊舍成员可运行只读遗传模拟。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { SimulateGeneticBreedingRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  const body = {
    // GeneticSimulationRequest
    geneticSimulationRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies SimulateGeneticBreedingRequest;

  try {
    const data = await api.simulateGeneticBreeding(body);
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
| **geneticSimulationRequest** | [GeneticSimulationRequest](GeneticSimulationRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**GeneticSimulationResponse**](GeneticSimulationResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 模拟遗传配对成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## updateOrganizationMember

> OrganizationMemberResponse updateOrganizationMember(memberId, updateOrganizationMemberRequest, ifMatch, idempotencyKey)

更新熊舍成员

需要 Bearer 令牌；仅舍主可修改成员角色或显示名。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { UpdateOrganizationMemberOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  const body = {
    // string | 成员 ID
    memberId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // UpdateOrganizationMemberRequest
    updateOrganizationMemberRequest: ...,
    // string | 可选的当前资源版本 ETag；传入时用于乐观并发控制。 (optional)
    ifMatch: ifMatch_example,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies UpdateOrganizationMemberOperationRequest;

  try {
    const data = await api.updateOrganizationMember(body);
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
| **memberId** | `string` | 成员 ID | [Defaults to `undefined`] |
| **updateOrganizationMemberRequest** | [UpdateOrganizationMemberRequest](UpdateOrganizationMemberRequest.md) |  | |
| **ifMatch** | `string` | 可选的当前资源版本 ETag；传入时用于乐观并发控制。 | [Optional] [Defaults to `undefined`] |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**OrganizationMemberResponse**](OrganizationMemberResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 更新熊舍成员成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **403** | 当前成员角色缺少执行该操作的权限 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## upsertPushDevice

> PushDeviceResponse upsertPushDevice(upsertPushDeviceRequest, idempotencyKey)

登记推送设备

需要 Bearer 令牌；当前熊舍成员可登记或恢复推送设备。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example

```ts
import {
  Configuration,
  P1Api,
} from '@scolvpet/scolvpet-api';
import type { UpsertPushDeviceOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new P1Api(config);

  const body = {
    // UpsertPushDeviceRequest
    upsertPushDeviceRequest: ...,
    // string | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies UpsertPushDeviceOperationRequest;

  try {
    const data = await api.upsertPushDevice(body);
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
| **upsertPushDeviceRequest** | [UpsertPushDeviceRequest](UpsertPushDeviceRequest.md) |  | |
| **idempotencyKey** | `string` | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [Optional] [Defaults to `undefined`] |

### Return type

[**PushDeviceResponse**](PushDeviceResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 登记推送设备成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)

