// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounting_summary_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AccountingSummaryResponseCWProxy {
  AccountingSummaryResponse data(AccountingSummary data);

  AccountingSummaryResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AccountingSummaryResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AccountingSummaryResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AccountingSummaryResponse call({AccountingSummary data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAccountingSummaryResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAccountingSummaryResponse.copyWith.fieldName(...)`
class _$AccountingSummaryResponseCWProxyImpl
    implements _$AccountingSummaryResponseCWProxy {
  const _$AccountingSummaryResponseCWProxyImpl(this._value);

  final AccountingSummaryResponse _value;

  @override
  AccountingSummaryResponse data(AccountingSummary data) => this(data: data);

  @override
  AccountingSummaryResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AccountingSummaryResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AccountingSummaryResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AccountingSummaryResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return AccountingSummaryResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as AccountingSummary,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $AccountingSummaryResponseCopyWith on AccountingSummaryResponse {
  /// Returns a callable class that can be used as follows: `instanceOfAccountingSummaryResponse.copyWith(...)` or like so:`instanceOfAccountingSummaryResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AccountingSummaryResponseCWProxy get copyWith =>
      _$AccountingSummaryResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountingSummaryResponse _$AccountingSummaryResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AccountingSummaryResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = AccountingSummaryResponse(
    data: $checkedConvert(
      'data',
      (v) => AccountingSummary.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$AccountingSummaryResponseToJson(
  AccountingSummaryResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
