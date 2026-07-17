// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounting_record.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AccountingRecordCWProxy {
  AccountingRecord id(String id);

  AccountingRecord categoryId(String? categoryId);

  AccountingRecord entryType(AccountingRecordEntryTypeEnum entryType);

  AccountingRecord amountCents(int amountCents);

  AccountingRecord currency(String currency);

  AccountingRecord title(String title);

  AccountingRecord notes(String? notes);

  AccountingRecord contactId(String? contactId);

  AccountingRecord occurredAt(DateTime occurredAt);

  AccountingRecord version(int version);

  AccountingRecord categoryName(String? categoryName);

  AccountingRecord contactName(String? contactName);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AccountingRecord(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AccountingRecord(...).copyWith(id: 12, name: "My name")
  /// ````
  AccountingRecord call({
    String id,
    String? categoryId,
    AccountingRecordEntryTypeEnum entryType,
    int amountCents,
    String currency,
    String title,
    String? notes,
    String? contactId,
    DateTime occurredAt,
    int version,
    String? categoryName,
    String? contactName,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAccountingRecord.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAccountingRecord.copyWith.fieldName(...)`
class _$AccountingRecordCWProxyImpl implements _$AccountingRecordCWProxy {
  const _$AccountingRecordCWProxyImpl(this._value);

  final AccountingRecord _value;

  @override
  AccountingRecord id(String id) => this(id: id);

  @override
  AccountingRecord categoryId(String? categoryId) =>
      this(categoryId: categoryId);

  @override
  AccountingRecord entryType(AccountingRecordEntryTypeEnum entryType) =>
      this(entryType: entryType);

  @override
  AccountingRecord amountCents(int amountCents) =>
      this(amountCents: amountCents);

  @override
  AccountingRecord currency(String currency) => this(currency: currency);

  @override
  AccountingRecord title(String title) => this(title: title);

  @override
  AccountingRecord notes(String? notes) => this(notes: notes);

  @override
  AccountingRecord contactId(String? contactId) => this(contactId: contactId);

  @override
  AccountingRecord occurredAt(DateTime occurredAt) =>
      this(occurredAt: occurredAt);

  @override
  AccountingRecord version(int version) => this(version: version);

  @override
  AccountingRecord categoryName(String? categoryName) =>
      this(categoryName: categoryName);

  @override
  AccountingRecord contactName(String? contactName) =>
      this(contactName: contactName);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AccountingRecord(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AccountingRecord(...).copyWith(id: 12, name: "My name")
  /// ````
  AccountingRecord call({
    Object? id = const $CopyWithPlaceholder(),
    Object? categoryId = const $CopyWithPlaceholder(),
    Object? entryType = const $CopyWithPlaceholder(),
    Object? amountCents = const $CopyWithPlaceholder(),
    Object? currency = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? contactId = const $CopyWithPlaceholder(),
    Object? occurredAt = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? categoryName = const $CopyWithPlaceholder(),
    Object? contactName = const $CopyWithPlaceholder(),
  }) {
    return AccountingRecord(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      categoryId: categoryId == const $CopyWithPlaceholder()
          ? _value.categoryId
          // ignore: cast_nullable_to_non_nullable
          : categoryId as String?,
      entryType: entryType == const $CopyWithPlaceholder()
          ? _value.entryType
          // ignore: cast_nullable_to_non_nullable
          : entryType as AccountingRecordEntryTypeEnum,
      amountCents: amountCents == const $CopyWithPlaceholder()
          ? _value.amountCents
          // ignore: cast_nullable_to_non_nullable
          : amountCents as int,
      currency: currency == const $CopyWithPlaceholder()
          ? _value.currency
          // ignore: cast_nullable_to_non_nullable
          : currency as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
      contactId: contactId == const $CopyWithPlaceholder()
          ? _value.contactId
          // ignore: cast_nullable_to_non_nullable
          : contactId as String?,
      occurredAt: occurredAt == const $CopyWithPlaceholder()
          ? _value.occurredAt
          // ignore: cast_nullable_to_non_nullable
          : occurredAt as DateTime,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
      categoryName: categoryName == const $CopyWithPlaceholder()
          ? _value.categoryName
          // ignore: cast_nullable_to_non_nullable
          : categoryName as String?,
      contactName: contactName == const $CopyWithPlaceholder()
          ? _value.contactName
          // ignore: cast_nullable_to_non_nullable
          : contactName as String?,
    );
  }
}

extension $AccountingRecordCopyWith on AccountingRecord {
  /// Returns a callable class that can be used as follows: `instanceOfAccountingRecord.copyWith(...)` or like so:`instanceOfAccountingRecord.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AccountingRecordCWProxy get copyWith => _$AccountingRecordCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountingRecord _$AccountingRecordFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'AccountingRecord',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'entry_type',
            'amount_cents',
            'currency',
            'title',
            'occurred_at',
            'version',
          ],
        );
        final val = AccountingRecord(
          id: $checkedConvert('id', (v) => v as String),
          categoryId: $checkedConvert('category_id', (v) => v as String?),
          entryType: $checkedConvert(
            'entry_type',
            (v) => $enumDecode(_$AccountingRecordEntryTypeEnumEnumMap, v),
          ),
          amountCents: $checkedConvert(
            'amount_cents',
            (v) => (v as num).toInt(),
          ),
          currency: $checkedConvert('currency', (v) => v as String),
          title: $checkedConvert('title', (v) => v as String),
          notes: $checkedConvert('notes', (v) => v as String?),
          contactId: $checkedConvert('contact_id', (v) => v as String?),
          occurredAt: $checkedConvert(
            'occurred_at',
            (v) => DateTime.parse(v as String),
          ),
          version: $checkedConvert('version', (v) => (v as num).toInt()),
          categoryName: $checkedConvert('category_name', (v) => v as String?),
          contactName: $checkedConvert('contact_name', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'categoryId': 'category_id',
        'entryType': 'entry_type',
        'amountCents': 'amount_cents',
        'contactId': 'contact_id',
        'occurredAt': 'occurred_at',
        'categoryName': 'category_name',
        'contactName': 'contact_name',
      },
    );

Map<String, dynamic> _$AccountingRecordToJson(AccountingRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category_id': ?instance.categoryId,
      'entry_type': _$AccountingRecordEntryTypeEnumEnumMap[instance.entryType]!,
      'amount_cents': instance.amountCents,
      'currency': instance.currency,
      'title': instance.title,
      'notes': ?instance.notes,
      'contact_id': ?instance.contactId,
      'occurred_at': instance.occurredAt.toIso8601String(),
      'version': instance.version,
      'category_name': ?instance.categoryName,
      'contact_name': ?instance.contactName,
    };

const _$AccountingRecordEntryTypeEnumEnumMap = {
  AccountingRecordEntryTypeEnum.income: 'income',
  AccountingRecordEntryTypeEnum.expense: 'expense',
};
