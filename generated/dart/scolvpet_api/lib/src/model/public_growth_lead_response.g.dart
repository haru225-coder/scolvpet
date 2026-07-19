// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_growth_lead_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublicGrowthLeadResponseCWProxy {
  PublicGrowthLeadResponse data(Map<String, Object> data);

  PublicGrowthLeadResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicGrowthLeadResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicGrowthLeadResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicGrowthLeadResponse call({Map<String, Object> data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublicGrowthLeadResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublicGrowthLeadResponse.copyWith.fieldName(...)`
class _$PublicGrowthLeadResponseCWProxyImpl
    implements _$PublicGrowthLeadResponseCWProxy {
  const _$PublicGrowthLeadResponseCWProxyImpl(this._value);

  final PublicGrowthLeadResponse _value;

  @override
  PublicGrowthLeadResponse data(Map<String, Object> data) => this(data: data);

  @override
  PublicGrowthLeadResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicGrowthLeadResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicGrowthLeadResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicGrowthLeadResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return PublicGrowthLeadResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as Map<String, Object>,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $PublicGrowthLeadResponseCopyWith on PublicGrowthLeadResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPublicGrowthLeadResponse.copyWith(...)` or like so:`instanceOfPublicGrowthLeadResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublicGrowthLeadResponseCWProxy get copyWith =>
      _$PublicGrowthLeadResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicGrowthLeadResponse _$PublicGrowthLeadResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PublicGrowthLeadResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = PublicGrowthLeadResponse(
    data: $checkedConvert(
      'data',
      (v) =>
          (v as Map<String, dynamic>).map((k, e) => MapEntry(k, e as Object)),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$PublicGrowthLeadResponseToJson(
  PublicGrowthLeadResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta.toJson()};
