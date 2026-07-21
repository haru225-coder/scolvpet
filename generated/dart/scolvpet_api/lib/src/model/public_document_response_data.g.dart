// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_document_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublicDocumentResponseDataCWProxy {
  PublicDocumentResponseData kind(PublicDocumentResponseDataKindEnum kind);

  PublicDocumentResponseData kindLabel(String? kindLabel);

  PublicDocumentResponseData title(String title);

  PublicDocumentResponseData bodyFilled(String bodyFilled);

  PublicDocumentResponseData contactName(String? contactName);

  PublicDocumentResponseData currency(String? currency);

  PublicDocumentResponseData amountCents(int? amountCents);

  PublicDocumentResponseData amountLabel(String? amountLabel);

  PublicDocumentResponseData issuedAt(DateTime? issuedAt);

  PublicDocumentResponseData status(
    PublicDocumentResponseDataStatusEnum status,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicDocumentResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicDocumentResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicDocumentResponseData call({
    PublicDocumentResponseDataKindEnum kind,
    String? kindLabel,
    String title,
    String bodyFilled,
    String? contactName,
    String? currency,
    int? amountCents,
    String? amountLabel,
    DateTime? issuedAt,
    PublicDocumentResponseDataStatusEnum status,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublicDocumentResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublicDocumentResponseData.copyWith.fieldName(...)`
class _$PublicDocumentResponseDataCWProxyImpl
    implements _$PublicDocumentResponseDataCWProxy {
  const _$PublicDocumentResponseDataCWProxyImpl(this._value);

  final PublicDocumentResponseData _value;

  @override
  PublicDocumentResponseData kind(PublicDocumentResponseDataKindEnum kind) =>
      this(kind: kind);

  @override
  PublicDocumentResponseData kindLabel(String? kindLabel) =>
      this(kindLabel: kindLabel);

  @override
  PublicDocumentResponseData title(String title) => this(title: title);

  @override
  PublicDocumentResponseData bodyFilled(String bodyFilled) =>
      this(bodyFilled: bodyFilled);

  @override
  PublicDocumentResponseData contactName(String? contactName) =>
      this(contactName: contactName);

  @override
  PublicDocumentResponseData currency(String? currency) =>
      this(currency: currency);

  @override
  PublicDocumentResponseData amountCents(int? amountCents) =>
      this(amountCents: amountCents);

  @override
  PublicDocumentResponseData amountLabel(String? amountLabel) =>
      this(amountLabel: amountLabel);

  @override
  PublicDocumentResponseData issuedAt(DateTime? issuedAt) =>
      this(issuedAt: issuedAt);

  @override
  PublicDocumentResponseData status(
    PublicDocumentResponseDataStatusEnum status,
  ) => this(status: status);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicDocumentResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicDocumentResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicDocumentResponseData call({
    Object? kind = const $CopyWithPlaceholder(),
    Object? kindLabel = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? bodyFilled = const $CopyWithPlaceholder(),
    Object? contactName = const $CopyWithPlaceholder(),
    Object? currency = const $CopyWithPlaceholder(),
    Object? amountCents = const $CopyWithPlaceholder(),
    Object? amountLabel = const $CopyWithPlaceholder(),
    Object? issuedAt = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
  }) {
    return PublicDocumentResponseData(
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as PublicDocumentResponseDataKindEnum,
      kindLabel: kindLabel == const $CopyWithPlaceholder()
          ? _value.kindLabel
          // ignore: cast_nullable_to_non_nullable
          : kindLabel as String?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      bodyFilled: bodyFilled == const $CopyWithPlaceholder()
          ? _value.bodyFilled
          // ignore: cast_nullable_to_non_nullable
          : bodyFilled as String,
      contactName: contactName == const $CopyWithPlaceholder()
          ? _value.contactName
          // ignore: cast_nullable_to_non_nullable
          : contactName as String?,
      currency: currency == const $CopyWithPlaceholder()
          ? _value.currency
          // ignore: cast_nullable_to_non_nullable
          : currency as String?,
      amountCents: amountCents == const $CopyWithPlaceholder()
          ? _value.amountCents
          // ignore: cast_nullable_to_non_nullable
          : amountCents as int?,
      amountLabel: amountLabel == const $CopyWithPlaceholder()
          ? _value.amountLabel
          // ignore: cast_nullable_to_non_nullable
          : amountLabel as String?,
      issuedAt: issuedAt == const $CopyWithPlaceholder()
          ? _value.issuedAt
          // ignore: cast_nullable_to_non_nullable
          : issuedAt as DateTime?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as PublicDocumentResponseDataStatusEnum,
    );
  }
}

extension $PublicDocumentResponseDataCopyWith on PublicDocumentResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfPublicDocumentResponseData.copyWith(...)` or like so:`instanceOfPublicDocumentResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublicDocumentResponseDataCWProxy get copyWith =>
      _$PublicDocumentResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicDocumentResponseData _$PublicDocumentResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PublicDocumentResponseData',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['kind', 'title', 'body_filled', 'status'],
    );
    final val = PublicDocumentResponseData(
      kind: $checkedConvert(
        'kind',
        (v) => $enumDecode(_$PublicDocumentResponseDataKindEnumEnumMap, v),
      ),
      kindLabel: $checkedConvert('kind_label', (v) => v as String?),
      title: $checkedConvert('title', (v) => v as String),
      bodyFilled: $checkedConvert('body_filled', (v) => v as String),
      contactName: $checkedConvert('contact_name', (v) => v as String?),
      currency: $checkedConvert('currency', (v) => v as String?),
      amountCents: $checkedConvert('amount_cents', (v) => (v as num?)?.toInt()),
      amountLabel: $checkedConvert('amount_label', (v) => v as String?),
      issuedAt: $checkedConvert(
        'issued_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$PublicDocumentResponseDataStatusEnumEnumMap, v),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'kindLabel': 'kind_label',
    'bodyFilled': 'body_filled',
    'contactName': 'contact_name',
    'amountCents': 'amount_cents',
    'amountLabel': 'amount_label',
    'issuedAt': 'issued_at',
  },
);

Map<String, dynamic> _$PublicDocumentResponseDataToJson(
  PublicDocumentResponseData instance,
) => <String, dynamic>{
  'kind': _$PublicDocumentResponseDataKindEnumEnumMap[instance.kind]!,
  'kind_label': ?instance.kindLabel,
  'title': instance.title,
  'body_filled': instance.bodyFilled,
  'contact_name': ?instance.contactName,
  'currency': ?instance.currency,
  'amount_cents': ?instance.amountCents,
  'amount_label': ?instance.amountLabel,
  'issued_at': ?instance.issuedAt?.toIso8601String(),
  'status': _$PublicDocumentResponseDataStatusEnumEnumMap[instance.status]!,
};

const _$PublicDocumentResponseDataKindEnumEnumMap = {
  PublicDocumentResponseDataKindEnum.contract: 'contract',
  PublicDocumentResponseDataKindEnum.receipt: 'receipt',
};

const _$PublicDocumentResponseDataStatusEnumEnumMap = {
  PublicDocumentResponseDataStatusEnum.issued: 'issued',
};
