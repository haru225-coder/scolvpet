// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_attempt_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PairingAttemptResponseCWProxy {
  PairingAttemptResponse data(PairingAttempt data);

  PairingAttemptResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PairingAttemptResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PairingAttemptResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PairingAttemptResponse call({PairingAttempt data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPairingAttemptResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPairingAttemptResponse.copyWith.fieldName(...)`
class _$PairingAttemptResponseCWProxyImpl
    implements _$PairingAttemptResponseCWProxy {
  const _$PairingAttemptResponseCWProxyImpl(this._value);

  final PairingAttemptResponse _value;

  @override
  PairingAttemptResponse data(PairingAttempt data) => this(data: data);

  @override
  PairingAttemptResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PairingAttemptResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PairingAttemptResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PairingAttemptResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return PairingAttemptResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as PairingAttempt,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $PairingAttemptResponseCopyWith on PairingAttemptResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPairingAttemptResponse.copyWith(...)` or like so:`instanceOfPairingAttemptResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PairingAttemptResponseCWProxy get copyWith =>
      _$PairingAttemptResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingAttemptResponse _$PairingAttemptResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PairingAttemptResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = PairingAttemptResponse(
    data: $checkedConvert(
      'data',
      (v) => PairingAttempt.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$PairingAttemptResponseToJson(
  PairingAttemptResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
