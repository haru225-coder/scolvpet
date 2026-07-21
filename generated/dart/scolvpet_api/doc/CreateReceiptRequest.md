# scolvpet_api.model.CreateReceiptRequest

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**templateId** | **String** |  |
**contactId** | **String** |  | [optional]
**handoverId** | **String** |  | [optional]
**reservationId** | **String** | 从统一预订继承客户与仓鼠；可同时关联已有交付 | [optional]
**title** | **String** |  | [optional]
**amountCents** | **int** |  |
**currency** | **String** |  | [optional] [default to 'CNY']
**notes** | **String** |  | [optional]
**contactName** | **String** |  | [optional]
**hamsterName** | **String** |  | [optional]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
