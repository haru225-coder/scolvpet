// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genetic_profile_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GeneticProfileResponseCWProxy {
  GeneticProfileResponse data(GeneticProfile data);

  GeneticProfileResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeneticProfileResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeneticProfileResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  GeneticProfileResponse call({GeneticProfile data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGeneticProfileResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGeneticProfileResponse.copyWith.fieldName(...)`
class _$GeneticProfileResponseCWProxyImpl
    implements _$GeneticProfileResponseCWProxy {
  const _$GeneticProfileResponseCWProxyImpl(this._value);

  final GeneticProfileResponse _value;

  @override
  GeneticProfileResponse data(GeneticProfile data) => this(data: data);

  @override
  GeneticProfileResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeneticProfileResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeneticProfileResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  GeneticProfileResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return GeneticProfileResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as GeneticProfile,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $GeneticProfileResponseCopyWith on GeneticProfileResponse {
  /// Returns a callable class that can be used as follows: `instanceOfGeneticProfileResponse.copyWith(...)` or like so:`instanceOfGeneticProfileResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GeneticProfileResponseCWProxy get copyWith =>
      _$GeneticProfileResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneticProfileResponse _$GeneticProfileResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('GeneticProfileResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = GeneticProfileResponse(
    data: $checkedConvert(
      'data',
      (v) => GeneticProfile.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$GeneticProfileResponseToJson(
  GeneticProfileResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
