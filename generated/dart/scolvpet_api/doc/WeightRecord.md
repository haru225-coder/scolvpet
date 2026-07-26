# scolvpet_api.model.WeightRecord

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  |
**hamsterId** | **String** |  | [optional]
**pupIdentityId** | **String** |  | [optional]
**litterId** | **String** |  | [optional]
**measurementKind** | **String** |  | [optional]
**subjectCount** | **int** |  | [optional]
**weightG** | **num** |  |
**recordedAt** | [**DateTime**](DateTime.md) |  |
**source_** | **String** |  |
**birthWeightG** | **num** |  | [optional]
**previousWeightG** | **num** |  | [optional]
**changeFromPreviousG** | **num** |  | [optional]
**changeFromBirthG** | **num** |  | [optional]
**alertFlags** | **List&lt;String&gt;** |  |
**notes** | **String** |  | [optional]
**correctsWeightRecordId** | **String** | 若非空，本条记录是对该历史记录的纠错，原记录仍然保留。 | [optional]
**correctionReason** | **String** |  | [optional]
**createdAt** | [**DateTime**](DateTime.md) |  |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
