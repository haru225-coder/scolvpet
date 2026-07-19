// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_campaign_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GrowthCampaignListResponseCWProxy {
  GrowthCampaignListResponse data(List<GrowthCampaign> data);

  GrowthCampaignListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrowthCampaignListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrowthCampaignListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  GrowthCampaignListResponse call({
    List<GrowthCampaign> data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGrowthCampaignListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGrowthCampaignListResponse.copyWith.fieldName(...)`
class _$GrowthCampaignListResponseCWProxyImpl
    implements _$GrowthCampaignListResponseCWProxy {
  const _$GrowthCampaignListResponseCWProxyImpl(this._value);

  final GrowthCampaignListResponse _value;

  @override
  GrowthCampaignListResponse data(List<GrowthCampaign> data) =>
      this(data: data);

  @override
  GrowthCampaignListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrowthCampaignListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrowthCampaignListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  GrowthCampaignListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return GrowthCampaignListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<GrowthCampaign>,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $GrowthCampaignListResponseCopyWith on GrowthCampaignListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfGrowthCampaignListResponse.copyWith(...)` or like so:`instanceOfGrowthCampaignListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GrowthCampaignListResponseCWProxy get copyWith =>
      _$GrowthCampaignListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrowthCampaignListResponse _$GrowthCampaignListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('GrowthCampaignListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = GrowthCampaignListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => GrowthCampaign.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$GrowthCampaignListResponseToJson(
  GrowthCampaignListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'meta': instance.meta.toJson(),
};
