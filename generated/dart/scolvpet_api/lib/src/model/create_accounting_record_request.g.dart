// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_accounting_record_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateAccountingRecordRequestCWProxy {
  CreateAccountingRecordRequest categoryId(String? categoryId);

  CreateAccountingRecordRequest entryType(
    CreateAccountingRecordRequestEntryTypeEnum entryType,
  );

  CreateAccountingRecordRequest amountCents(int amountCents);

  CreateAccountingRecordRequest currency(String? currency);

  CreateAccountingRecordRequest title(String title);

  CreateAccountingRecordRequest notes(String? notes);

  CreateAccountingRecordRequest contactId(String? contactId);

  CreateAccountingRecordRequest occurredAt(DateTime? occurredAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateAccountingRecordRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateAccountingRecordRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateAccountingRecordRequest call({
    String? categoryId,
    CreateAccountingRecordRequestEntryTypeEnum entryType,
    int amountCents,
    String? currency,
    String title,
    String? notes,
    String? contactId,
    DateTime? occurredAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateAccountingRecordRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateAccountingRecordRequest.copyWith.fieldName(...)`
class _$CreateAccountingRecordRequestCWProxyImpl
    implements _$CreateAccountingRecordRequestCWProxy {
  const _$CreateAccountingRecordRequestCWProxyImpl(this._value);

  final CreateAccountingRecordRequest _value;

  @override
  CreateAccountingRecordRequest categoryId(String? categoryId) =>
      this(categoryId: categoryId);

  @override
  CreateAccountingRecordRequest entryType(
    CreateAccountingRecordRequestEntryTypeEnum entryType,
  ) => this(entryType: entryType);

  @override
  CreateAccountingRecordRequest amountCents(int amountCents) =>
      this(amountCents: amountCents);

  @override
  CreateAccountingRecordRequest currency(String? currency) =>
      this(currency: currency);

  @override
  CreateAccountingRecordRequest title(String title) => this(title: title);

  @override
  CreateAccountingRecordRequest notes(String? notes) => this(notes: notes);

  @override
  CreateAccountingRecordRequest contactId(String? contactId) =>
      this(contactId: contactId);

  @override
  CreateAccountingRecordRequest occurredAt(DateTime? occurredAt) =>
      this(occurredAt: occurredAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateAccountingRecordRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateAccountingRecordRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateAccountingRecordRequest call({
    Object? categoryId = const $CopyWithPlaceholder(),
    Object? entryType = const $CopyWithPlaceholder(),
    Object? amountCents = const $CopyWithPlaceholder(),
    Object? currency = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? contactId = const $CopyWithPlaceholder(),
    Object? occurredAt = const $CopyWithPlaceholder(),
  }) {
    return CreateAccountingRecordRequest(
      categoryId: categoryId == const $CopyWithPlaceholder()
          ? _value.categoryId
          // ignore: cast_nullable_to_non_nullable
          : categoryId as String?,
      entryType: entryType == const $CopyWithPlaceholder()
          ? _value.entryType
          // ignore: cast_nullable_to_non_nullable
          : entryType as CreateAccountingRecordRequestEntryTypeEnum,
      amountCents: amountCents == const $CopyWithPlaceholder()
          ? _value.amountCents
          // ignore: cast_nullable_to_non_nullable
          : amountCents as int,
      currency: currency == const $CopyWithPlaceholder()
          ? _value.currency
          // ignore: cast_nullable_to_non_nullable
          : currency as String?,
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
          : occurredAt as DateTime?,
    );
  }
}

extension $CreateAccountingRecordRequestCopyWith
    on CreateAccountingRecordRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateAccountingRecordRequest.copyWith(...)` or like so:`instanceOfCreateAccountingRecordRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateAccountingRecordRequestCWProxy get copyWith =>
      _$CreateAccountingRecordRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateAccountingRecordRequest _$CreateAccountingRecordRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CreateAccountingRecordRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['entry_type', 'amount_cents', 'title'],
    );
    final val = CreateAccountingRecordRequest(
      categoryId: $checkedConvert('category_id', (v) => v as String?),
      entryType: $checkedConvert(
        'entry_type',
        (v) =>
            $enumDecode(_$CreateAccountingRecordRequestEntryTypeEnumEnumMap, v),
      ),
      amountCents: $checkedConvert('amount_cents', (v) => (v as num).toInt()),
      currency: $checkedConvert('currency', (v) => v as String? ?? 'CNY'),
      title: $checkedConvert('title', (v) => v as String),
      notes: $checkedConvert('notes', (v) => v as String?),
      contactId: $checkedConvert('contact_id', (v) => v as String?),
      occurredAt: $checkedConvert(
        'occurred_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'categoryId': 'category_id',
    'entryType': 'entry_type',
    'amountCents': 'amount_cents',
    'contactId': 'contact_id',
    'occurredAt': 'occurred_at',
  },
);

Map<String, dynamic> _$CreateAccountingRecordRequestToJson(
  CreateAccountingRecordRequest instance,
) => <String, dynamic>{
  'category_id': ?instance.categoryId,
  'entry_type':
      _$CreateAccountingRecordRequestEntryTypeEnumEnumMap[instance.entryType]!,
  'amount_cents': instance.amountCents,
  'currency': ?instance.currency,
  'title': instance.title,
  'notes': ?instance.notes,
  'contact_id': ?instance.contactId,
  'occurred_at': ?instance.occurredAt?.toIso8601String(),
};

const _$CreateAccountingRecordRequestEntryTypeEnumEnumMap = {
  CreateAccountingRecordRequestEntryTypeEnum.income: 'income',
  CreateAccountingRecordRequestEntryTypeEnum.expense: 'expense',
};
