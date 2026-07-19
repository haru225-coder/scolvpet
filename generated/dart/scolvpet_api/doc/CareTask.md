# scolvpet_api.model.CareTask

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  |
**taskType** | **String** |  |
**targetType** | **String** |  |
**targetId** | **String** |  |
**title** | **String** |  | [optional]
**scheduledAt** | [**DateTime**](DateTime.md) |  |
**priority** | [**TaskPriority**](TaskPriority.md) |  |
**state** | [**TaskState**](TaskState.md) |  |
**subjectIds** | **List&lt;String&gt;** |  | [optional]
**completedSubjectIds** | **List&lt;String&gt;** |  | [optional]
**stageTotal** | **int** |  |
**stageDone** | **int** |  |
**sourceEventId** | **String** |  | [optional]
**notes** | **String** |  | [optional]
**version** | **int** |  |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
