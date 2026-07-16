// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirm_birth_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ConfirmBirthResponseCWProxy {
  ConfirmBirthResponse data(ConfirmBirthResponseData data);

  ConfirmBirthResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConfirmBirthResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConfirmBirthResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ConfirmBirthResponse call({ConfirmBirthResponseData data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfConfirmBirthResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfConfirmBirthResponse.copyWith.fieldName(...)`
class _$ConfirmBirthResponseCWProxyImpl
    implements _$ConfirmBirthResponseCWProxy {
  const _$ConfirmBirthResponseCWProxyImpl(this._value);

  final ConfirmBirthResponse _value;

  @override
  ConfirmBirthResponse data(ConfirmBirthResponseData data) => this(data: data);

  @override
  ConfirmBirthResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConfirmBirthResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConfirmBirthResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ConfirmBirthResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return ConfirmBirthResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as ConfirmBirthResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $ConfirmBirthResponseCopyWith on ConfirmBirthResponse {
  /// Returns a callable class that can be used as follows: `instanceOfConfirmBirthResponse.copyWith(...)` or like so:`instanceOfConfirmBirthResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ConfirmBirthResponseCWProxy get copyWith =>
      _$ConfirmBirthResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfirmBirthResponse _$ConfirmBirthResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ConfirmBirthResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = ConfirmBirthResponse(
    data: $checkedConvert(
      'data',
      (v) => ConfirmBirthResponseData.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ConfirmBirthResponseToJson(
  ConfirmBirthResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
