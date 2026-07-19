// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_campaign_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GrowthCampaignResponseCWProxy {
  GrowthCampaignResponse data(GrowthCampaign data);

  GrowthCampaignResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrowthCampaignResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrowthCampaignResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  GrowthCampaignResponse call({GrowthCampaign data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGrowthCampaignResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGrowthCampaignResponse.copyWith.fieldName(...)`
class _$GrowthCampaignResponseCWProxyImpl
    implements _$GrowthCampaignResponseCWProxy {
  const _$GrowthCampaignResponseCWProxyImpl(this._value);

  final GrowthCampaignResponse _value;

  @override
  GrowthCampaignResponse data(GrowthCampaign data) => this(data: data);

  @override
  GrowthCampaignResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrowthCampaignResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrowthCampaignResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  GrowthCampaignResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return GrowthCampaignResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as GrowthCampaign,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $GrowthCampaignResponseCopyWith on GrowthCampaignResponse {
  /// Returns a callable class that can be used as follows: `instanceOfGrowthCampaignResponse.copyWith(...)` or like so:`instanceOfGrowthCampaignResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GrowthCampaignResponseCWProxy get copyWith =>
      _$GrowthCampaignResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrowthCampaignResponse _$GrowthCampaignResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('GrowthCampaignResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = GrowthCampaignResponse(
    data: $checkedConvert(
      'data',
      (v) => GrowthCampaign.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$GrowthCampaignResponseToJson(
  GrowthCampaignResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
