# PublicDocumentsApi

All URIs are relative to *https://api.scolvpet.cn/v1*

| Method | HTTP request | Description |
|------------- | ------------- | -------------|
| [**getPublicDocument**](PublicDocumentsApi.md#getpublicdocument) | **GET** /v1/public/documents/{token} | 客户只读查看已签发合同/回执 |



## getPublicDocument

> PublicDocumentResponse getPublicDocument(token)

客户只读查看已签发合同/回执

能力令牌访问；仅 status&#x3D;issued 的单据可见。 不暴露 owner_id、内部 ID 与未签发草稿。 

### Example

```ts
import {
  Configuration,
  PublicDocumentsApi,
} from '@scolvpet/scolvpet-api';
import type { GetPublicDocumentRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const api = new PublicDocumentsApi();

  const body = {
    // string
    token: token_example,
  } satisfies GetPublicDocumentRequest;

  try {
    const data = await api.getPublicDocument(body);
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
| **token** | `string` |  | [Defaults to `undefined`] |

### Return type

[**PublicDocumentResponse**](PublicDocumentResponse.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 公开单据投影 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)

