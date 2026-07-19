# scolvpet_api.model.HealthRecordCreateRequest

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**hamsterId** | **String** |  | [optional]
**litterId** | **String** |  | [optional]
**type** | [**HealthRecordType**](HealthRecordType.md) |  |
**observedAt** | [**DateTime**](DateTime.md) |  |
**structuredChecks** | **Map&lt;String, Object&gt;** |  | [optional]
**severity** | [**Severity**](Severity.md) |  | [optional]
**medication** | **Map&lt;String, Object&gt;** |  | [optional]
**mediaIds** | **List&lt;String&gt;** |  | [optional]
**followUpAt** | [**DateTime**](DateTime.md) |  | [optional]
**notes** | **String** |  | [optional]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
