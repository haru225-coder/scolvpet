# scolvpet_api.model.BreedingPlan

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  |
**ownerId** | **String** |  |
**name** | **String** |  | [optional]
**sireId** | **String** |  |
**damId** | **String** |  |
**ruleVersionId** | **String** |  |
**state** | [**BreedingPlanState**](BreedingPlanState.md) |  |
**plannedPairingAt** | [**DateTime**](DateTime.md) |  | [optional]
**matingBaselineAt** | [**DateTime**](DateTime.md) |  | [optional]
**expectedBirthStart** | [**DateTime**](DateTime.md) |  | [optional]
**expectedBirthEnd** | [**DateTime**](DateTime.md) |  | [optional]
**actualBirthAt** | [**DateTime**](DateTime.md) |  | [optional]
**activePairingAttemptId** | **String** |  | [optional]
**litterId** | **String** |  | [optional]
**objectiveTraits** | **Map&lt;String, Object&gt;** |  | [optional]
**kinshipCheck** | [**KinshipCheck**](KinshipCheck.md) |  | [optional]
**notes** | **String** |  | [optional]
**version** | **int** |  |
**createdAt** | [**DateTime**](DateTime.md) |  |
**updatedAt** | [**DateTime**](DateTime.md) |  |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
