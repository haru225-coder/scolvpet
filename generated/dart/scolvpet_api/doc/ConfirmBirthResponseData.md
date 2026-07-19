# scolvpet_api.model.ConfirmBirthResponseData

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**resultType** | **String** |  |
**breedingPlan** | [**BreedingPlan**](BreedingPlan.md) |  |
**litter** | [**Litter**](Litter.md) |  |
**pupIdentityCount** | **int** |  |
**pupIdentities** | [**List&lt;PupIdentity&gt;**](PupIdentity.md) | 数量严格等于 pup_identity_count 和请求 initial_alive_count |
**initialCountEvent** | [**LitterCountEvent**](LitterCountEvent.md) |  |
**celebrationJob** | [**AsyncJob**](AsyncJob.md) |  | [optional]
**birthEventId** | **String** |  |
**eventType** | **String** |  |
**bornAt** | [**DateTime**](DateTime.md) |  |
**initialOtherCount** | **int** |  |
**outcomeReason** | **String** |  |
**damCondition** | [**DamCondition**](DamCondition.md) |  |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
