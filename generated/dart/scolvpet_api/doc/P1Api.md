# scolvpet_api.api.P1Api

## Load the API package
```dart
import 'package:scolvpet_api/api.dart';
```

All URIs are relative to *https://api.scolvpet.cn/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**checkEntitlement**](P1Api.md#checkentitlement) | **POST** /v1/entitlements/check | 检查功能或指标权益
[**createAccountingCategory**](P1Api.md#createaccountingcategory) | **POST** /v1/accounting/categories | 创建记账分类
[**createAccountingRecord**](P1Api.md#createaccountingrecord) | **POST** /v1/accounting/records | 创建记账流水
[**createContract**](P1Api.md#createcontract) | **POST** /v1/contracts | 创建合同单据
[**createContractTemplate**](P1Api.md#createcontracttemplate) | **POST** /v1/contracts/templates | 创建合同模板
[**createGeneticProfile**](P1Api.md#creategeneticprofile) | **POST** /v1/genetic/profiles | 创建遗传档案
[**createPushMessage**](P1Api.md#createpushmessage) | **POST** /v1/push/messages | 创建推送消息
[**createReceipt**](P1Api.md#createreceipt) | **POST** /v1/receipts | 创建回执单据
[**createReceiptTemplate**](P1Api.md#createreceipttemplate) | **POST** /v1/receipts/templates | 创建回执模板
[**deleteGeneticProfile**](P1Api.md#deletegeneticprofile) | **DELETE** /v1/genetic/profiles/{profile_id} | 删除遗传档案
[**disablePushDevice**](P1Api.md#disablepushdevice) | **DELETE** /v1/push/devices/{device_id} | 停用推送设备
[**downloadContractPdf**](P1Api.md#downloadcontractpdf) | **GET** /v1/contracts/{document_id}/pdf | 下载已签发合同 PDF
[**downloadReceiptPdf**](P1Api.md#downloadreceiptpdf) | **GET** /v1/receipts/{document_id}/pdf | 下载已签发回执 PDF
[**getAccountingSummary**](P1Api.md#getaccountingsummary) | **GET** /v1/accounting/summary | 读取记账汇总
[**getContract**](P1Api.md#getcontract) | **GET** /v1/contracts/{document_id} | 获取合同单据详情
[**getCurrentEntitlement**](P1Api.md#getcurrententitlement) | **GET** /v1/entitlements/current | 读取当前权益快照
[**getEntitlementCatalog**](P1Api.md#getentitlementcatalog) | **GET** /v1/entitlements/catalog | 读取权益套餐目录
[**getReceipt**](P1Api.md#getreceipt) | **GET** /v1/receipts/{document_id} | 获取回执单据详情
[**inviteOrganizationMember**](P1Api.md#inviteorganizationmember) | **POST** /v1/organization-members | 邀请熊舍成员
[**issueContract**](P1Api.md#issuecontract) | **POST** /v1/contracts/{document_id}/issue | 签发合同
[**issueReceipt**](P1Api.md#issuereceipt) | **POST** /v1/receipts/{document_id}/issue | 签发回执
[**listAccountingCategories**](P1Api.md#listaccountingcategories) | **GET** /v1/accounting/categories | 列出记账分类
[**listAccountingRecords**](P1Api.md#listaccountingrecords) | **GET** /v1/accounting/records | 列出记账流水
[**listContractTemplates**](P1Api.md#listcontracttemplates) | **GET** /v1/contracts/templates | 列出合同模板
[**listContracts**](P1Api.md#listcontracts) | **GET** /v1/contracts | 列出合同单据
[**listGeneticLoci**](P1Api.md#listgeneticloci) | **GET** /v1/genetic/loci | 列出遗传位点
[**listGeneticProfiles**](P1Api.md#listgeneticprofiles) | **GET** /v1/genetic/profiles | 列出遗传档案
[**listOrganizationMembers**](P1Api.md#listorganizationmembers) | **GET** /v1/organization-members | 列出熊舍成员
[**listPushDevices**](P1Api.md#listpushdevices) | **GET** /v1/push/devices | 列出推送设备
[**listPushMessages**](P1Api.md#listpushmessages) | **GET** /v1/push/messages | 列出推送消息
[**listReceiptTemplates**](P1Api.md#listreceipttemplates) | **GET** /v1/receipts/templates | 列出回执模板
[**listReceipts**](P1Api.md#listreceipts) | **GET** /v1/receipts | 列出回执单据
[**revokeContract**](P1Api.md#revokecontract) | **POST** /v1/contracts/{document_id}/revoke | 撤销合同
[**revokeOrganizationMember**](P1Api.md#revokeorganizationmember) | **POST** /v1/organization-members/{member_id}/revoke | 撤销熊舍成员
[**revokeReceipt**](P1Api.md#revokereceipt) | **POST** /v1/receipts/{document_id}/revoke | 撤销回执
[**sandboxActivatePlan**](P1Api.md#sandboxactivateplan) | **POST** /v1/entitlements/sandbox/activate | 沙箱激活权益套餐
[**simulateGeneticBreeding**](P1Api.md#simulategeneticbreeding) | **POST** /v1/genetic/simulate | 模拟遗传配对
[**updateGeneticProfile**](P1Api.md#updategeneticprofile) | **PATCH** /v1/genetic/profiles/{profile_id} | 更新遗传档案
[**updateOrganizationMember**](P1Api.md#updateorganizationmember) | **PATCH** /v1/organization-members/{member_id} | 更新熊舍成员
[**upsertPushDevice**](P1Api.md#upsertpushdevice) | **PUT** /v1/push/devices | 登记推送设备


# **checkEntitlement**
> EntitlementCheckResponse checkEntitlement(entitlementCheckRequest, idempotencyKey)

检查功能或指标权益

需要 Bearer 令牌；当前熊舍成员可检查本舍功能与指标门限。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final EntitlementCheckRequest entitlementCheckRequest = ; // EntitlementCheckRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.checkEntitlement(entitlementCheckRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->checkEntitlement: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **entitlementCheckRequest** | [**EntitlementCheckRequest**](EntitlementCheckRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**EntitlementCheckResponse**](EntitlementCheckResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createAccountingCategory**
> AccountingCategoryResponse createAccountingCategory(createAccountingCategoryRequest, idempotencyKey)

创建记账分类

需要 Bearer 令牌；当前熊舍成员可创建记账分类。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final CreateAccountingCategoryRequest createAccountingCategoryRequest = ; // CreateAccountingCategoryRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.createAccountingCategory(createAccountingCategoryRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->createAccountingCategory: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createAccountingCategoryRequest** | [**CreateAccountingCategoryRequest**](CreateAccountingCategoryRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**AccountingCategoryResponse**](AccountingCategoryResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createAccountingRecord**
> AccountingRecordResponse createAccountingRecord(createAccountingRecordRequest, idempotencyKey)

创建记账流水

需要 Bearer 令牌；当前熊舍成员可创建记账流水。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final CreateAccountingRecordRequest createAccountingRecordRequest = ; // CreateAccountingRecordRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.createAccountingRecord(createAccountingRecordRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->createAccountingRecord: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createAccountingRecordRequest** | [**CreateAccountingRecordRequest**](CreateAccountingRecordRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**AccountingRecordResponse**](AccountingRecordResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createContract**
> DocumentResponse createContract(createContractRequest, idempotencyKey)

创建合同单据

需要 Bearer 令牌；当前熊舍成员可创建合同草稿。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final CreateContractRequest createContractRequest = ; // CreateContractRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.createContract(createContractRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->createContract: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createContractRequest** | [**CreateContractRequest**](CreateContractRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**DocumentResponse**](DocumentResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createContractTemplate**
> DocumentTemplateResponse createContractTemplate(createDocumentTemplateRequest, idempotencyKey)

创建合同模板

需要 Bearer 令牌；当前熊舍成员可创建合同模板。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final CreateDocumentTemplateRequest createDocumentTemplateRequest = ; // CreateDocumentTemplateRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.createContractTemplate(createDocumentTemplateRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->createContractTemplate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createDocumentTemplateRequest** | [**CreateDocumentTemplateRequest**](CreateDocumentTemplateRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**DocumentTemplateResponse**](DocumentTemplateResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createGeneticProfile**
> GeneticProfileResponse createGeneticProfile(createGeneticProfileRequest, idempotencyKey)

创建遗传档案

需要 Bearer 令牌；当前熊舍成员可创建遗传档案。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final CreateGeneticProfileRequest createGeneticProfileRequest = ; // CreateGeneticProfileRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.createGeneticProfile(createGeneticProfileRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->createGeneticProfile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createGeneticProfileRequest** | [**CreateGeneticProfileRequest**](CreateGeneticProfileRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**GeneticProfileResponse**](GeneticProfileResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createPushMessage**
> PushMessageResponse createPushMessage(createPushMessageRequest, idempotencyKey)

创建推送消息

需要 Bearer 令牌；当前熊舍成员可发送测试或业务推送。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final CreatePushMessageRequest createPushMessageRequest = ; // CreatePushMessageRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.createPushMessage(createPushMessageRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->createPushMessage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createPushMessageRequest** | [**CreatePushMessageRequest**](CreatePushMessageRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**PushMessageResponse**](PushMessageResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createReceipt**
> DocumentResponse createReceipt(createReceiptRequest, idempotencyKey)

创建回执单据

需要 Bearer 令牌；当前熊舍成员可创建回执草稿。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final CreateReceiptRequest createReceiptRequest = ; // CreateReceiptRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.createReceipt(createReceiptRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->createReceipt: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createReceiptRequest** | [**CreateReceiptRequest**](CreateReceiptRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**DocumentResponse**](DocumentResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createReceiptTemplate**
> DocumentTemplateResponse createReceiptTemplate(createDocumentTemplateRequest, idempotencyKey)

创建回执模板

需要 Bearer 令牌；当前熊舍成员可创建回执模板。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final CreateDocumentTemplateRequest createDocumentTemplateRequest = ; // CreateDocumentTemplateRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.createReceiptTemplate(createDocumentTemplateRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->createReceiptTemplate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createDocumentTemplateRequest** | [**CreateDocumentTemplateRequest**](CreateDocumentTemplateRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**DocumentTemplateResponse**](DocumentTemplateResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteGeneticProfile**
> Map<String, Object> deleteGeneticProfile(profileId)

删除遗传档案

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final String profileId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.deleteGeneticProfile(profileId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->deleteGeneticProfile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **profileId** | **String**|  |

### Return type

**Map&lt;String, Object&gt;**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **disablePushDevice**
> PushDeviceResponse disablePushDevice(deviceId, idempotencyKey)

停用推送设备

需要 Bearer 令牌；当前熊舍成员可停用自己的推送设备。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final String deviceId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 设备 ID
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.disablePushDevice(deviceId, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->disablePushDevice: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceId** | **String**| 设备 ID |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**PushDeviceResponse**](PushDeviceResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **downloadContractPdf**
> Uint8List downloadContractPdf(documentId)

下载已签发合同 PDF

需要 Bearer 令牌；仅当前经营账号下已签发合同可下载，服务端统一渲染 PDF。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final String documentId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 合同单据 ID

try {
    final response = api.downloadContractPdf(documentId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->downloadContractPdf: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **documentId** | **String**| 合同单据 ID |

### Return type

[**Uint8List**](Uint8List.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/pdf, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **downloadReceiptPdf**
> Uint8List downloadReceiptPdf(documentId)

下载已签发回执 PDF

需要 Bearer 令牌；仅当前经营账号下已签发回执可下载，服务端统一渲染 PDF。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final String documentId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 回执单据 ID

try {
    final response = api.downloadReceiptPdf(documentId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->downloadReceiptPdf: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **documentId** | **String**| 回执单据 ID |

### Return type

[**Uint8List**](Uint8List.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/pdf, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAccountingSummary**
> AccountingSummaryResponse getAccountingSummary(entryType, from, to)

读取记账汇总

需要 Bearer 令牌；当前熊舍成员可读收支汇总。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final String entryType = entryType_example; // String | 按收支类型筛选
final DateTime from = 2013-10-20T19:20:30+01:00; // DateTime | 起始时间
final DateTime to = 2013-10-20T19:20:30+01:00; // DateTime | 结束时间

try {
    final response = api.getAccountingSummary(entryType, from, to);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->getAccountingSummary: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **entryType** | **String**| 按收支类型筛选 | [optional]
 **from** | **DateTime**| 起始时间 | [optional]
 **to** | **DateTime**| 结束时间 | [optional]

### Return type

[**AccountingSummaryResponse**](AccountingSummaryResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getContract**
> DocumentResponse getContract(documentId)

获取合同单据详情

需要 Bearer 令牌；当前熊舍成员可读取单个合同单据。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final String documentId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 合同单据 ID

try {
    final response = api.getContract(documentId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->getContract: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **documentId** | **String**| 合同单据 ID |

### Return type

[**DocumentResponse**](DocumentResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCurrentEntitlement**
> EntitlementSnapshotResponse getCurrentEntitlement()

读取当前权益快照

需要 Bearer 令牌；当前熊舍成员可读本舍权益与用量门限。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();

try {
    final response = api.getCurrentEntitlement();
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->getCurrentEntitlement: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**EntitlementSnapshotResponse**](EntitlementSnapshotResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getEntitlementCatalog**
> EntitlementCatalogResponse getEntitlementCatalog()

读取权益套餐目录

需要 Bearer 令牌；当前熊舍成员可读公开套餐与功能目录。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();

try {
    final response = api.getEntitlementCatalog();
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->getEntitlementCatalog: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**EntitlementCatalogResponse**](EntitlementCatalogResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getReceipt**
> DocumentResponse getReceipt(documentId)

获取回执单据详情

需要 Bearer 令牌；当前熊舍成员可读取单个回执单据。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final String documentId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 回执单据 ID

try {
    final response = api.getReceipt(documentId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->getReceipt: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **documentId** | **String**| 回执单据 ID |

### Return type

[**DocumentResponse**](DocumentResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **inviteOrganizationMember**
> OrganizationMemberResponse inviteOrganizationMember(inviteOrganizationMemberRequest, idempotencyKey)

邀请熊舍成员

需要 Bearer 令牌；仅舍主可邀请成员。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final InviteOrganizationMemberRequest inviteOrganizationMemberRequest = ; // InviteOrganizationMemberRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.inviteOrganizationMember(inviteOrganizationMemberRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->inviteOrganizationMember: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **inviteOrganizationMemberRequest** | [**InviteOrganizationMemberRequest**](InviteOrganizationMemberRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**OrganizationMemberResponse**](OrganizationMemberResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **issueContract**
> DocumentResponse issueContract(documentId, ifMatch, idempotencyKey)

签发合同

需要 Bearer 令牌；当前熊舍成员可签发合同草稿。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final String documentId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 合同单据 ID
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。

try {
    final response = api.issueContract(documentId, ifMatch, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->issueContract: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **documentId** | **String**| 合同单据 ID |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |

### Return type

[**DocumentResponse**](DocumentResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **issueReceipt**
> DocumentResponse issueReceipt(documentId, ifMatch, idempotencyKey)

签发回执

需要 Bearer 令牌；当前熊舍成员可签发回执草稿。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final String documentId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 回执单据 ID
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。

try {
    final response = api.issueReceipt(documentId, ifMatch, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->issueReceipt: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **documentId** | **String**| 回执单据 ID |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |

### Return type

[**DocumentResponse**](DocumentResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listAccountingCategories**
> AccountingCategoryListResponse listAccountingCategories(entryType)

列出记账分类

需要 Bearer 令牌；当前熊舍成员可读记账分类。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final String entryType = entryType_example; // String | 按收入或支出筛选

try {
    final response = api.listAccountingCategories(entryType);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->listAccountingCategories: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **entryType** | **String**| 按收入或支出筛选 | [optional]

### Return type

[**AccountingCategoryListResponse**](AccountingCategoryListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listAccountingRecords**
> AccountingRecordListResponse listAccountingRecords(entryType, from, to)

列出记账流水

需要 Bearer 令牌；当前熊舍成员可读记账流水。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final String entryType = entryType_example; // String | 按收支类型筛选
final DateTime from = 2013-10-20T19:20:30+01:00; // DateTime | 起始时间
final DateTime to = 2013-10-20T19:20:30+01:00; // DateTime | 结束时间

try {
    final response = api.listAccountingRecords(entryType, from, to);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->listAccountingRecords: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **entryType** | **String**| 按收支类型筛选 | [optional]
 **from** | **DateTime**| 起始时间 | [optional]
 **to** | **DateTime**| 结束时间 | [optional]

### Return type

[**AccountingRecordListResponse**](AccountingRecordListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listContractTemplates**
> DocumentTemplateListResponse listContractTemplates()

列出合同模板

需要 Bearer 令牌；当前熊舍成员可读合同模板。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();

try {
    final response = api.listContractTemplates();
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->listContractTemplates: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**DocumentTemplateListResponse**](DocumentTemplateListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listContracts**
> DocumentListResponse listContracts()

列出合同单据

需要 Bearer 令牌；当前熊舍成员可读合同单据。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();

try {
    final response = api.listContracts();
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->listContracts: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**DocumentListResponse**](DocumentListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listGeneticLoci**
> GeneticLocusListResponse listGeneticLoci()

列出遗传位点

需要 Bearer 令牌；当前熊舍成员可读系统遗传位点目录。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();

try {
    final response = api.listGeneticLoci();
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->listGeneticLoci: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**GeneticLocusListResponse**](GeneticLocusListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listGeneticProfiles**
> GeneticProfileListResponse listGeneticProfiles()

列出遗传档案

需要 Bearer 令牌；当前熊舍成员可读遗传档案。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();

try {
    final response = api.listGeneticProfiles();
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->listGeneticProfiles: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**GeneticProfileListResponse**](GeneticProfileListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listOrganizationMembers**
> OrganizationMemberListResponse listOrganizationMembers()

列出熊舍成员

需要 Bearer 令牌；仅舍主和具备成员管理权限的成员可读。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();

try {
    final response = api.listOrganizationMembers();
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->listOrganizationMembers: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**OrganizationMemberListResponse**](OrganizationMemberListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPushDevices**
> PushDeviceListResponse listPushDevices()

列出推送设备

需要 Bearer 令牌；当前熊舍成员可读自己的推送设备。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();

try {
    final response = api.listPushDevices();
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->listPushDevices: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**PushDeviceListResponse**](PushDeviceListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPushMessages**
> PushMessageListResponse listPushMessages()

列出推送消息

需要 Bearer 令牌；当前熊舍成员可读推送审计记录。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();

try {
    final response = api.listPushMessages();
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->listPushMessages: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**PushMessageListResponse**](PushMessageListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listReceiptTemplates**
> DocumentTemplateListResponse listReceiptTemplates()

列出回执模板

需要 Bearer 令牌；当前熊舍成员可读回执模板。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();

try {
    final response = api.listReceiptTemplates();
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->listReceiptTemplates: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**DocumentTemplateListResponse**](DocumentTemplateListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listReceipts**
> DocumentListResponse listReceipts()

列出回执单据

需要 Bearer 令牌；当前熊舍成员可读回执单据。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();

try {
    final response = api.listReceipts();
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->listReceipts: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**DocumentListResponse**](DocumentListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **revokeContract**
> DocumentResponse revokeContract(documentId, ifMatch, idempotencyKey)

撤销合同

需要 Bearer 令牌；撤销已签发合同并立即使客户公开链接失效。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final String documentId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 合同单据 ID
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。

try {
    final response = api.revokeContract(documentId, ifMatch, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->revokeContract: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **documentId** | **String**| 合同单据 ID |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |

### Return type

[**DocumentResponse**](DocumentResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **revokeOrganizationMember**
> OrganizationMemberResponse revokeOrganizationMember(memberId, ifMatch, idempotencyKey)

撤销熊舍成员

需要 Bearer 令牌；仅舍主可撤销成员。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final String memberId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 成员 ID
final String ifMatch = ifMatch_example; // String | 可选的当前资源版本 ETag；传入时用于乐观并发控制。
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.revokeOrganizationMember(memberId, ifMatch, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->revokeOrganizationMember: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **memberId** | **String**| 成员 ID |
 **ifMatch** | **String**| 可选的当前资源版本 ETag；传入时用于乐观并发控制。 | [optional]
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**OrganizationMemberResponse**](OrganizationMemberResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **revokeReceipt**
> DocumentResponse revokeReceipt(documentId, ifMatch, idempotencyKey)

撤销回执

需要 Bearer 令牌；撤销已签发回执并立即使客户公开链接失效。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final String documentId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 回执单据 ID
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。

try {
    final response = api.revokeReceipt(documentId, ifMatch, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->revokeReceipt: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **documentId** | **String**| 回执单据 ID |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |

### Return type

[**DocumentResponse**](DocumentResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sandboxActivatePlan**
> EntitlementSnapshotResponse sandboxActivatePlan(sandboxActivatePlanRequest, idempotencyKey)

沙箱激活权益套餐

需要 Bearer 令牌；仅写入 sandbox 来源的权益记录，不代表正式支付或生产订阅。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final SandboxActivatePlanRequest sandboxActivatePlanRequest = ; // SandboxActivatePlanRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.sandboxActivatePlan(sandboxActivatePlanRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->sandboxActivatePlan: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sandboxActivatePlanRequest** | [**SandboxActivatePlanRequest**](SandboxActivatePlanRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**EntitlementSnapshotResponse**](EntitlementSnapshotResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **simulateGeneticBreeding**
> GeneticSimulationResponse simulateGeneticBreeding(geneticSimulationRequest, idempotencyKey)

模拟遗传配对

需要 Bearer 令牌；当前熊舍成员可运行只读遗传模拟。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final GeneticSimulationRequest geneticSimulationRequest = ; // GeneticSimulationRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.simulateGeneticBreeding(geneticSimulationRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->simulateGeneticBreeding: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **geneticSimulationRequest** | [**GeneticSimulationRequest**](GeneticSimulationRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**GeneticSimulationResponse**](GeneticSimulationResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateGeneticProfile**
> GeneticProfileResponse updateGeneticProfile(profileId, updateGeneticProfileRequest, idempotencyKey)

更新遗传档案

需要 Bearer 令牌；乐观并发依赖 body.version（当前档案版本）。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final String profileId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final UpdateGeneticProfileRequest updateGeneticProfileRequest = ; // UpdateGeneticProfileRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.updateGeneticProfile(profileId, updateGeneticProfileRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->updateGeneticProfile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **profileId** | **String**|  |
 **updateGeneticProfileRequest** | [**UpdateGeneticProfileRequest**](UpdateGeneticProfileRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**GeneticProfileResponse**](GeneticProfileResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateOrganizationMember**
> OrganizationMemberResponse updateOrganizationMember(memberId, updateOrganizationMemberRequest, ifMatch, idempotencyKey)

更新熊舍成员

需要 Bearer 令牌；仅舍主可修改成员角色或显示名。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final String memberId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 成员 ID
final UpdateOrganizationMemberRequest updateOrganizationMemberRequest = ; // UpdateOrganizationMemberRequest |
final String ifMatch = ifMatch_example; // String | 可选的当前资源版本 ETag；传入时用于乐观并发控制。
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.updateOrganizationMember(memberId, updateOrganizationMemberRequest, ifMatch, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->updateOrganizationMember: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **memberId** | **String**| 成员 ID |
 **updateOrganizationMemberRequest** | [**UpdateOrganizationMemberRequest**](UpdateOrganizationMemberRequest.md)|  |
 **ifMatch** | **String**| 可选的当前资源版本 ETag；传入时用于乐观并发控制。 | [optional]
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**OrganizationMemberResponse**](OrganizationMemberResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **upsertPushDevice**
> PushDeviceResponse upsertPushDevice(upsertPushDeviceRequest, idempotencyKey)

登记推送设备

需要 Bearer 令牌；当前熊舍成员可登记或恢复推送设备。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1Api();
final UpsertPushDeviceRequest upsertPushDeviceRequest = ; // UpsertPushDeviceRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.upsertPushDevice(upsertPushDeviceRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1Api->upsertPushDevice: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **upsertPushDeviceRequest** | [**UpsertPushDeviceRequest**](UpsertPushDeviceRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**PushDeviceResponse**](PushDeviceResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
