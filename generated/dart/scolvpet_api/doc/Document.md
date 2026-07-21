# scolvpet_api.model.Document

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  |
**templateId** | **String** |  |
**kind** | **String** |  |
**contactId** | **String** |  | [optional]
**handoverId** | **String** |  | [optional]
**title** | **String** |  |
**bodyFilled** | **String** |  |
**amountCents** | **int** |  | [optional]
**currency** | **String** |  |
**status** | **String** |  |
**issuedAt** | [**DateTime**](DateTime.md) |  | [optional]
**notes** | **String** |  | [optional]
**version** | **int** |  |
**contactName** | **String** |  | [optional]
**publicToken** | **String** | 已签发单据的客户侧能力令牌 | [optional]
**publicPath** | **String** | 客户侧相对路径，如 /d/{token} | [optional]
**publicUrl** | **String** | 可直接复制或打开的客户侧完整公开 URL | [optional]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
