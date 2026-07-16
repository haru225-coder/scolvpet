// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_account_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CurrentAccountResponseCWProxy {
  CurrentAccountResponse data(CurrentAccountResponseData data);

  CurrentAccountResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CurrentAccountResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CurrentAccountResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CurrentAccountResponse call({
    CurrentAccountResponseData data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCurrentAccountResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCurrentAccountResponse.copyWith.fieldName(...)`
class _$CurrentAccountResponseCWProxyImpl
    implements _$CurrentAccountResponseCWProxy {
  const _$CurrentAccountResponseCWProxyImpl(this._value);

  final CurrentAccountResponse _value;

  @override
  CurrentAccountResponse data(CurrentAccountResponseData data) =>
      this(data: data);

  @override
  CurrentAccountResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CurrentAccountResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CurrentAccountResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CurrentAccountResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return CurrentAccountResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as CurrentAccountResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $CurrentAccountResponseCopyWith on CurrentAccountResponse {
  /// Returns a callable class that can be used as follows: `instanceOfCurrentAccountResponse.copyWith(...)` or like so:`instanceOfCurrentAccountResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CurrentAccountResponseCWProxy get copyWith =>
      _$CurrentAccountResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrentAccountResponse _$CurrentAccountResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CurrentAccountResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = CurrentAccountResponse(
    data: $checkedConvert(
      'data',
      (v) => CurrentAccountResponseData.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$CurrentAccountResponseToJson(
  CurrentAccountResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
