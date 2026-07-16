// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'individualize_litter_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$IndividualizeLitterResponseCWProxy {
  IndividualizeLitterResponse data(IndividualizeLitterResponseData data);

  IndividualizeLitterResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IndividualizeLitterResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IndividualizeLitterResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  IndividualizeLitterResponse call({
    IndividualizeLitterResponseData data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfIndividualizeLitterResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfIndividualizeLitterResponse.copyWith.fieldName(...)`
class _$IndividualizeLitterResponseCWProxyImpl
    implements _$IndividualizeLitterResponseCWProxy {
  const _$IndividualizeLitterResponseCWProxyImpl(this._value);

  final IndividualizeLitterResponse _value;

  @override
  IndividualizeLitterResponse data(IndividualizeLitterResponseData data) =>
      this(data: data);

  @override
  IndividualizeLitterResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IndividualizeLitterResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IndividualizeLitterResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  IndividualizeLitterResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return IndividualizeLitterResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as IndividualizeLitterResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $IndividualizeLitterResponseCopyWith on IndividualizeLitterResponse {
  /// Returns a callable class that can be used as follows: `instanceOfIndividualizeLitterResponse.copyWith(...)` or like so:`instanceOfIndividualizeLitterResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$IndividualizeLitterResponseCWProxy get copyWith =>
      _$IndividualizeLitterResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IndividualizeLitterResponse _$IndividualizeLitterResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('IndividualizeLitterResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = IndividualizeLitterResponse(
    data: $checkedConvert(
      'data',
      (v) =>
          IndividualizeLitterResponseData.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$IndividualizeLitterResponseToJson(
  IndividualizeLitterResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
