// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adjust_litter_count_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdjustLitterCountResponseCWProxy {
  AdjustLitterCountResponse data(AdjustLitterCountResponseData data);

  AdjustLitterCountResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdjustLitterCountResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdjustLitterCountResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AdjustLitterCountResponse call({
    AdjustLitterCountResponseData data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAdjustLitterCountResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAdjustLitterCountResponse.copyWith.fieldName(...)`
class _$AdjustLitterCountResponseCWProxyImpl
    implements _$AdjustLitterCountResponseCWProxy {
  const _$AdjustLitterCountResponseCWProxyImpl(this._value);

  final AdjustLitterCountResponse _value;

  @override
  AdjustLitterCountResponse data(AdjustLitterCountResponseData data) =>
      this(data: data);

  @override
  AdjustLitterCountResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdjustLitterCountResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdjustLitterCountResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AdjustLitterCountResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return AdjustLitterCountResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as AdjustLitterCountResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $AdjustLitterCountResponseCopyWith on AdjustLitterCountResponse {
  /// Returns a callable class that can be used as follows: `instanceOfAdjustLitterCountResponse.copyWith(...)` or like so:`instanceOfAdjustLitterCountResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AdjustLitterCountResponseCWProxy get copyWith =>
      _$AdjustLitterCountResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdjustLitterCountResponse _$AdjustLitterCountResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AdjustLitterCountResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = AdjustLitterCountResponse(
    data: $checkedConvert(
      'data',
      (v) => AdjustLitterCountResponseData.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$AdjustLitterCountResponseToJson(
  AdjustLitterCountResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
