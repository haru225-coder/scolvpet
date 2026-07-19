# scolvpet_api.api.GrowthApi

## Load the API package
```dart
import 'package:scolvpet_api/api.dart';
```

All URIs are relative to *https://api.scolvpet.cn/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**archiveGrowthCampaign**](GrowthApi.md#archivegrowthcampaign) | **POST** /v1/growth/campaigns/{campaign_id}/archive | 归档获客活动
[**generateGrowthCampaign**](GrowthApi.md#generategrowthcampaign) | **POST** /v1/growth/campaigns/generate | 生成并保存视频或直播脚本
[**getGrowthCampaign**](GrowthApi.md#getgrowthcampaign) | **GET** /v1/growth/campaigns/{campaign_id} | 查看获客活动详情
[**listGrowthCampaigns**](GrowthApi.md#listgrowthcampaigns) | **GET** /v1/growth/campaigns | 查看获客活动
[**listGrowthLeads**](GrowthApi.md#listgrowthleads) | **GET** /v1/growth/leads | 查看获客线索及来源归因
[**listGrowthOpportunities**](GrowthApi.md#listgrowthopportunities) | **GET** /v1/growth/opportunities | 查看 AI 内容机会
[**listGrowthPublicHamsters**](GrowthApi.md#listgrowthpublichamsters) | **GET** /v1/growth/public-hamsters | 查看本舍仓鼠公开资料
[**publishGrowthCampaign**](GrowthApi.md#publishgrowthcampaign) | **POST** /v1/growth/campaigns/{campaign_id}/publish | 发布获客活动
[**upsertGrowthPublicHamster**](GrowthApi.md#upsertgrowthpublichamster) | **PUT** /v1/growth/public-hamsters/{hamster_id} | 保存仓鼠公开资料


# **archiveGrowthCampaign**
> GrowthCampaignResponse archiveGrowthCampaign(campaignId, idempotencyKey)

归档获客活动

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getGrowthApi();
final String campaignId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.archiveGrowthCampaign(campaignId, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GrowthApi->archiveGrowthCampaign: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **campaignId** | **String**|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**GrowthCampaignResponse**](GrowthCampaignResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **generateGrowthCampaign**
> GrowthCampaignResponse generateGrowthCampaign(growthCampaignGenerateRequest, idempotencyKey)

生成并保存视频或直播脚本

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getGrowthApi();
final GrowthCampaignGenerateRequest growthCampaignGenerateRequest = ; // GrowthCampaignGenerateRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.generateGrowthCampaign(growthCampaignGenerateRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GrowthApi->generateGrowthCampaign: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **growthCampaignGenerateRequest** | [**GrowthCampaignGenerateRequest**](GrowthCampaignGenerateRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**GrowthCampaignResponse**](GrowthCampaignResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getGrowthCampaign**
> GrowthCampaignResponse getGrowthCampaign(campaignId)

查看获客活动详情

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getGrowthApi();
final String campaignId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getGrowthCampaign(campaignId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GrowthApi->getGrowthCampaign: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **campaignId** | **String**|  |

### Return type

[**GrowthCampaignResponse**](GrowthCampaignResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listGrowthCampaigns**
> GrowthCampaignListResponse listGrowthCampaigns()

查看获客活动

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getGrowthApi();

try {
    final response = api.listGrowthCampaigns();
    print(response);
} on DioException catch (e) {
    print('Exception when calling GrowthApi->listGrowthCampaigns: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**GrowthCampaignListResponse**](GrowthCampaignListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listGrowthLeads**
> GrowthLeadListResponse listGrowthLeads()

查看获客线索及来源归因

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getGrowthApi();

try {
    final response = api.listGrowthLeads();
    print(response);
} on DioException catch (e) {
    print('Exception when calling GrowthApi->listGrowthLeads: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**GrowthLeadListResponse**](GrowthLeadListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listGrowthOpportunities**
> GrowthOpportunityListResponse listGrowthOpportunities()

查看 AI 内容机会

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getGrowthApi();

try {
    final response = api.listGrowthOpportunities();
    print(response);
} on DioException catch (e) {
    print('Exception when calling GrowthApi->listGrowthOpportunities: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**GrowthOpportunityListResponse**](GrowthOpportunityListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listGrowthPublicHamsters**
> GrowthPublicHamsterListResponse listGrowthPublicHamsters()

查看本舍仓鼠公开资料

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getGrowthApi();

try {
    final response = api.listGrowthPublicHamsters();
    print(response);
} on DioException catch (e) {
    print('Exception when calling GrowthApi->listGrowthPublicHamsters: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**GrowthPublicHamsterListResponse**](GrowthPublicHamsterListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **publishGrowthCampaign**
> GrowthCampaignResponse publishGrowthCampaign(campaignId, idempotencyKey)

发布获客活动

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getGrowthApi();
final String campaignId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.publishGrowthCampaign(campaignId, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GrowthApi->publishGrowthCampaign: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **campaignId** | **String**|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**GrowthCampaignResponse**](GrowthCampaignResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **upsertGrowthPublicHamster**
> GrowthPublicHamsterResponse upsertGrowthPublicHamster(hamsterId, growthPublicHamsterRequest, idempotencyKey)

保存仓鼠公开资料

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getGrowthApi();
final String hamsterId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final GrowthPublicHamsterRequest growthPublicHamsterRequest = ; // GrowthPublicHamsterRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.upsertGrowthPublicHamster(hamsterId, growthPublicHamsterRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GrowthApi->upsertGrowthPublicHamster: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **hamsterId** | **String**|  |
 **growthPublicHamsterRequest** | [**GrowthPublicHamsterRequest**](GrowthPublicHamsterRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**GrowthPublicHamsterResponse**](GrowthPublicHamsterResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
