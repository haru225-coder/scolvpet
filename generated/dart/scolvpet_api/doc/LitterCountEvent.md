# scolvpet_api.model.LitterCountEvent

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  |
**litterId** | **String** |  |
**eventType** | **String** | confirm-birth 的 initial_alive 为正；discovered 为正；death/transferred_out 为负；correction 非零 |
**delta** | **int** |  |
**occurredAt** | [**DateTime**](DateTime.md) |  |
**reason** | **String** |  | [optional]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
