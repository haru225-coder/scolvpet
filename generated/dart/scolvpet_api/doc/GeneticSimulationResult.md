# scolvpet_api.model.GeneticSimulationResult

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**mode** | **String** |  | [optional]
**tableId** | **String** |  | [optional]
**tableVersion** | **String** |  | [optional]
**series** | **String** |  | [optional]
**seriesName** | **String** |  | [optional]
**sirePhenotype** | **String** |  | [optional]
**damPhenotype** | **String** |  | [optional]
**sire** | **Map&lt;String, String&gt;** |  |
**dam** | **Map&lt;String, String&gt;** |  |
**outcomes** | [**List&lt;GeneticOutcome&gt;**](GeneticOutcome.md) |  |
**tableOutcomes** | [**List&lt;PhenotypeTableOutcome&gt;**](PhenotypeTableOutcome.md) |  | [optional]
**predictionBasis** | **String** | 前端仅需映射为“基于权威表”或“已结合历史繁殖记录” | [optional]
**historyLitterCount** | **int** |  | [optional]
**historyPupCount** | **int** |  | [optional]
**notes** | **String** |  |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
