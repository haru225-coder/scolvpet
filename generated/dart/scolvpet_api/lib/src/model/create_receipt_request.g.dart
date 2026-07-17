// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_receipt_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateReceiptRequestCWProxy {
  CreateReceiptRequest templateId(String templateId);

  CreateReceiptRequest contactId(String? contactId);

  CreateReceiptRequest title(String? title);

  CreateReceiptRequest amountCents(int amountCents);

  CreateReceiptRequest currency(String? currency);

  CreateReceiptRequest notes(String? notes);

  CreateReceiptRequest contactName(String? contactName);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateReceiptRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateReceiptRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateReceiptRequest call({
    String templateId,
    String? contactId,
    String? title,
    int amountCents,
    String? currency,
    String? notes,
    String? contactName,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateReceiptRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateReceiptRequest.copyWith.fieldName(...)`
class _$CreateReceiptRequestCWProxyImpl
    implements _$CreateReceiptRequestCWProxy {
  const _$CreateReceiptRequestCWProxyImpl(this._value);

  final CreateReceiptRequest _value;

  @override
  CreateReceiptRequest templateId(String templateId) =>
      this(templateId: templateId);

  @override
  CreateReceiptRequest contactId(String? contactId) =>
      this(contactId: contactId);

  @override
  CreateReceiptRequest title(String? title) => this(title: title);

  @override
  CreateReceiptRequest amountCents(int amountCents) =>
      this(amountCents: amountCents);

  @override
  CreateReceiptRequest currency(String? currency) => this(currency: currency);

  @override
  CreateReceiptRequest notes(String? notes) => this(notes: notes);

  @override
  CreateReceiptRequest contactName(String? contactName) =>
      this(contactName: contactName);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateReceiptRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateReceiptRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateReceiptRequest call({
    Object? templateId = const $CopyWithPlaceholder(),
    Object? contactId = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? amountCents = const $CopyWithPlaceholder(),
    Object? currency = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? contactName = const $CopyWithPlaceholder(),
  }) {
    return CreateReceiptRequest(
      templateId: templateId == const $CopyWithPlaceholder()
          ? _value.templateId
          // ignore: cast_nullable_to_non_nullable
          : templateId as String,
      contactId: contactId == const $CopyWithPlaceholder()
          ? _value.contactId
          // ignore: cast_nullable_to_non_nullable
          : contactId as String?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      amountCents: amountCents == const $CopyWithPlaceholder()
          ? _value.amountCents
          // ignore: cast_nullable_to_non_nullable
          : amountCents as int,
      currency: currency == const $CopyWithPlaceholder()
          ? _value.currency
          // ignore: cast_nullable_to_non_nullable
          : currency as String?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
      contactName: contactName == const $CopyWithPlaceholder()
          ? _value.contactName
          // ignore: cast_nullable_to_non_nullable
          : contactName as String?,
    );
  }
}

extension $CreateReceiptRequestCopyWith on CreateReceiptRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateReceiptRequest.copyWith(...)` or like so:`instanceOfCreateReceiptRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateReceiptRequestCWProxy get copyWith =>
      _$CreateReceiptRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateReceiptRequest _$CreateReceiptRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CreateReceiptRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['template_id', 'amount_cents']);
    final val = CreateReceiptRequest(
      templateId: $checkedConvert('template_id', (v) => v as String),
      contactId: $checkedConvert('contact_id', (v) => v as String?),
      title: $checkedConvert('title', (v) => v as String?),
      amountCents: $checkedConvert('amount_cents', (v) => (v as num).toInt()),
      currency: $checkedConvert('currency', (v) => v as String? ?? 'CNY'),
      notes: $checkedConvert('notes', (v) => v as String?),
      contactName: $checkedConvert('contact_name', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'templateId': 'template_id',
    'contactId': 'contact_id',
    'amountCents': 'amount_cents',
    'contactName': 'contact_name',
  },
);

Map<String, dynamic> _$CreateReceiptRequestToJson(
  CreateReceiptRequest instance,
) => <String, dynamic>{
  'template_id': instance.templateId,
  'contact_id': ?instance.contactId,
  'title': ?instance.title,
  'amount_cents': instance.amountCents,
  'currency': ?instance.currency,
  'notes': ?instance.notes,
  'contact_name': ?instance.contactName,
};
