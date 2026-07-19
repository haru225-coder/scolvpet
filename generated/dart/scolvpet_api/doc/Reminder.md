# scolvpet_api.model.Reminder

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  |
**ruleCode** | **String** |  |
**ruleVersion** | **String** |  | [optional]
**baseEventId** | **String** |  | [optional]
**targetType** | **String** |  | [optional]
**targetId** | **String** |  | [optional]
**scheduledAt** | [**DateTime**](DateTime.md) |  |
**state** | [**ReminderState**](ReminderState.md) |  |
**supersededBy** | **String** |  | [optional]
**channelStatuses** | [**List&lt;ReminderDelivery&gt;**](ReminderDelivery.md) |  |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
