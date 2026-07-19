# scolvpet_api.model.PairingAttempt

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  |
**breedingPlanId** | **String** |  |
**sequence** | **int** |  |
**enclosureId** | **String** |  |
**startedAt** | [**DateTime**](DateTime.md) |  |
**endedAt** | [**DateTime**](DateTime.md) |  | [optional]
**separatedAt** | [**DateTime**](DateTime.md) |  | [optional]
**separationDeadline** | [**DateTime**](DateTime.md) |  |
**status** | [**PairingAttemptStatus**](PairingAttemptStatus.md) |  |
**result** | [**PairingResult**](PairingResult.md) | 配对尝试未结束时为 null，分笼闭环后写入持久结果 |
**conflictLevel** | **String** |  | [optional]
**sireDestinationEnclosureId** | **String** |  | [optional]
**damDestinationEnclosureId** | **String** |  | [optional]
**notes** | **String** |  | [optional]
**version** | **int** |  |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
