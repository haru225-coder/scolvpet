# scolvpet_api.model.SpeciesRuleVersion

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**ownerId** | **String** | 系统模板为 null，舍主副本由认证上下文填充 | [optional] 
**scope** | **String** |  | 
**sourceTemplateId** | **String** |  | [optional] 
**speciesCode** | **String** |  | 
**varietyScope** | **List&lt;String&gt;** |  | [optional] 
**gestationMinDays** | **int** |  | 
**gestationMaxDays** | **int** |  | 
**pairingMaxMinutes** | **int** |  | [optional] 
**weaningTargetDays** | **int** |  | 
**sexingTargetDays** | **int** |  | 
**separationTargetDays** | **int** |  | 
**postBreedingRestDays** | **int** |  | [optional] 
**profileCreationDeadlineDays** | **int** |  | [optional] 
**weightReference** | **Map&lt;String, Object&gt;** |  | [optional] 
**sourceNote** | **String** |  | 
**version** | **int** |  | 
**effectiveAt** | [**DateTime**](DateTime.md) |  | 
**frozen** | **bool** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


