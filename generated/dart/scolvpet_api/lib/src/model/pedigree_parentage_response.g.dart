// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedigree_parentage_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PedigreeParentageResponseCWProxy {
  PedigreeParentageResponse data(PedigreeParentage data);

  PedigreeParentageResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PedigreeParentageResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PedigreeParentageResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PedigreeParentageResponse call({PedigreeParentage data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPedigreeParentageResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPedigreeParentageResponse.copyWith.fieldName(...)`
class _$PedigreeParentageResponseCWProxyImpl
    implements _$PedigreeParentageResponseCWProxy {
  const _$PedigreeParentageResponseCWProxyImpl(this._value);

  final PedigreeParentageResponse _value;

  @override
  PedigreeParentageResponse data(PedigreeParentage data) => this(data: data);

  @override
  PedigreeParentageResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PedigreeParentageResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PedigreeParentageResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PedigreeParentageResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return PedigreeParentageResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as PedigreeParentage,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $PedigreeParentageResponseCopyWith on PedigreeParentageResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPedigreeParentageResponse.copyWith(...)` or like so:`instanceOfPedigreeParentageResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PedigreeParentageResponseCWProxy get copyWith =>
      _$PedigreeParentageResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PedigreeParentageResponse _$PedigreeParentageResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PedigreeParentageResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = PedigreeParentageResponse(
    data: $checkedConvert(
      'data',
      (v) => PedigreeParentage.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$PedigreeParentageResponseToJson(
  PedigreeParentageResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
