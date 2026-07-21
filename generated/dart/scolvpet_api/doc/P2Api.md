# scolvpet_api.api.P2Api

## Load the API package
```dart
import 'package:scolvpet_api/api.dart';
```

All URIs are relative to *https://api.scolvpet.cn/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**askAssistant**](P2Api.md#askassistant) | **POST** /v1/assistant/ask | 向只读助手提问
[**assistantCapabilities**](P2Api.md#assistantcapabilities) | **GET** /v1/assistant/capabilities | 读取助手能力
[**auditMiniprogramRelease**](P2Api.md#auditminiprogramrelease) | **POST** /v1/miniprogram/releases/{release_id}/audit | 审核小程序版本
[**cancelAssistantAction**](P2Api.md#cancelassistantaction) | **POST** /v1/assistant/actions/{action_id}/cancel | 取消助手动作
[**cancelStudDeal**](P2Api.md#cancelstuddeal) | **POST** /v1/stud/deals/{deal_id}/cancel | 取消跨舍借配单
[**chatAssistant**](P2Api.md#chatassistant) | **POST** /v1/assistant/chat | 通用多轮对话
[**completeStudDeal**](P2Api.md#completestuddeal) | **POST** /v1/stud/deals/{deal_id}/complete | 完成跨舍借配单
[**confirmAssistantAction**](P2Api.md#confirmassistantaction) | **POST** /v1/assistant/actions/{action_id}/confirm | 确认并执行助手动作
[**confirmStudDeal**](P2Api.md#confirmstuddeal) | **POST** /v1/stud/deals/{deal_id}/confirm | 确认跨舍借配单
[**createAssistantSession**](P2Api.md#createassistantsession) | **POST** /v1/assistant/sessions | 创建会话
[**createMiniprogramRelease**](P2Api.md#createminiprogramrelease) | **POST** /v1/miniprogram/releases | 创建小程序版本
[**createStudDeal**](P2Api.md#createstuddeal) | **POST** /v1/stud/deals | 创建跨舍借配单
[**createStudListing**](P2Api.md#createstudlisting) | **POST** /v1/stud/listings | 创建种公借配挂牌
[**getMiniprogramConfig**](P2Api.md#getminiprogramconfig) | **GET** /v1/miniprogram/config | 读取小程序配置
[**getOwnerPublicSite**](P2Api.md#getownerpublicsite) | **GET** /v1/public-site | 读取熊舍公开主页草稿
[**getPublicSiteBySlug**](P2Api.md#getpublicsitebyslug) | **GET** /v1/public/sites/{slug} | 读取公开主页投影
[**listAssistantMessages**](P2Api.md#listassistantmessages) | **GET** /v1/assistant/sessions/{session_id}/messages | 列出会话消息
[**listAssistantSessions**](P2Api.md#listassistantsessions) | **GET** /v1/assistant/sessions | 列出会话
[**listMiniprogramReleases**](P2Api.md#listminiprogramreleases) | **GET** /v1/miniprogram/releases | 列出小程序版本
[**listStudDeals**](P2Api.md#liststuddeals) | **GET** /v1/stud/deals | 列出跨舍借配单
[**listStudListings**](P2Api.md#liststudlistings) | **GET** /v1/stud/listings | 列出种公借配挂牌
[**publishMiniprogramRelease**](P2Api.md#publishminiprogramrelease) | **POST** /v1/miniprogram/releases/{release_id}/publish | 发布小程序版本
[**publishOwnerPublicSite**](P2Api.md#publishownerpublicsite) | **POST** /v1/public-site/publish | 发布熊舍公开主页
[**rollbackMiniprogramRelease**](P2Api.md#rollbackminiprogramrelease) | **POST** /v1/miniprogram/releases/{release_id}/rollback | 回滚小程序版本
[**startStudDeal**](P2Api.md#startstuddeal) | **POST** /v1/stud/deals/{deal_id}/start | 开始跨舍借配单
[**submitMiniprogramRelease**](P2Api.md#submitminiprogramrelease) | **POST** /v1/miniprogram/releases/{release_id}/submit | 提交小程序审核
[**unpublishOwnerPublicSite**](P2Api.md#unpublishownerpublicsite) | **POST** /v1/public-site/unpublish | 撤下熊舍公开主页
[**unpublishStudListing**](P2Api.md#unpublishstudlisting) | **POST** /v1/stud/listings/{listing_id}/unpublish | 撤下种公挂牌
[**upsertMiniprogramConfig**](P2Api.md#upsertminiprogramconfig) | **PUT** /v1/miniprogram/config | 保存小程序配置
[**upsertOwnerPublicSite**](P2Api.md#upsertownerpublicsite) | **PUT** /v1/public-site | 保存熊舍公开主页


# **askAssistant**
> AssistantAnswerResponse askAssistant(assistantAskRequest, idempotencyKey)

向只读助手提问

需要 Bearer 令牌；当前熊舍成员可查询本舍结构化数据；助手不修改业务数据。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();
final AssistantAskRequest assistantAskRequest = ; // AssistantAskRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.askAssistant(assistantAskRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->askAssistant: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **assistantAskRequest** | [**AssistantAskRequest**](AssistantAskRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**AssistantAnswerResponse**](AssistantAnswerResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **assistantCapabilities**
> AssistantCapabilitiesResponse assistantCapabilities()

读取助手能力

需要 Bearer 令牌；当前熊舍成员可读取只读助手能力与可用模式。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();

try {
    final response = api.assistantCapabilities();
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->assistantCapabilities: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AssistantCapabilitiesResponse**](AssistantCapabilitiesResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **auditMiniprogramRelease**
> MiniprogramReleaseResponse auditMiniprogramRelease(releaseId, auditMiniprogramReleaseRequest, idempotencyKey)

审核小程序版本

需要 Bearer 令牌；当前熊舍成员可在沙箱审核流水中通过或驳回版本。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();
final String releaseId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 版本 ID
final AuditMiniprogramReleaseRequest auditMiniprogramReleaseRequest = ; // AuditMiniprogramReleaseRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.auditMiniprogramRelease(releaseId, auditMiniprogramReleaseRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->auditMiniprogramRelease: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **releaseId** | **String**| 版本 ID |
 **auditMiniprogramReleaseRequest** | [**AuditMiniprogramReleaseRequest**](AuditMiniprogramReleaseRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**MiniprogramReleaseResponse**](MiniprogramReleaseResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cancelAssistantAction**
> AssistantActionCancelResponse cancelAssistantAction(actionId, idempotencyKey)

取消助手动作

需要 Bearer 令牌；仅可取消当前 owner 的待确认动作。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();
final String actionId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.cancelAssistantAction(actionId, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->cancelAssistantAction: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **actionId** | **String**|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**AssistantActionCancelResponse**](AssistantActionCancelResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cancelStudDeal**
> StudDealResponse cancelStudDeal(dealId, idempotencyKey)

取消跨舍借配单

需要 Bearer 令牌；当前熊舍成员可推进本舍借配履约状态。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();
final String dealId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 借配单 ID
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.cancelStudDeal(dealId, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->cancelStudDeal: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **dealId** | **String**| 借配单 ID |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**StudDealResponse**](StudDealResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **chatAssistant**
> AssistantChatResponse chatAssistant(assistantChatRequest, idempotencyKey)

通用多轮对话

需要 Bearer 令牌。主路径为 Grok Build 通用对话，并注入本舍结构化事实。 未传 session_id 时自动创建会话。LLM 失败时降级为规则答案。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();
final AssistantChatRequest assistantChatRequest = ; // AssistantChatRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.chatAssistant(assistantChatRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->chatAssistant: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **assistantChatRequest** | [**AssistantChatRequest**](AssistantChatRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**AssistantChatResponse**](AssistantChatResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **completeStudDeal**
> StudDealResponse completeStudDeal(dealId, idempotencyKey)

完成跨舍借配单

需要 Bearer 令牌；当前熊舍成员可推进本舍借配履约状态。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();
final String dealId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 借配单 ID
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.completeStudDeal(dealId, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->completeStudDeal: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **dealId** | **String**| 借配单 ID |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**StudDealResponse**](StudDealResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **confirmAssistantAction**
> AssistantActionConfirmResponse confirmAssistantAction(actionId, idempotencyKey)

确认并执行助手动作

需要 Bearer 令牌；仅可执行当前 owner 的待确认动作。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();
final String actionId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.confirmAssistantAction(actionId, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->confirmAssistantAction: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **actionId** | **String**|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**AssistantActionConfirmResponse**](AssistantActionConfirmResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **confirmStudDeal**
> StudDealResponse confirmStudDeal(dealId, idempotencyKey)

确认跨舍借配单

需要 Bearer 令牌；当前熊舍成员可推进本舍借配履约状态。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();
final String dealId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 借配单 ID
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.confirmStudDeal(dealId, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->confirmStudDeal: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **dealId** | **String**| 借配单 ID |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**StudDealResponse**](StudDealResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createAssistantSession**
> AssistantSessionResponse createAssistantSession(assistantSessionCreateRequest)

创建会话

需要 Bearer 令牌；可空 body。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();
final AssistantSessionCreateRequest assistantSessionCreateRequest = ; // AssistantSessionCreateRequest |

try {
    final response = api.createAssistantSession(assistantSessionCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->createAssistantSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **assistantSessionCreateRequest** | [**AssistantSessionCreateRequest**](AssistantSessionCreateRequest.md)|  | [optional]

### Return type

[**AssistantSessionResponse**](AssistantSessionResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createMiniprogramRelease**
> MiniprogramReleaseResponse createMiniprogramRelease(createMiniprogramReleaseRequest, idempotencyKey)

创建小程序版本

需要 Bearer 令牌；当前熊舍成员可创建小程序草稿版本。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();
final CreateMiniprogramReleaseRequest createMiniprogramReleaseRequest = ; // CreateMiniprogramReleaseRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.createMiniprogramRelease(createMiniprogramReleaseRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->createMiniprogramRelease: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createMiniprogramReleaseRequest** | [**CreateMiniprogramReleaseRequest**](CreateMiniprogramReleaseRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**MiniprogramReleaseResponse**](MiniprogramReleaseResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createStudDeal**
> StudDealResponse createStudDeal(createStudDealRequest, idempotencyKey)

创建跨舍借配单

需要 Bearer 令牌；当前熊舍成员可创建借配履约记录。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();
final CreateStudDealRequest createStudDealRequest = ; // CreateStudDealRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.createStudDeal(createStudDealRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->createStudDeal: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createStudDealRequest** | [**CreateStudDealRequest**](CreateStudDealRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**StudDealResponse**](StudDealResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createStudListing**
> StudListingResponse createStudListing(createStudListingRequest, idempotencyKey)

创建种公借配挂牌

需要 Bearer 令牌；当前熊舍成员可创建本舍种公挂牌。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();
final CreateStudListingRequest createStudListingRequest = ; // CreateStudListingRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.createStudListing(createStudListingRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->createStudListing: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createStudListingRequest** | [**CreateStudListingRequest**](CreateStudListingRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**StudListingResponse**](StudListingResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMiniprogramConfig**
> MiniprogramConfigResponse getMiniprogramConfig()

读取小程序配置

需要 Bearer 令牌；当前熊舍成员可读小程序配置。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();

try {
    final response = api.getMiniprogramConfig();
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->getMiniprogramConfig: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MiniprogramConfigResponse**](MiniprogramConfigResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getOwnerPublicSite**
> PublicSiteResponse getOwnerPublicSite()

读取熊舍公开主页草稿

需要 Bearer 令牌；当前熊舍成员可读本舍公开主页配置。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();

try {
    final response = api.getOwnerPublicSite();
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->getOwnerPublicSite: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**PublicSiteResponse**](PublicSiteResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPublicSiteBySlug**
> PublicSiteViewResponse getPublicSiteBySlug(slug)

读取公开主页投影

匿名公开读取；仅返回 published=true 的主页投影，未发布或不存在统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();
final String slug = slug_example; // String |

try {
    final response = api.getPublicSiteBySlug(slug);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->getPublicSiteBySlug: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**|  |

### Return type

[**PublicSiteViewResponse**](PublicSiteViewResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listAssistantMessages**
> AssistantMessageListResponse listAssistantMessages(sessionId)

列出会话消息

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();
final String sessionId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.listAssistantMessages(sessionId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->listAssistantMessages: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  |

### Return type

[**AssistantMessageListResponse**](AssistantMessageListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listAssistantSessions**
> AssistantSessionListResponse listAssistantSessions()

列出会话

需要 Bearer 令牌；按 owner_id 隔离。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();

try {
    final response = api.listAssistantSessions();
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->listAssistantSessions: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AssistantSessionListResponse**](AssistantSessionListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listMiniprogramReleases**
> MiniprogramReleaseListResponse listMiniprogramReleases()

列出小程序版本

需要 Bearer 令牌；当前熊舍成员可读小程序发布流水。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();

try {
    final response = api.listMiniprogramReleases();
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->listMiniprogramReleases: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MiniprogramReleaseListResponse**](MiniprogramReleaseListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listStudDeals**
> StudDealListResponse listStudDeals()

列出跨舍借配单

需要 Bearer 令牌；当前熊舍成员可读本舍借配履约记录。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();

try {
    final response = api.listStudDeals();
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->listStudDeals: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**StudDealListResponse**](StudDealListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listStudListings**
> StudListingListResponse listStudListings(mine)

列出种公借配挂牌

需要 Bearer 令牌；当前成员可读公开挂牌及自己的未公开挂牌。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();
final String mine = mine_example; // String | 仅查看自己的挂牌时传 1

try {
    final response = api.listStudListings(mine);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->listStudListings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mine** | **String**| 仅查看自己的挂牌时传 1 | [optional]

### Return type

[**StudListingListResponse**](StudListingListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **publishMiniprogramRelease**
> MiniprogramReleaseResponse publishMiniprogramRelease(releaseId, idempotencyKey)

发布小程序版本

需要 Bearer 令牌；当前熊舍成员可发布已审核通过版本。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();
final String releaseId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 版本 ID
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.publishMiniprogramRelease(releaseId, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->publishMiniprogramRelease: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **releaseId** | **String**| 版本 ID |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**MiniprogramReleaseResponse**](MiniprogramReleaseResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **publishOwnerPublicSite**
> PublicSiteResponse publishOwnerPublicSite(idempotencyKey)

发布熊舍公开主页

需要 Bearer 令牌；当前熊舍成员可发布本舍公开主页。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.publishOwnerPublicSite(idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->publishOwnerPublicSite: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**PublicSiteResponse**](PublicSiteResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rollbackMiniprogramRelease**
> MiniprogramReleaseResponse rollbackMiniprogramRelease(releaseId, idempotencyKey)

回滚小程序版本

需要 Bearer 令牌；当前熊舍成员可回滚线上版本。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();
final String releaseId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 版本 ID
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.rollbackMiniprogramRelease(releaseId, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->rollbackMiniprogramRelease: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **releaseId** | **String**| 版本 ID |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**MiniprogramReleaseResponse**](MiniprogramReleaseResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startStudDeal**
> StudDealResponse startStudDeal(dealId, idempotencyKey)

开始跨舍借配单

需要 Bearer 令牌；当前熊舍成员可推进本舍借配履约状态。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();
final String dealId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 借配单 ID
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.startStudDeal(dealId, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->startStudDeal: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **dealId** | **String**| 借配单 ID |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**StudDealResponse**](StudDealResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **submitMiniprogramRelease**
> MiniprogramReleaseResponse submitMiniprogramRelease(releaseId, idempotencyKey)

提交小程序审核

需要 Bearer 令牌；当前熊舍成员可提交草稿或驳回版本。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();
final String releaseId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 版本 ID
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.submitMiniprogramRelease(releaseId, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->submitMiniprogramRelease: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **releaseId** | **String**| 版本 ID |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**MiniprogramReleaseResponse**](MiniprogramReleaseResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **unpublishOwnerPublicSite**
> PublicSiteResponse unpublishOwnerPublicSite(idempotencyKey)

撤下熊舍公开主页

需要 Bearer 令牌；当前熊舍成员可撤下本舍公开主页。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.unpublishOwnerPublicSite(idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->unpublishOwnerPublicSite: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**PublicSiteResponse**](PublicSiteResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **unpublishStudListing**
> StudListingResponse unpublishStudListing(listingId, idempotencyKey)

撤下种公挂牌

需要 Bearer 令牌；当前熊舍成员可撤下自己的种公挂牌。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();
final String listingId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 挂牌 ID
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.unpublishStudListing(listingId, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->unpublishStudListing: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **listingId** | **String**| 挂牌 ID |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**StudListingResponse**](StudListingResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **upsertMiniprogramConfig**
> MiniprogramConfigResponse upsertMiniprogramConfig(upsertMiniprogramConfigRequest, idempotencyKey)

保存小程序配置

需要 Bearer 令牌；当前熊舍成员可保存小程序配置。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();
final UpsertMiniprogramConfigRequest upsertMiniprogramConfigRequest = ; // UpsertMiniprogramConfigRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.upsertMiniprogramConfig(upsertMiniprogramConfigRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->upsertMiniprogramConfig: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **upsertMiniprogramConfigRequest** | [**UpsertMiniprogramConfigRequest**](UpsertMiniprogramConfigRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**MiniprogramConfigResponse**](MiniprogramConfigResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **upsertOwnerPublicSite**
> PublicSiteResponse upsertOwnerPublicSite(upsertPublicSiteRequest, idempotencyKey)

保存熊舍公开主页

需要 Bearer 令牌；当前熊舍成员可保存本舍公开主页配置。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getP2Api();
final UpsertPublicSiteRequest upsertPublicSiteRequest = ; // UpsertPublicSiteRequest |
final String idempotencyKey = idempotencyKey_example; // String | P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。

try {
    final response = api.upsertOwnerPublicSite(upsertPublicSiteRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling P2Api->upsertOwnerPublicSite: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **upsertPublicSiteRequest** | [**UpsertPublicSiteRequest**](UpsertPublicSiteRequest.md)|  |
 **idempotencyKey** | **String**| P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。 | [optional]

### Return type

[**PublicSiteResponse**](PublicSiteResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
