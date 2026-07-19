# scolvpet_api.model.AdjustLitterCountRequest

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**eventType** | **String** |  |
**delta** | **int** | discovered 必须为正；death/transferred_out 必须为负；correction 非零 |
**occurredAt** | [**DateTime**](DateTime.md) |  |
**reason** | **String** |  |
**newTemporaryCodes** | **Set&lt;String&gt;** |  | [optional]
**affectedPupIdentityIds** | **Set&lt;String&gt;** |  | [optional]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
