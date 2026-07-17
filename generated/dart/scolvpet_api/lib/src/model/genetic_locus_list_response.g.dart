// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genetic_locus_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GeneticLocusListResponseCWProxy {
  GeneticLocusListResponse data(List<GeneticLocus> data);

  GeneticLocusListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeneticLocusListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeneticLocusListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  GeneticLocusListResponse call({List<GeneticLocus> data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGeneticLocusListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGeneticLocusListResponse.copyWith.fieldName(...)`
class _$GeneticLocusListResponseCWProxyImpl
    implements _$GeneticLocusListResponseCWProxy {
  const _$GeneticLocusListResponseCWProxyImpl(this._value);

  final GeneticLocusListResponse _value;

  @override
  GeneticLocusListResponse data(List<GeneticLocus> data) => this(data: data);

  @override
  GeneticLocusListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeneticLocusListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeneticLocusListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  GeneticLocusListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return GeneticLocusListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<GeneticLocus>,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $GeneticLocusListResponseCopyWith on GeneticLocusListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfGeneticLocusListResponse.copyWith(...)` or like so:`instanceOfGeneticLocusListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GeneticLocusListResponseCWProxy get copyWith =>
      _$GeneticLocusListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneticLocusListResponse _$GeneticLocusListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('GeneticLocusListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = GeneticLocusListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => GeneticLocus.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$GeneticLocusListResponseToJson(
  GeneticLocusListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'meta': instance.meta.toJson(),
};
