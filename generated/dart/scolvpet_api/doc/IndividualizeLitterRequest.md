# scolvpet_api.model.IndividualizeLitterRequest

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**individualizedAt** | [**DateTime**](DateTime.md) |  |
**timezone** | **String** |  |
**eligibleSetToken** | **String** | 来自最新 individualization-eligibility 响应；仅作并发快照，不替代服务端重算 |
**items** | [**List&lt;IndividualizeLitterRequestItemsInner&gt;**](IndividualizeLitterRequestItemsInner.md) |  |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
