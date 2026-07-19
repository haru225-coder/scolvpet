# scolvpet_api.model.GeneticSimulationRequest

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**mode** | **String** | phenotype_table=核心表查表；mendel=简化孟德尔 | [optional]
**series** | **String** | 系列代码或中文名，如 poly / 波利系列 / chocolate / 巧克力色系 | [optional]
**sirePhenotype** | **String** | 父本表型（phenotype_table 模式） | [optional]
**damPhenotype** | **String** | 母本表型（phenotype_table 模式） | [optional]
**sireHamsterId** | **String** | 可选父本档案 ID；父母双方都提供时启用具体亲本历史校准 | [optional]
**damHamsterId** | **String** | 可选母本档案 ID；父母双方都提供时启用具体亲本历史校准 | [optional]
**targetPhenotype** | **String** | 可选重点表型；客户端可据最终概率计算本窝至少出现一只的机会 | [optional]
**sire** | **Map&lt;String, String&gt;** | 父本基因型位点映射（mendel 模式） | [optional]
**dam** | **Map&lt;String, String&gt;** | 母本基因型位点映射（mendel 模式） | [optional]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
