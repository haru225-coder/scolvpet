// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounting_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AccountingSummaryCWProxy {
  AccountingSummary from(DateTime from);

  AccountingSummary to(DateTime to);

  AccountingSummary incomeCents(int incomeCents);

  AccountingSummary expenseCents(int expenseCents);

  AccountingSummary netCents(int netCents);

  AccountingSummary currency(String currency);

  AccountingSummary recordCount(int recordCount);

  AccountingSummary byCategory(List<AccountingCategorySummary> byCategory);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AccountingSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AccountingSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  AccountingSummary call({
    DateTime from,
    DateTime to,
    int incomeCents,
    int expenseCents,
    int netCents,
    String currency,
    int recordCount,
    List<AccountingCategorySummary> byCategory,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAccountingSummary.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAccountingSummary.copyWith.fieldName(...)`
class _$AccountingSummaryCWProxyImpl implements _$AccountingSummaryCWProxy {
  const _$AccountingSummaryCWProxyImpl(this._value);

  final AccountingSummary _value;

  @override
  AccountingSummary from(DateTime from) => this(from: from);

  @override
  AccountingSummary to(DateTime to) => this(to: to);

  @override
  AccountingSummary incomeCents(int incomeCents) =>
      this(incomeCents: incomeCents);

  @override
  AccountingSummary expenseCents(int expenseCents) =>
      this(expenseCents: expenseCents);

  @override
  AccountingSummary netCents(int netCents) => this(netCents: netCents);

  @override
  AccountingSummary currency(String currency) => this(currency: currency);

  @override
  AccountingSummary recordCount(int recordCount) =>
      this(recordCount: recordCount);

  @override
  AccountingSummary byCategory(List<AccountingCategorySummary> byCategory) =>
      this(byCategory: byCategory);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AccountingSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AccountingSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  AccountingSummary call({
    Object? from = const $CopyWithPlaceholder(),
    Object? to = const $CopyWithPlaceholder(),
    Object? incomeCents = const $CopyWithPlaceholder(),
    Object? expenseCents = const $CopyWithPlaceholder(),
    Object? netCents = const $CopyWithPlaceholder(),
    Object? currency = const $CopyWithPlaceholder(),
    Object? recordCount = const $CopyWithPlaceholder(),
    Object? byCategory = const $CopyWithPlaceholder(),
  }) {
    return AccountingSummary(
      from: from == const $CopyWithPlaceholder()
          ? _value.from
          // ignore: cast_nullable_to_non_nullable
          : from as DateTime,
      to: to == const $CopyWithPlaceholder()
          ? _value.to
          // ignore: cast_nullable_to_non_nullable
          : to as DateTime,
      incomeCents: incomeCents == const $CopyWithPlaceholder()
          ? _value.incomeCents
          // ignore: cast_nullable_to_non_nullable
          : incomeCents as int,
      expenseCents: expenseCents == const $CopyWithPlaceholder()
          ? _value.expenseCents
          // ignore: cast_nullable_to_non_nullable
          : expenseCents as int,
      netCents: netCents == const $CopyWithPlaceholder()
          ? _value.netCents
          // ignore: cast_nullable_to_non_nullable
          : netCents as int,
      currency: currency == const $CopyWithPlaceholder()
          ? _value.currency
          // ignore: cast_nullable_to_non_nullable
          : currency as String,
      recordCount: recordCount == const $CopyWithPlaceholder()
          ? _value.recordCount
          // ignore: cast_nullable_to_non_nullable
          : recordCount as int,
      byCategory: byCategory == const $CopyWithPlaceholder()
          ? _value.byCategory
          // ignore: cast_nullable_to_non_nullable
          : byCategory as List<AccountingCategorySummary>,
    );
  }
}

extension $AccountingSummaryCopyWith on AccountingSummary {
  /// Returns a callable class that can be used as follows: `instanceOfAccountingSummary.copyWith(...)` or like so:`instanceOfAccountingSummary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AccountingSummaryCWProxy get copyWith =>
      _$AccountingSummaryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountingSummary _$AccountingSummaryFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AccountingSummary',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'from',
        'to',
        'income_cents',
        'expense_cents',
        'net_cents',
        'currency',
        'record_count',
        'by_category',
      ],
    );
    final val = AccountingSummary(
      from: $checkedConvert('from', (v) => DateTime.parse(v as String)),
      to: $checkedConvert('to', (v) => DateTime.parse(v as String)),
      incomeCents: $checkedConvert('income_cents', (v) => (v as num).toInt()),
      expenseCents: $checkedConvert('expense_cents', (v) => (v as num).toInt()),
      netCents: $checkedConvert('net_cents', (v) => (v as num).toInt()),
      currency: $checkedConvert('currency', (v) => v as String),
      recordCount: $checkedConvert('record_count', (v) => (v as num).toInt()),
      byCategory: $checkedConvert(
        'by_category',
        (v) => (v as List<dynamic>)
            .map(
              (e) =>
                  AccountingCategorySummary.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'incomeCents': 'income_cents',
    'expenseCents': 'expense_cents',
    'netCents': 'net_cents',
    'recordCount': 'record_count',
    'byCategory': 'by_category',
  },
);

Map<String, dynamic> _$AccountingSummaryToJson(AccountingSummary instance) =>
    <String, dynamic>{
      'from': instance.from.toIso8601String(),
      'to': instance.to.toIso8601String(),
      'income_cents': instance.incomeCents,
      'expense_cents': instance.expenseCents,
      'net_cents': instance.netCents,
      'currency': instance.currency,
      'record_count': instance.recordCount,
      'by_category': instance.byCategory.map((e) => e.toJson()).toList(),
    };
