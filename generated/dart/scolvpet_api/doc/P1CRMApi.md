# scolvpet_api.api.P1CRMApi

## Load the API package
```dart
import 'package:scolvpet_api/api.dart';
```

All URIs are relative to *https://api.scolvpet.cn/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**cancelCrmReservation**](P1CRMApi.md#cancelcrmreservation) | **POST** /v1/crm/reservations/{reservation_id}/cancel | 取消客户预订
[**completeCrmHandover**](P1CRMApi.md#completecrmhandover) | **POST** /v1/crm/handovers/{handover_id}/complete | 完成客户交付
[**confirmCrmReservation**](P1CRMApi.md#confirmcrmreservation) | **POST** /v1/crm/reservations/{reservation_id}/confirm | 确认客户预订
[**createCrmContact**](P1CRMApi.md#createcrmcontact) | **POST** /v1/crm/contacts | 创建 CRM 客户
[**createCrmHandover**](P1CRMApi.md#createcrmhandover) | **POST** /v1/crm/handovers | 创建交付记录
[**createCrmReservation**](P1CRMApi.md#createcrmreservation) | **POST** /v1/crm/reservations | 创建客户预订
[**listCrmContacts**](P1CRMApi.md#listcrmcontacts) | **GET** /v1/crm/contacts | 列出 CRM 客户
[**listCrmHandovers**](P1CRMApi.md#listcrmhandovers) | **GET** /v1/crm/handovers | 列出交付记录
[**listCrmReservations**](P1CRMApi.md#listcrmreservations) | **GET** /v1/crm/reservations | 列出客户预订


# **cancelCrmReservation**
> CrmReservationResponse cancelCrmReservation(reservationId, idempotencyKey)

取消客户预订

需要 Bearer 令牌；当前熊舍成员可取消预订。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1CRMApi();
final String reservationId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 预订 ID
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.cancelCrmReservation(reservationId, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1CRMApi->cancelCrmReservation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **reservationId** | **String**| 预订 ID | 
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional] 

### Return type

[**CrmReservationResponse**](CrmReservationResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **completeCrmHandover**
> CrmHandoverResponse completeCrmHandover(handoverId, idempotencyKey)

完成客户交付

需要 Bearer 令牌；当前熊舍成员可完成交付并闭合关联预订。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1CRMApi();
final String handoverId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 交付 ID
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.completeCrmHandover(handoverId, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1CRMApi->completeCrmHandover: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **handoverId** | **String**| 交付 ID | 
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional] 

### Return type

[**CrmHandoverResponse**](CrmHandoverResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **confirmCrmReservation**
> CrmReservationResponse confirmCrmReservation(reservationId, idempotencyKey)

确认客户预订

需要 Bearer 令牌；当前熊舍成员可推进预订状态。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1CRMApi();
final String reservationId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 预订 ID
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.confirmCrmReservation(reservationId, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1CRMApi->confirmCrmReservation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **reservationId** | **String**| 预订 ID | 
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional] 

### Return type

[**CrmReservationResponse**](CrmReservationResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createCrmContact**
> CrmContactResponse createCrmContact(createCrmContactRequest, idempotencyKey)

创建 CRM 客户

需要 Bearer 令牌；当前熊舍成员可创建客户档案。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1CRMApi();
final CreateCrmContactRequest createCrmContactRequest = ; // CreateCrmContactRequest | 
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.createCrmContact(createCrmContactRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1CRMApi->createCrmContact: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createCrmContactRequest** | [**CreateCrmContactRequest**](CreateCrmContactRequest.md)|  | 
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional] 

### Return type

[**CrmContactResponse**](CrmContactResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createCrmHandover**
> CrmHandoverResponse createCrmHandover(createCrmHandoverRequest, idempotencyKey)

创建交付记录

需要 Bearer 令牌；当前熊舍成员可创建交付记录。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1CRMApi();
final CreateCrmHandoverRequest createCrmHandoverRequest = ; // CreateCrmHandoverRequest | 
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.createCrmHandover(createCrmHandoverRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1CRMApi->createCrmHandover: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createCrmHandoverRequest** | [**CreateCrmHandoverRequest**](CreateCrmHandoverRequest.md)|  | 
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional] 

### Return type

[**CrmHandoverResponse**](CrmHandoverResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createCrmReservation**
> CrmReservationResponse createCrmReservation(createCrmReservationRequest, idempotencyKey)

创建客户预订

需要 Bearer 令牌；当前熊舍成员可创建预订记录。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1CRMApi();
final CreateCrmReservationRequest createCrmReservationRequest = ; // CreateCrmReservationRequest | 
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.createCrmReservation(createCrmReservationRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1CRMApi->createCrmReservation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createCrmReservationRequest** | [**CreateCrmReservationRequest**](CreateCrmReservationRequest.md)|  | 
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional] 

### Return type

[**CrmReservationResponse**](CrmReservationResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listCrmContacts**
> CrmContactListResponse listCrmContacts()

列出 CRM 客户

需要 Bearer 令牌；当前熊舍成员可读客户档案。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1CRMApi();

try {
    final response = api.listCrmContacts();
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1CRMApi->listCrmContacts: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**CrmContactListResponse**](CrmContactListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listCrmHandovers**
> CrmHandoverListResponse listCrmHandovers()

列出交付记录

需要 Bearer 令牌；当前熊舍成员可读交付记录。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1CRMApi();

try {
    final response = api.listCrmHandovers();
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1CRMApi->listCrmHandovers: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**CrmHandoverListResponse**](CrmHandoverListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listCrmReservations**
> CrmReservationListResponse listCrmReservations()

列出客户预订

需要 Bearer 令牌；当前熊舍成员可读预订记录。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP1CRMApi();

try {
    final response = api.listCrmReservations();
    print(response);
} on DioException catch (e) {
    print('Exception when calling P1CRMApi->listCrmReservations: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**CrmReservationListResponse**](CrmReservationListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

