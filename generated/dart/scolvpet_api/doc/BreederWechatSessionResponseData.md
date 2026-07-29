# scolvpet_api.model.BreederWechatSessionResponseData

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**bindRequired** | **bool** |  | [optional]
**wechatTicket** | **String** | bwt_ 开头的一次性 B 端绑定票据，10 分钟有效，明文仅此一次 | [optional]
**tokenType** | **String** |  | [optional]
**accessToken** | **String** |  | [optional]
**expiresInSeconds** | **int** |  | [optional]
**refreshToken** | **String** |  | [optional]
**account** | [**Account**](Account.md) |  | [optional]
**currentOrganization** | [**Organization**](Organization.md) |  | [optional]
**memberRole** | **String** |  | [optional]
**capabilities** | **List&lt;String&gt;** |  | [optional]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
