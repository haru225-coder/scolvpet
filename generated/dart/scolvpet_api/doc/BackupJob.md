# scolvpet_api.model.BackupJob

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**jobType** | **String** |  | 
**status** | [**JobStatus**](JobStatus.md) |  | 
**progressPercent** | **int** |  | 
**currentStep** | **String** |  | [optional] 
**error** | [**ErrorObject**](ErrorObject.md) |  | [optional] 
**retryable** | **bool** |  | 
**attempt** | **int** |  | [optional] [default to 1]
**result** | **Map&lt;String, Object&gt;** |  | [optional] 
**expiresAt** | [**DateTime**](DateTime.md) |  | [optional] 
**version** | **int** |  | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 
**includesStructuredData** | **bool** |  | 
**includesMediaManifest** | **bool** |  | 
**includesChecksums** | **bool** |  | 
**sizeBytes** | **int** |  | [optional] 
**sha256** | **String** |  | [optional] 
**integrityStatus** | **String** |  | 
**restoreReadiness** | **String** |  | 
**verifiedAt** | [**DateTime**](DateTime.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


