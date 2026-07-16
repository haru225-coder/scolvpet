// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'separate_pairing_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SeparatePairingResponseCWProxy {
  SeparatePairingResponse data(SeparatePairingResponseData data);

  SeparatePairingResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SeparatePairingResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SeparatePairingResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SeparatePairingResponse call({
    SeparatePairingResponseData data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSeparatePairingResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSeparatePairingResponse.copyWith.fieldName(...)`
class _$SeparatePairingResponseCWProxyImpl
    implements _$SeparatePairingResponseCWProxy {
  const _$SeparatePairingResponseCWProxyImpl(this._value);

  final SeparatePairingResponse _value;

  @override
  SeparatePairingResponse data(SeparatePairingResponseData data) =>
      this(data: data);

  @override
  SeparatePairingResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SeparatePairingResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SeparatePairingResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SeparatePairingResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return SeparatePairingResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as SeparatePairingResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $SeparatePairingResponseCopyWith on SeparatePairingResponse {
  /// Returns a callable class that can be used as follows: `instanceOfSeparatePairingResponse.copyWith(...)` or like so:`instanceOfSeparatePairingResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SeparatePairingResponseCWProxy get copyWith =>
      _$SeparatePairingResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SeparatePairingResponse _$SeparatePairingResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SeparatePairingResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = SeparatePairingResponse(
    data: $checkedConvert(
      'data',
      (v) => SeparatePairingResponseData.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$SeparatePairingResponseToJson(
  SeparatePairingResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
