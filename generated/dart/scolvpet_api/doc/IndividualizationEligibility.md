# scolvpet_api.model.IndividualizationEligibility

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**litterId** | **String** |  |
**litterVersion** | **int** |  |
**eligibleSetToken** | **String** | 绑定 litter version、完整 eligible 身份集合和关键守卫事实的不透明令牌 |
**eligiblePupIdentityIds** | **Set&lt;String&gt;** |  |
**eligibleCount** | **int** |  |
**blockers** | [**List&lt;IndividualizationEligibilityBlocker&gt;**](IndividualizationEligibilityBlocker.md) |  |
**canIndividualize** | **bool** |  |
**computedAt** | [**DateTime**](DateTime.md) |  |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
