# scolvpet_api.model.ImportPreflightRequest

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**strictReferences** | **bool** | 父母、窝次和笼位引用缺失时必须报错 |
**duplicatePolicy** | **String** |  | [optional] [default to 'reject']
**historicalLitterPolicy** | **String** | create_if_complete 仅在同一历史窝次编号的出生时间、双亲和物种规则一致时， 自动规划创建一个历史窝次；信息缺失或冲突时产生阻塞问题。  |
**parentageConflictPolicy** | **String** | 导入父母与既有已接受谱系边或同窝父母不一致时拒绝相关行 |
**existingFieldPolicy** | **String** | 默认不覆盖已有非空字段；更新候选必须在提交时逐项确认并带版本 |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
