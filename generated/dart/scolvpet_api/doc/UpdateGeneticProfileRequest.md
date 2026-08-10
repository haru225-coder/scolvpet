# scolvpet_api.model.UpdateGeneticProfileRequest

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | **String** |  | [optional]
**notes** | **String** |  | [optional]
**confidence** | **String** |  | [optional]
**phenotype** | **Map&lt;String, Object&gt;** |  | [optional]
**genotype** | **Map&lt;String, String&gt;** |  | [optional]
**version** | **int** | 当前档案 version，不匹配则 422 |
**hamsterId** | **String** | 绑定个体 uuid；空字符串或 null 解除绑定；省略则不变 | [optional]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
