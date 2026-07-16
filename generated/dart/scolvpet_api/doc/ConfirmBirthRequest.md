# scolvpet_api.model.ConfirmBirthRequest

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**bornAt** | [**DateTime**](DateTime.md) |  | 
**enclosureId** | **String** | initial_alive_count > 0 时必填；N=0 时必须省略或为 null | [optional] 
**initialAliveCount** | **int** |  | 
**initialOtherCount** | **int** |  | 
**damCondition** | [**DamCondition**](DamCondition.md) |  | 
**outcomeReason** | **String** | 生产结果原因；N=0 时必须明确无活仔原因 | 
**temporaryCodePrefix** | **String** |  | [optional] 
**temporaryCodes** | **Set&lt;String&gt;** | 若提供，数量必须等于 initial_alive_count | [optional] 
**timezone** | **String** |  | 
**notes** | **String** |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


