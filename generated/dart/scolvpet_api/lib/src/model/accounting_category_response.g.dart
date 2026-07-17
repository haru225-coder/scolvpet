// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounting_category_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AccountingCategoryResponseCWProxy {
  AccountingCategoryResponse data(AccountingCategory data);

  AccountingCategoryResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AccountingCategoryResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AccountingCategoryResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AccountingCategoryResponse call({AccountingCategory data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAccountingCategoryResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAccountingCategoryResponse.copyWith.fieldName(...)`
class _$AccountingCategoryResponseCWProxyImpl
    implements _$AccountingCategoryResponseCWProxy {
  const _$AccountingCategoryResponseCWProxyImpl(this._value);

  final AccountingCategoryResponse _value;

  @override
  AccountingCategoryResponse data(AccountingCategory data) => this(data: data);

  @override
  AccountingCategoryResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AccountingCategoryResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AccountingCategoryResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AccountingCategoryResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return AccountingCategoryResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as AccountingCategory,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $AccountingCategoryResponseCopyWith on AccountingCategoryResponse {
  /// Returns a callable class that can be used as follows: `instanceOfAccountingCategoryResponse.copyWith(...)` or like so:`instanceOfAccountingCategoryResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AccountingCategoryResponseCWProxy get copyWith =>
      _$AccountingCategoryResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountingCategoryResponse _$AccountingCategoryResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AccountingCategoryResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = AccountingCategoryResponse(
    data: $checkedConvert(
      'data',
      (v) => AccountingCategory.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$AccountingCategoryResponseToJson(
  AccountingCategoryResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
