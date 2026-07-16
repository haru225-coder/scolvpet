# scolvpet_api.model.ImportCommitRequest

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**preflightVersion** | **int** |  | 
**batchKey** | **String** |  | 
**partialFailurePolicy** | **String** |  | 
**approvedUpdates** | [**Set&lt;ImportCommitRequestApprovedUpdatesInner&gt;**](ImportCommitRequestApprovedUpdatesInner.md) | 预检列出的更新候选逐项确认；未列出的已有非空字段保持不变 | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


