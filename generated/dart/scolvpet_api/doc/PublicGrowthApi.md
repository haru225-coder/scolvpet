# scolvpet_api.api.PublicGrowthApi

## Load the API package
```dart
import 'package:scolvpet_api/api.dart';
```

All URIs are relative to *https://api.scolvpet.cn/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**consultPublicGrowthAdvisor**](PublicGrowthApi.md#consultpublicgrowthadvisor) | **POST** /v1/public/sites/{slug}/consult | 向公开 AI 顾问咨询
[**createPublicGrowthLead**](PublicGrowthApi.md#createpublicgrowthlead) | **POST** /v1/public/sites/{slug}/leads | 提交公开咨询线索
[**createPublicGrowthReservation**](PublicGrowthApi.md#createpublicgrowthreservation) | **POST** /v1/public/sites/{slug}/reservations | 客户提交公开仓鼠预订
[**getPublicGrowthCatalog**](PublicGrowthApi.md#getpublicgrowthcatalog) | **GET** /v1/public/sites/{slug}/catalog | 查看公开熊舍获客目录
[**getPublicGrowthMedia**](PublicGrowthApi.md#getpublicgrowthmedia) | **GET** /v1/public/sites/{slug}/media/{media_id} | 读取公开仓鼠封面图片


# **consultPublicGrowthAdvisor**
> PublicGrowthConsultResponse consultPublicGrowthAdvisor(slug, publicGrowthConsultRequest)

向公开 AI 顾问咨询

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getPublicGrowthApi();
final String slug = slug_example; // String |
final PublicGrowthConsultRequest publicGrowthConsultRequest = ; // PublicGrowthConsultRequest |

try {
    final response = api.consultPublicGrowthAdvisor(slug, publicGrowthConsultRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PublicGrowthApi->consultPublicGrowthAdvisor: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**|  |
 **publicGrowthConsultRequest** | [**PublicGrowthConsultRequest**](PublicGrowthConsultRequest.md)|  |

### Return type

[**PublicGrowthConsultResponse**](PublicGrowthConsultResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createPublicGrowthLead**
> PublicGrowthLeadResponse createPublicGrowthLead(slug, publicGrowthLeadRequest, idempotencyKey)

提交公开咨询线索

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getPublicGrowthApi();
final String slug = slug_example; // String |
final PublicGrowthLeadRequest publicGrowthLeadRequest = ; // PublicGrowthLeadRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.createPublicGrowthLead(slug, publicGrowthLeadRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PublicGrowthApi->createPublicGrowthLead: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**|  |
 **publicGrowthLeadRequest** | [**PublicGrowthLeadRequest**](PublicGrowthLeadRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**PublicGrowthLeadResponse**](PublicGrowthLeadResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createPublicGrowthReservation**
> PublicGrowthReservationResponse createPublicGrowthReservation(slug, publicGrowthReservationRequest, idempotencyKey)

客户提交公开仓鼠预订

客户从前台对真实 hamster 创建统一 crm_reservation（status=held）。 必须传 hamster_id；Backend 校验公开可订与排他；禁止手填品种/毛色。 需要客户短信验证后的 Bearer ct_* customer session。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getPublicGrowthApi();
final String slug = slug_example; // String |
final PublicGrowthReservationRequest publicGrowthReservationRequest = ; // PublicGrowthReservationRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.createPublicGrowthReservation(slug, publicGrowthReservationRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PublicGrowthApi->createPublicGrowthReservation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**|  |
 **publicGrowthReservationRequest** | [**PublicGrowthReservationRequest**](PublicGrowthReservationRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**PublicGrowthReservationResponse**](PublicGrowthReservationResponse.md)

### Authorization

[customerBearerAuth](../README.md#customerBearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPublicGrowthCatalog**
> PublicGrowthCatalogResponse getPublicGrowthCatalog(slug, campaign)

查看公开熊舍获客目录

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getPublicGrowthApi();
final String slug = slug_example; // String |
final String campaign = campaign_example; // String |

try {
    final response = api.getPublicGrowthCatalog(slug, campaign);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PublicGrowthApi->getPublicGrowthCatalog: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**|  |
 **campaign** | **String**|  | [optional]

### Return type

[**PublicGrowthCatalogResponse**](PublicGrowthCatalogResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPublicGrowthMedia**
> Uint8List getPublicGrowthMedia(slug, mediaId)

读取公开仓鼠封面图片

匿名公开读取；仅允许读取已发布主页中已公开仓鼠当前选择的封面图片，撤下主页或公开资料后统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getPublicGrowthApi();
final String slug = slug_example; // String |
final String mediaId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getPublicGrowthMedia(slug, mediaId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PublicGrowthApi->getPublicGrowthMedia: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**|  |
 **mediaId** | **String**|  |

### Return type

[**Uint8List**](Uint8List.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: image/*, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
