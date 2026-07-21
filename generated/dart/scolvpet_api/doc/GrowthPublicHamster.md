# scolvpet_api.model.GrowthPublicHamster

## Load the model package
```dart
import 'package:scolvpet_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**hamsterId** | **String** |  |
**publicName** | **String** |  |
**summary** | **String** |  | [optional]
**traits** | **List&lt;String&gt;** |  | [optional]
**sex** | **String** |  | [optional]
**variety** | **String** |  | [optional]
**birthDate** | [**DateTime**](DateTime.md) |  | [optional]
**filmingStatus** | **String** |  |
**published** | **bool** |  |
**consultable** | **bool** |  |
**reservable** | **bool** | Backend 唯一可订判定（公开可咨询且无 held/confirmed 预订） |
**ctaText** | **String** |  | [optional]
**priceLabel** | **String** |  | [optional]
**media** | [**List&lt;GrowthPublicMedia&gt;**](GrowthPublicMedia.md) |  | [optional]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
