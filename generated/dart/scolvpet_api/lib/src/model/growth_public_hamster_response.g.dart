// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_public_hamster_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GrowthPublicHamsterResponseCWProxy {
  GrowthPublicHamsterResponse data(GrowthPublicHamster data);

  GrowthPublicHamsterResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrowthPublicHamsterResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrowthPublicHamsterResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  GrowthPublicHamsterResponse call({
    GrowthPublicHamster data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGrowthPublicHamsterResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGrowthPublicHamsterResponse.copyWith.fieldName(...)`
class _$GrowthPublicHamsterResponseCWProxyImpl
    implements _$GrowthPublicHamsterResponseCWProxy {
  const _$GrowthPublicHamsterResponseCWProxyImpl(this._value);

  final GrowthPublicHamsterResponse _value;

  @override
  GrowthPublicHamsterResponse data(GrowthPublicHamster data) =>
      this(data: data);

  @override
  GrowthPublicHamsterResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrowthPublicHamsterResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrowthPublicHamsterResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  GrowthPublicHamsterResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return GrowthPublicHamsterResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as GrowthPublicHamster,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $GrowthPublicHamsterResponseCopyWith on GrowthPublicHamsterResponse {
  /// Returns a callable class that can be used as follows: `instanceOfGrowthPublicHamsterResponse.copyWith(...)` or like so:`instanceOfGrowthPublicHamsterResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GrowthPublicHamsterResponseCWProxy get copyWith =>
      _$GrowthPublicHamsterResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrowthPublicHamsterResponse _$GrowthPublicHamsterResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('GrowthPublicHamsterResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = GrowthPublicHamsterResponse(
    data: $checkedConvert(
      'data',
      (v) => GrowthPublicHamster.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$GrowthPublicHamsterResponseToJson(
  GrowthPublicHamsterResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
