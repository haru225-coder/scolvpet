// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genetic_profile_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GeneticProfileListResponseCWProxy {
  GeneticProfileListResponse data(List<GeneticProfile> data);

  GeneticProfileListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeneticProfileListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeneticProfileListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  GeneticProfileListResponse call({
    List<GeneticProfile> data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGeneticProfileListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGeneticProfileListResponse.copyWith.fieldName(...)`
class _$GeneticProfileListResponseCWProxyImpl
    implements _$GeneticProfileListResponseCWProxy {
  const _$GeneticProfileListResponseCWProxyImpl(this._value);

  final GeneticProfileListResponse _value;

  @override
  GeneticProfileListResponse data(List<GeneticProfile> data) =>
      this(data: data);

  @override
  GeneticProfileListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeneticProfileListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeneticProfileListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  GeneticProfileListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return GeneticProfileListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<GeneticProfile>,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $GeneticProfileListResponseCopyWith on GeneticProfileListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfGeneticProfileListResponse.copyWith(...)` or like so:`instanceOfGeneticProfileListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GeneticProfileListResponseCWProxy get copyWith =>
      _$GeneticProfileListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneticProfileListResponse _$GeneticProfileListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('GeneticProfileListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = GeneticProfileListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => GeneticProfile.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$GeneticProfileListResponseToJson(
  GeneticProfileListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'meta': instance.meta.toJson(),
};
