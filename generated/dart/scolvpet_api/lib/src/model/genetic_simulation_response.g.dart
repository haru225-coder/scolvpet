// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genetic_simulation_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GeneticSimulationResponseCWProxy {
  GeneticSimulationResponse data(GeneticSimulationResult data);

  GeneticSimulationResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeneticSimulationResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeneticSimulationResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  GeneticSimulationResponse call({
    GeneticSimulationResult data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGeneticSimulationResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGeneticSimulationResponse.copyWith.fieldName(...)`
class _$GeneticSimulationResponseCWProxyImpl
    implements _$GeneticSimulationResponseCWProxy {
  const _$GeneticSimulationResponseCWProxyImpl(this._value);

  final GeneticSimulationResponse _value;

  @override
  GeneticSimulationResponse data(GeneticSimulationResult data) =>
      this(data: data);

  @override
  GeneticSimulationResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeneticSimulationResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeneticSimulationResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  GeneticSimulationResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return GeneticSimulationResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as GeneticSimulationResult,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $GeneticSimulationResponseCopyWith on GeneticSimulationResponse {
  /// Returns a callable class that can be used as follows: `instanceOfGeneticSimulationResponse.copyWith(...)` or like so:`instanceOfGeneticSimulationResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GeneticSimulationResponseCWProxy get copyWith =>
      _$GeneticSimulationResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneticSimulationResponse _$GeneticSimulationResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('GeneticSimulationResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = GeneticSimulationResponse(
    data: $checkedConvert(
      'data',
      (v) => GeneticSimulationResult.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$GeneticSimulationResponseToJson(
  GeneticSimulationResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
