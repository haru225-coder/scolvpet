# CustomerApi

All URIs are relative to *https://api.scolvpet.cn/v1*

| Method | HTTP request | Description |
|------------- | ------------- | -------------|
| [**createCustomerWechatPhoneBinding**](CustomerApi.md#createcustomerwechatphonebindingoperation) | **POST** /v1/public/customer/wechat-phone-bindings | 微信授权手机号并创建客户会话 |



## createCustomerWechatPhoneBinding

> CustomerSessionResponse createCustomerWechatPhoneBinding(createCustomerWechatPhoneBindingRequest)

微信授权手机号并创建客户会话

原子消费 wx.login 下发的 wt_ 一次性票据后，使用 getPhoneNumber 的 phone_code 从微信服务端换取手机号，写入 OpenID↔手机号有效绑定并发放 ct_* 会话。ticket 有效期为 10 分钟；任一凭证失效、ticket 已消费或远程结果不确定时，客户端必须 重新执行 wx.login 并由用户再次授权，不得重放旧 phone_code。

### Example

```ts
import {
  Configuration,
  CustomerApi,
} from '@scolvpet/scolvpet-api';
import type { CreateCustomerWechatPhoneBindingOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const api = new CustomerApi();

  const body = {
    // CreateCustomerWechatPhoneBindingRequest
    createCustomerWechatPhoneBindingRequest: ...,
  } satisfies CreateCustomerWechatPhoneBindingOperationRequest;

  try {
    const data = await api.createCustomerWechatPhoneBinding(body);
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
| **createCustomerWechatPhoneBindingRequest** | [CreateCustomerWechatPhoneBindingRequest](CreateCustomerWechatPhoneBindingRequest.md) |  | |

### Return type

[**CustomerSessionResponse**](CustomerSessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 微信手机号已绑定并创建客户会话 |  -  |
| **409** | 手机号已绑定到另一有效微信身份 |  -  |
| **422** | 微信手机号凭证失效或手机号国家/地区不受支持 |  -  |
| **429** | 请求频率过高 |  * Retry-After - 建议重试等待秒数 <br>  |
| **503** | 微信手机号服务或其全局调用配额暂不可用 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)

