# scolvpet_api.model.UsageResponseData

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**metrics** | [**List&lt;UsageMetric&gt;**](UsageMetric.md) | active_hamsters、active_litters、enclosures、media_bytes、video_minutes、backup_bytes 各一项 | 
**meteringStatus** | **String** | updating/delayed 只影响展示，不阻止业务写入 | 
**entitlement** | [**UsageResponseDataEntitlement**](UsageResponseDataEntitlement.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


