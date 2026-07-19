# scolvpet_api.model.Enclosure

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  |
**ownerId** | **String** |  |
**code** | **String** |  |
**rackCode** | **String** |  | [optional]
**levelCode** | **String** |  | [optional]
**dimensions** | [**EnclosureDimensions**](EnclosureDimensions.md) |  | [optional]
**state** | [**EnclosureState**](EnclosureState.md) |  |
**cleanlinessState** | [**CleanlinessState**](CleanlinessState.md) |  |
**capacity** | **int** |  | [optional] [default to 1]
**equipment** | **List&lt;String&gt;** |  | [optional]
**lastCleanedAt** | [**DateTime**](DateTime.md) |  | [optional]
**currentStays** | [**List&lt;EnclosureStay&gt;**](EnclosureStay.md) |  | [optional]
**version** | **int** |  |
**createdAt** | [**DateTime**](DateTime.md) |  |
**updatedAt** | [**DateTime**](DateTime.md) |  |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
