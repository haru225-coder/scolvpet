// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounting_record_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AccountingRecordResponseCWProxy {
  AccountingRecordResponse data(AccountingRecord data);

  AccountingRecordResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AccountingRecordResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AccountingRecordResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AccountingRecordResponse call({AccountingRecord data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAccountingRecordResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAccountingRecordResponse.copyWith.fieldName(...)`
class _$AccountingRecordResponseCWProxyImpl
    implements _$AccountingRecordResponseCWProxy {
  const _$AccountingRecordResponseCWProxyImpl(this._value);

  final AccountingRecordResponse _value;

  @override
  AccountingRecordResponse data(AccountingRecord data) => this(data: data);

  @override
  AccountingRecordResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AccountingRecordResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AccountingRecordResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AccountingRecordResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return AccountingRecordResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as AccountingRecord,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $AccountingRecordResponseCopyWith on AccountingRecordResponse {
  /// Returns a callable class that can be used as follows: `instanceOfAccountingRecordResponse.copyWith(...)` or like so:`instanceOfAccountingRecordResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AccountingRecordResponseCWProxy get copyWith =>
      _$AccountingRecordResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountingRecordResponse _$AccountingRecordResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AccountingRecordResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = AccountingRecordResponse(
    data: $checkedConvert(
      'data',
      (v) => AccountingRecord.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$AccountingRecordResponseToJson(
  AccountingRecordResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
