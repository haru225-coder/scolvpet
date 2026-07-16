// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedigree_graph_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PedigreeGraphResponseCWProxy {
  PedigreeGraphResponse data(PedigreeGraphResponseData data);

  PedigreeGraphResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PedigreeGraphResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PedigreeGraphResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PedigreeGraphResponse call({
    PedigreeGraphResponseData data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPedigreeGraphResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPedigreeGraphResponse.copyWith.fieldName(...)`
class _$PedigreeGraphResponseCWProxyImpl
    implements _$PedigreeGraphResponseCWProxy {
  const _$PedigreeGraphResponseCWProxyImpl(this._value);

  final PedigreeGraphResponse _value;

  @override
  PedigreeGraphResponse data(PedigreeGraphResponseData data) =>
      this(data: data);

  @override
  PedigreeGraphResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PedigreeGraphResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PedigreeGraphResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PedigreeGraphResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return PedigreeGraphResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as PedigreeGraphResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $PedigreeGraphResponseCopyWith on PedigreeGraphResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPedigreeGraphResponse.copyWith(...)` or like so:`instanceOfPedigreeGraphResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PedigreeGraphResponseCWProxy get copyWith =>
      _$PedigreeGraphResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PedigreeGraphResponse _$PedigreeGraphResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PedigreeGraphResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = PedigreeGraphResponse(
    data: $checkedConvert(
      'data',
      (v) => PedigreeGraphResponseData.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$PedigreeGraphResponseToJson(
  PedigreeGraphResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
