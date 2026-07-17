// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentCWProxy {
  Document id(String id);

  Document templateId(String templateId);

  Document kind(DocumentKindEnum kind);

  Document contactId(String? contactId);

  Document handoverId(String? handoverId);

  Document title(String title);

  Document bodyFilled(String bodyFilled);

  Document amountCents(int? amountCents);

  Document currency(String currency);

  Document status(DocumentStatusEnum status);

  Document issuedAt(DateTime? issuedAt);

  Document notes(String? notes);

  Document version(int version);

  Document contactName(String? contactName);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Document(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Document(...).copyWith(id: 12, name: "My name")
  /// ````
  Document call({
    String id,
    String templateId,
    DocumentKindEnum kind,
    String? contactId,
    String? handoverId,
    String title,
    String bodyFilled,
    int? amountCents,
    String currency,
    DocumentStatusEnum status,
    DateTime? issuedAt,
    String? notes,
    int version,
    String? contactName,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocument.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocument.copyWith.fieldName(...)`
class _$DocumentCWProxyImpl implements _$DocumentCWProxy {
  const _$DocumentCWProxyImpl(this._value);

  final Document _value;

  @override
  Document id(String id) => this(id: id);

  @override
  Document templateId(String templateId) => this(templateId: templateId);

  @override
  Document kind(DocumentKindEnum kind) => this(kind: kind);

  @override
  Document contactId(String? contactId) => this(contactId: contactId);

  @override
  Document handoverId(String? handoverId) => this(handoverId: handoverId);

  @override
  Document title(String title) => this(title: title);

  @override
  Document bodyFilled(String bodyFilled) => this(bodyFilled: bodyFilled);

  @override
  Document amountCents(int? amountCents) => this(amountCents: amountCents);

  @override
  Document currency(String currency) => this(currency: currency);

  @override
  Document status(DocumentStatusEnum status) => this(status: status);

  @override
  Document issuedAt(DateTime? issuedAt) => this(issuedAt: issuedAt);

  @override
  Document notes(String? notes) => this(notes: notes);

  @override
  Document version(int version) => this(version: version);

  @override
  Document contactName(String? contactName) => this(contactName: contactName);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Document(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Document(...).copyWith(id: 12, name: "My name")
  /// ````
  Document call({
    Object? id = const $CopyWithPlaceholder(),
    Object? templateId = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? contactId = const $CopyWithPlaceholder(),
    Object? handoverId = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? bodyFilled = const $CopyWithPlaceholder(),
    Object? amountCents = const $CopyWithPlaceholder(),
    Object? currency = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? issuedAt = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? contactName = const $CopyWithPlaceholder(),
  }) {
    return Document(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      templateId: templateId == const $CopyWithPlaceholder()
          ? _value.templateId
          // ignore: cast_nullable_to_non_nullable
          : templateId as String,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as DocumentKindEnum,
      contactId: contactId == const $CopyWithPlaceholder()
          ? _value.contactId
          // ignore: cast_nullable_to_non_nullable
          : contactId as String?,
      handoverId: handoverId == const $CopyWithPlaceholder()
          ? _value.handoverId
          // ignore: cast_nullable_to_non_nullable
          : handoverId as String?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      bodyFilled: bodyFilled == const $CopyWithPlaceholder()
          ? _value.bodyFilled
          // ignore: cast_nullable_to_non_nullable
          : bodyFilled as String,
      amountCents: amountCents == const $CopyWithPlaceholder()
          ? _value.amountCents
          // ignore: cast_nullable_to_non_nullable
          : amountCents as int?,
      currency: currency == const $CopyWithPlaceholder()
          ? _value.currency
          // ignore: cast_nullable_to_non_nullable
          : currency as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as DocumentStatusEnum,
      issuedAt: issuedAt == const $CopyWithPlaceholder()
          ? _value.issuedAt
          // ignore: cast_nullable_to_non_nullable
          : issuedAt as DateTime?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
      contactName: contactName == const $CopyWithPlaceholder()
          ? _value.contactName
          // ignore: cast_nullable_to_non_nullable
          : contactName as String?,
    );
  }
}

extension $DocumentCopyWith on Document {
  /// Returns a callable class that can be used as follows: `instanceOfDocument.copyWith(...)` or like so:`instanceOfDocument.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentCWProxy get copyWith => _$DocumentCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Document _$DocumentFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Document',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'template_id',
        'kind',
        'title',
        'body_filled',
        'currency',
        'status',
        'version',
      ],
    );
    final val = Document(
      id: $checkedConvert('id', (v) => v as String),
      templateId: $checkedConvert('template_id', (v) => v as String),
      kind: $checkedConvert(
        'kind',
        (v) => $enumDecode(_$DocumentKindEnumEnumMap, v),
      ),
      contactId: $checkedConvert('contact_id', (v) => v as String?),
      handoverId: $checkedConvert('handover_id', (v) => v as String?),
      title: $checkedConvert('title', (v) => v as String),
      bodyFilled: $checkedConvert('body_filled', (v) => v as String),
      amountCents: $checkedConvert('amount_cents', (v) => (v as num?)?.toInt()),
      currency: $checkedConvert('currency', (v) => v as String),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$DocumentStatusEnumEnumMap, v),
      ),
      issuedAt: $checkedConvert(
        'issued_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      notes: $checkedConvert('notes', (v) => v as String?),
      version: $checkedConvert('version', (v) => (v as num).toInt()),
      contactName: $checkedConvert('contact_name', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'templateId': 'template_id',
    'contactId': 'contact_id',
    'handoverId': 'handover_id',
    'bodyFilled': 'body_filled',
    'amountCents': 'amount_cents',
    'issuedAt': 'issued_at',
    'contactName': 'contact_name',
  },
);

Map<String, dynamic> _$DocumentToJson(Document instance) => <String, dynamic>{
  'id': instance.id,
  'template_id': instance.templateId,
  'kind': _$DocumentKindEnumEnumMap[instance.kind]!,
  'contact_id': ?instance.contactId,
  'handover_id': ?instance.handoverId,
  'title': instance.title,
  'body_filled': instance.bodyFilled,
  'amount_cents': ?instance.amountCents,
  'currency': instance.currency,
  'status': _$DocumentStatusEnumEnumMap[instance.status]!,
  'issued_at': ?instance.issuedAt?.toIso8601String(),
  'notes': ?instance.notes,
  'version': instance.version,
  'contact_name': ?instance.contactName,
};

const _$DocumentKindEnumEnumMap = {
  DocumentKindEnum.contract: 'contract',
  DocumentKindEnum.receipt: 'receipt',
};

const _$DocumentStatusEnumEnumMap = {
  DocumentStatusEnum.draft: 'draft',
  DocumentStatusEnum.issued: 'issued',
  DocumentStatusEnum.archived: 'archived',
};
