// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounting_record_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AccountingRecordListResponseCWProxy {
  AccountingRecordListResponse data(List<AccountingRecord> data);

  AccountingRecordListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AccountingRecordListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AccountingRecordListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AccountingRecordListResponse call({
    List<AccountingRecord> data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAccountingRecordListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAccountingRecordListResponse.copyWith.fieldName(...)`
class _$AccountingRecordListResponseCWProxyImpl
    implements _$AccountingRecordListResponseCWProxy {
  const _$AccountingRecordListResponseCWProxyImpl(this._value);

  final AccountingRecordListResponse _value;

  @override
  AccountingRecordListResponse data(List<AccountingRecord> data) =>
      this(data: data);

  @override
  AccountingRecordListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AccountingRecordListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AccountingRecordListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AccountingRecordListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return AccountingRecordListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<AccountingRecord>,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $AccountingRecordListResponseCopyWith
    on AccountingRecordListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfAccountingRecordListResponse.copyWith(...)` or like so:`instanceOfAccountingRecordListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AccountingRecordListResponseCWProxy get copyWith =>
      _$AccountingRecordListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountingRecordListResponse _$AccountingRecordListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AccountingRecordListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = AccountingRecordListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => AccountingRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$AccountingRecordListResponseToJson(
  AccountingRecordListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'meta': instance.meta.toJson(),
};
