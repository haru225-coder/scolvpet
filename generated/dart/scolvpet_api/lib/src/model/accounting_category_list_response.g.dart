// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounting_category_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AccountingCategoryListResponseCWProxy {
  AccountingCategoryListResponse data(List<AccountingCategory> data);

  AccountingCategoryListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AccountingCategoryListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AccountingCategoryListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AccountingCategoryListResponse call({
    List<AccountingCategory> data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAccountingCategoryListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAccountingCategoryListResponse.copyWith.fieldName(...)`
class _$AccountingCategoryListResponseCWProxyImpl
    implements _$AccountingCategoryListResponseCWProxy {
  const _$AccountingCategoryListResponseCWProxyImpl(this._value);

  final AccountingCategoryListResponse _value;

  @override
  AccountingCategoryListResponse data(List<AccountingCategory> data) =>
      this(data: data);

  @override
  AccountingCategoryListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AccountingCategoryListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AccountingCategoryListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AccountingCategoryListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return AccountingCategoryListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<AccountingCategory>,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $AccountingCategoryListResponseCopyWith
    on AccountingCategoryListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfAccountingCategoryListResponse.copyWith(...)` or like so:`instanceOfAccountingCategoryListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AccountingCategoryListResponseCWProxy get copyWith =>
      _$AccountingCategoryListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountingCategoryListResponse _$AccountingCategoryListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AccountingCategoryListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = AccountingCategoryListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => AccountingCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$AccountingCategoryListResponseToJson(
  AccountingCategoryListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'meta': instance.meta.toJson(),
};
