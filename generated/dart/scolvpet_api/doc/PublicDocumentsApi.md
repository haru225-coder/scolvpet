# scolvpet_api.api.PublicDocumentsApi

## Load the API package
```dart
import 'package:scolvpet_api/api.dart';
```

All URIs are relative to *https://api.scolvpet.cn/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getPublicDocument**](PublicDocumentsApi.md#getpublicdocument) | **GET** /v1/public/documents/{token} | 客户只读查看已签发合同/回执


# **getPublicDocument**
> PublicDocumentResponse getPublicDocument(token)

客户只读查看已签发合同/回执

能力令牌访问；仅 status=issued 的单据可见。 不暴露 owner_id、内部 ID 与未签发草稿。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getPublicDocumentsApi();
final String token = token_example; // String |

try {
    final response = api.getPublicDocument(token);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PublicDocumentsApi->getPublicDocument: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  |

### Return type

[**PublicDocumentResponse**](PublicDocumentResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
