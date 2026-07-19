// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_opportunity_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GrowthOpportunityListResponseCWProxy {
  GrowthOpportunityListResponse data(List<GrowthOpportunity> data);

  GrowthOpportunityListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrowthOpportunityListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrowthOpportunityListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  GrowthOpportunityListResponse call({
    List<GrowthOpportunity> data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGrowthOpportunityListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGrowthOpportunityListResponse.copyWith.fieldName(...)`
class _$GrowthOpportunityListResponseCWProxyImpl
    implements _$GrowthOpportunityListResponseCWProxy {
  const _$GrowthOpportunityListResponseCWProxyImpl(this._value);

  final GrowthOpportunityListResponse _value;

  @override
  GrowthOpportunityListResponse data(List<GrowthOpportunity> data) =>
      this(data: data);

  @override
  GrowthOpportunityListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrowthOpportunityListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrowthOpportunityListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  GrowthOpportunityListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return GrowthOpportunityListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<GrowthOpportunity>,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $GrowthOpportunityListResponseCopyWith
    on GrowthOpportunityListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfGrowthOpportunityListResponse.copyWith(...)` or like so:`instanceOfGrowthOpportunityListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GrowthOpportunityListResponseCWProxy get copyWith =>
      _$GrowthOpportunityListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrowthOpportunityListResponse _$GrowthOpportunityListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('GrowthOpportunityListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = GrowthOpportunityListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => GrowthOpportunity.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$GrowthOpportunityListResponseToJson(
  GrowthOpportunityListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'meta': instance.meta.toJson(),
};
