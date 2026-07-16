// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_pairing_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StartPairingResponseCWProxy {
  StartPairingResponse data(StartPairingResponseData data);

  StartPairingResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StartPairingResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StartPairingResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  StartPairingResponse call({StartPairingResponseData data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStartPairingResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStartPairingResponse.copyWith.fieldName(...)`
class _$StartPairingResponseCWProxyImpl
    implements _$StartPairingResponseCWProxy {
  const _$StartPairingResponseCWProxyImpl(this._value);

  final StartPairingResponse _value;

  @override
  StartPairingResponse data(StartPairingResponseData data) => this(data: data);

  @override
  StartPairingResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StartPairingResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StartPairingResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  StartPairingResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return StartPairingResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as StartPairingResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $StartPairingResponseCopyWith on StartPairingResponse {
  /// Returns a callable class that can be used as follows: `instanceOfStartPairingResponse.copyWith(...)` or like so:`instanceOfStartPairingResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StartPairingResponseCWProxy get copyWith =>
      _$StartPairingResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartPairingResponse _$StartPairingResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('StartPairingResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = StartPairingResponse(
    data: $checkedConvert(
      'data',
      (v) => StartPairingResponseData.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$StartPairingResponseToJson(
  StartPairingResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
