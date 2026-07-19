// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_lead_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GrowthLeadListResponseCWProxy {
  GrowthLeadListResponse data(List<GrowthLead> data);

  GrowthLeadListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrowthLeadListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrowthLeadListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  GrowthLeadListResponse call({List<GrowthLead> data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGrowthLeadListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGrowthLeadListResponse.copyWith.fieldName(...)`
class _$GrowthLeadListResponseCWProxyImpl
    implements _$GrowthLeadListResponseCWProxy {
  const _$GrowthLeadListResponseCWProxyImpl(this._value);

  final GrowthLeadListResponse _value;

  @override
  GrowthLeadListResponse data(List<GrowthLead> data) => this(data: data);

  @override
  GrowthLeadListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrowthLeadListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrowthLeadListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  GrowthLeadListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return GrowthLeadListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<GrowthLead>,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $GrowthLeadListResponseCopyWith on GrowthLeadListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfGrowthLeadListResponse.copyWith(...)` or like so:`instanceOfGrowthLeadListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GrowthLeadListResponseCWProxy get copyWith =>
      _$GrowthLeadListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrowthLeadListResponse _$GrowthLeadListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('GrowthLeadListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = GrowthLeadListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => GrowthLead.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$GrowthLeadListResponseToJson(
  GrowthLeadListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'meta': instance.meta.toJson(),
};
