# scolvpet_api.api.CustomerApi

## Load the API package
```dart
import 'package:scolvpet_api/api.dart';
```

All URIs are relative to *https://api.scolvpet.cn/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**cancelCustomerReservation**](CustomerApi.md#cancelcustomerreservation) | **POST** /v1/customer/reservations/{reservation_id}/cancel | 客户取消 held 预订
[**createCustomerSession**](CustomerApi.md#createcustomersession) | **POST** /v1/public/customer/sessions | 客户验证码登录
[**createCustomerWechatBinding**](CustomerApi.md#createcustomerwechatbinding) | **POST** /v1/public/customer/wechat-bindings | 短信验证并绑定微信身份
[**createCustomerWechatPhoneBinding**](CustomerApi.md#createcustomerwechatphonebinding) | **POST** /v1/public/customer/wechat-phone-bindings | 微信授权手机号并创建客户会话
[**createCustomerWechatSession**](CustomerApi.md#createcustomerwechatsession) | **POST** /v1/public/customer/wechat-sessions | 微信 wx.login 静默登录
[**deleteCustomerSession**](CustomerApi.md#deletecustomersession) | **DELETE** /v1/customer/sessions/current | 客户退出当前会话
[**deleteCustomerWechatBinding**](CustomerApi.md#deletecustomerwechatbinding) | **DELETE** /v1/customer/wechat-bindings/current | 解绑当前客户的微信身份
[**getCustomerReservation**](CustomerApi.md#getcustomerreservation) | **GET** /v1/customer/reservations/{reservation_id} | 获取客户预订详情
[**listCustomerReservations**](CustomerApi.md#listcustomerreservations) | **GET** /v1/customer/reservations | 列出当前客户预订
[**sendCustomerVerificationCode**](CustomerApi.md#sendcustomerverificationcode) | **POST** /v1/public/customer/verification-codes | 客户侧发送登录验证码


# **cancelCustomerReservation**
> CustomerReservationResponse cancelCustomerReservation(reservationId)

客户取消 held 预订

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getCustomerApi();
final String reservationId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.cancelCustomerReservation(reservationId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CustomerApi->cancelCustomerReservation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **reservationId** | **String**|  |

### Return type

[**CustomerReservationResponse**](CustomerReservationResponse.md)

### Authorization

[customerBearerAuth](../README.md#customerBearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createCustomerSession**
> CustomerSessionResponse createCustomerSession(createCustomerSessionRequest)

客户验证码登录

返回 ct_* customer access token（与 staff bearer 分离）。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getCustomerApi();
final CreateCustomerSessionRequest createCustomerSessionRequest = ; // CreateCustomerSessionRequest |

try {
    final response = api.createCustomerSession(createCustomerSessionRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CustomerApi->createCustomerSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createCustomerSessionRequest** | [**CreateCustomerSessionRequest**](CreateCustomerSessionRequest.md)|  |

### Return type

[**CustomerSessionResponse**](CustomerSessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createCustomerWechatBinding**
> CustomerSessionResponse createCustomerWechatBinding(createCustomerWechatBindingRequest)

短信验证并绑定微信身份

消费 wechat-sessions 下发的一次性票据：短信验证通过后写入 openid↔phone 绑定 并发放 ct_* 会话。票据过期/已用返回 422，客户端应降级到普通验证码登录。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getCustomerApi();
final CreateCustomerWechatBindingRequest createCustomerWechatBindingRequest = ; // CreateCustomerWechatBindingRequest |

try {
    final response = api.createCustomerWechatBinding(createCustomerWechatBindingRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CustomerApi->createCustomerWechatBinding: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createCustomerWechatBindingRequest** | [**CreateCustomerWechatBindingRequest**](CreateCustomerWechatBindingRequest.md)|  |

### Return type

[**CustomerSessionResponse**](CustomerSessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createCustomerWechatPhoneBinding**
> CustomerSessionResponse createCustomerWechatPhoneBinding(createCustomerWechatPhoneBindingRequest)

微信授权手机号并创建客户会话

原子消费 wx.login 下发的 wt_ 一次性票据后，使用 getPhoneNumber 的 phone_code 从微信服务端换取手机号，写入 OpenID↔手机号有效绑定并发放 ct_* 会话。ticket 有效期为 10 分钟；任一凭证失效、ticket 已消费或远程结果不确定时，客户端必须 重新执行 wx.login 并由用户再次授权，不得重放旧 phone_code。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getCustomerApi();
final CreateCustomerWechatPhoneBindingRequest createCustomerWechatPhoneBindingRequest = ; // CreateCustomerWechatPhoneBindingRequest |

try {
    final response = api.createCustomerWechatPhoneBinding(createCustomerWechatPhoneBindingRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CustomerApi->createCustomerWechatPhoneBinding: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createCustomerWechatPhoneBindingRequest** | [**CreateCustomerWechatPhoneBindingRequest**](CreateCustomerWechatPhoneBindingRequest.md)|  |

### Return type

[**CustomerSessionResponse**](CustomerSessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createCustomerWechatSession**
> CustomerWechatBindTicketResponse createCustomerWechatSession(createCustomerWechatSessionRequest)

微信 wx.login 静默登录

用 wx.login 的 js_code 换取身份：openid 已绑定手机号则直接发放 ct_* 会话（201）； 未绑定则返回一次性绑定票据（200，10 分钟有效），随后经短信验证完成绑定。 session_key 永不返回客户端。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getCustomerApi();
final CreateCustomerWechatSessionRequest createCustomerWechatSessionRequest = ; // CreateCustomerWechatSessionRequest |

try {
    final response = api.createCustomerWechatSession(createCustomerWechatSessionRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CustomerApi->createCustomerWechatSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createCustomerWechatSessionRequest** | [**CreateCustomerWechatSessionRequest**](CreateCustomerWechatSessionRequest.md)|  |

### Return type

[**CustomerWechatBindTicketResponse**](CustomerWechatBindTicketResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteCustomerSession**
> deleteCustomerSession()

客户退出当前会话

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getCustomerApi();

try {
    api.deleteCustomerSession();
} on DioException catch (e) {
    print('Exception when calling CustomerApi->deleteCustomerSession: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[customerBearerAuth](../README.md#customerBearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteCustomerWechatBinding**
> deleteCustomerWechatBinding()

解绑当前客户的微信身份

审计链保留绑定行（revoked_at），解绑后下次 wx.login 回到绑定流程。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getCustomerApi();

try {
    api.deleteCustomerWechatBinding();
} on DioException catch (e) {
    print('Exception when calling CustomerApi->deleteCustomerWechatBinding: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[customerBearerAuth](../README.md#customerBearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCustomerReservation**
> CustomerReservationResponse getCustomerReservation(reservationId)

获取客户预订详情

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getCustomerApi();
final String reservationId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getCustomerReservation(reservationId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CustomerApi->getCustomerReservation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **reservationId** | **String**|  |

### Return type

[**CustomerReservationResponse**](CustomerReservationResponse.md)

### Authorization

[customerBearerAuth](../README.md#customerBearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listCustomerReservations**
> CustomerReservationListResponse listCustomerReservations()

列出当前客户预订

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getCustomerApi();

try {
    final response = api.listCustomerReservations();
    print(response);
} on DioException catch (e) {
    print('Exception when calling CustomerApi->listCustomerReservations: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**CustomerReservationListResponse**](CustomerReservationListResponse.md)

### Authorization

[customerBearerAuth](../README.md#customerBearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sendCustomerVerificationCode**
> CustomerVerificationCodeResponse sendCustomerVerificationCode(sendCustomerVerificationCodeRequest, idempotencyKey)

客户侧发送登录验证码

不创建 staff account；仅创建 verification challenge。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getCustomerApi();
final SendCustomerVerificationCodeRequest sendCustomerVerificationCodeRequest = ; // SendCustomerVerificationCodeRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.sendCustomerVerificationCode(sendCustomerVerificationCodeRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CustomerApi->sendCustomerVerificationCode: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sendCustomerVerificationCodeRequest** | [**SendCustomerVerificationCodeRequest**](SendCustomerVerificationCodeRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**CustomerVerificationCodeResponse**](CustomerVerificationCodeResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
