# scolvpet_api.model.HamsterCreateRequest

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**internalCode** | **String** |  |
**name** | **String** |  | [optional]
**speciesRuleVersionId** | **String** |  |
**varietyCode** | **String** |  | [optional]
**sex** | [**Sex**](Sex.md) |  |
**sexConfidence** | **num** |  | [optional]
**birthDate** | [**DateTime**](DateTime.md) |  | [optional]
**sourceType** | [**HamsterSourceType**](HamsterSourceType.md) |  |
**coverMediaId** | **String** |  | [optional]
**notes** | **String** |  | [optional]
**sireId** | **String** | 创建时可附带父本断言，服务端写入 pedigree_parentage | [optional]
**damId** | **String** | 创建时可附带母本断言，服务端写入 pedigree_parentage | [optional]
**litterId** | **String** | 外部或历史导入时关联窝次 | [optional]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
