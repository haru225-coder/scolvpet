// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounting_category_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AccountingCategorySummaryCWProxy {
  AccountingCategorySummary categoryId(String? categoryId);

  AccountingCategorySummary categoryName(String categoryName);

  AccountingCategorySummary entryType(
    AccountingCategorySummaryEntryTypeEnum entryType,
  );

  AccountingCategorySummary amountCents(int amountCents);

  AccountingCategorySummary count(int count);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AccountingCategorySummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AccountingCategorySummary(...).copyWith(id: 12, name: "My name")
  /// ````
  AccountingCategorySummary call({
    String? categoryId,
    String categoryName,
    AccountingCategorySummaryEntryTypeEnum entryType,
    int amountCents,
    int count,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAccountingCategorySummary.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAccountingCategorySummary.copyWith.fieldName(...)`
class _$AccountingCategorySummaryCWProxyImpl
    implements _$AccountingCategorySummaryCWProxy {
  const _$AccountingCategorySummaryCWProxyImpl(this._value);

  final AccountingCategorySummary _value;

  @override
  AccountingCategorySummary categoryId(String? categoryId) =>
      this(categoryId: categoryId);

  @override
  AccountingCategorySummary categoryName(String categoryName) =>
      this(categoryName: categoryName);

  @override
  AccountingCategorySummary entryType(
    AccountingCategorySummaryEntryTypeEnum entryType,
  ) => this(entryType: entryType);

  @override
  AccountingCategorySummary amountCents(int amountCents) =>
      this(amountCents: amountCents);

  @override
  AccountingCategorySummary count(int count) => this(count: count);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AccountingCategorySummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AccountingCategorySummary(...).copyWith(id: 12, name: "My name")
  /// ````
  AccountingCategorySummary call({
    Object? categoryId = const $CopyWithPlaceholder(),
    Object? categoryName = const $CopyWithPlaceholder(),
    Object? entryType = const $CopyWithPlaceholder(),
    Object? amountCents = const $CopyWithPlaceholder(),
    Object? count = const $CopyWithPlaceholder(),
  }) {
    return AccountingCategorySummary(
      categoryId: categoryId == const $CopyWithPlaceholder()
          ? _value.categoryId
          // ignore: cast_nullable_to_non_nullable
          : categoryId as String?,
      categoryName: categoryName == const $CopyWithPlaceholder()
          ? _value.categoryName
          // ignore: cast_nullable_to_non_nullable
          : categoryName as String,
      entryType: entryType == const $CopyWithPlaceholder()
          ? _value.entryType
          // ignore: cast_nullable_to_non_nullable
          : entryType as AccountingCategorySummaryEntryTypeEnum,
      amountCents: amountCents == const $CopyWithPlaceholder()
          ? _value.amountCents
          // ignore: cast_nullable_to_non_nullable
          : amountCents as int,
      count: count == const $CopyWithPlaceholder()
          ? _value.count
          // ignore: cast_nullable_to_non_nullable
          : count as int,
    );
  }
}

extension $AccountingCategorySummaryCopyWith on AccountingCategorySummary {
  /// Returns a callable class that can be used as follows: `instanceOfAccountingCategorySummary.copyWith(...)` or like so:`instanceOfAccountingCategorySummary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AccountingCategorySummaryCWProxy get copyWith =>
      _$AccountingCategorySummaryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountingCategorySummary _$AccountingCategorySummaryFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AccountingCategorySummary',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'category_name',
        'entry_type',
        'amount_cents',
        'count',
      ],
    );
    final val = AccountingCategorySummary(
      categoryId: $checkedConvert('category_id', (v) => v as String?),
      categoryName: $checkedConvert('category_name', (v) => v as String),
      entryType: $checkedConvert(
        'entry_type',
        (v) => $enumDecode(_$AccountingCategorySummaryEntryTypeEnumEnumMap, v),
      ),
      amountCents: $checkedConvert('amount_cents', (v) => (v as num).toInt()),
      count: $checkedConvert('count', (v) => (v as num).toInt()),
    );
    return val;
  },
  fieldKeyMap: const {
    'categoryId': 'category_id',
    'categoryName': 'category_name',
    'entryType': 'entry_type',
    'amountCents': 'amount_cents',
  },
);

Map<String, dynamic> _$AccountingCategorySummaryToJson(
  AccountingCategorySummary instance,
) => <String, dynamic>{
  'category_id': ?instance.categoryId,
  'category_name': instance.categoryName,
  'entry_type':
      _$AccountingCategorySummaryEntryTypeEnumEnumMap[instance.entryType]!,
  'amount_cents': instance.amountCents,
  'count': instance.count,
};

const _$AccountingCategorySummaryEntryTypeEnumEnumMap = {
  AccountingCategorySummaryEntryTypeEnum.income: 'income',
  AccountingCategorySummaryEntryTypeEnum.expense: 'expense',
};
