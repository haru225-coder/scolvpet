# scolvpet_api.model.WeightRecordCreateRequest

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**hamsterId** | **String** |  | [optional]
**pupIdentityId** | **String** |  | [optional]
**litterId** | **String** |  | [optional]
**measurementKind** | **String** |  | [optional]
**subjectCount** | **int** |  | [optional]
**weightG** | **num** |  |
**recordedAt** | [**DateTime**](DateTime.md) |  |
**source_** | **String** |  |
**deviceReadingId** | **String** |  | [optional]
**notes** | **String** |  | [optional]
**correctsWeightRecordId** | **String** | 纠错链：本条记录用于更正指定的历史体重记录。原记录不删除、不修改， 读取时可沿 corrects_weight_record_id 回溯完整审计链。  | [optional]
**correctionReason** | **String** | 纠错原因。传了 corrects_weight_record_id 就必须填写，否则返回 422。 | [optional]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
