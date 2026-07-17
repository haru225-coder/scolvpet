// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_stud_listing_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateStudListingRequestCWProxy {
  CreateStudListingRequest sireLabel(String sireLabel);

  CreateStudListingRequest title(String? title);

  CreateStudListingRequest feeCents(int? feeCents);

  CreateStudListingRequest currency(String? currency);

  CreateStudListingRequest notes(String? notes);

  CreateStudListingRequest published(bool? published);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateStudListingRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateStudListingRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateStudListingRequest call({
    String sireLabel,
    String? title,
    int? feeCents,
    String? currency,
    String? notes,
    bool? published,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateStudListingRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateStudListingRequest.copyWith.fieldName(...)`
class _$CreateStudListingRequestCWProxyImpl
    implements _$CreateStudListingRequestCWProxy {
  const _$CreateStudListingRequestCWProxyImpl(this._value);

  final CreateStudListingRequest _value;

  @override
  CreateStudListingRequest sireLabel(String sireLabel) =>
      this(sireLabel: sireLabel);

  @override
  CreateStudListingRequest title(String? title) => this(title: title);

  @override
  CreateStudListingRequest feeCents(int? feeCents) => this(feeCents: feeCents);

  @override
  CreateStudListingRequest currency(String? currency) =>
      this(currency: currency);

  @override
  CreateStudListingRequest notes(String? notes) => this(notes: notes);

  @override
  CreateStudListingRequest published(bool? published) =>
      this(published: published);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateStudListingRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateStudListingRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateStudListingRequest call({
    Object? sireLabel = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? feeCents = const $CopyWithPlaceholder(),
    Object? currency = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? published = const $CopyWithPlaceholder(),
  }) {
    return CreateStudListingRequest(
      sireLabel: sireLabel == const $CopyWithPlaceholder()
          ? _value.sireLabel
          // ignore: cast_nullable_to_non_nullable
          : sireLabel as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      feeCents: feeCents == const $CopyWithPlaceholder()
          ? _value.feeCents
          // ignore: cast_nullable_to_non_nullable
          : feeCents as int?,
      currency: currency == const $CopyWithPlaceholder()
          ? _value.currency
          // ignore: cast_nullable_to_non_nullable
          : currency as String?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
      published: published == const $CopyWithPlaceholder()
          ? _value.published
          // ignore: cast_nullable_to_non_nullable
          : published as bool?,
    );
  }
}

extension $CreateStudListingRequestCopyWith on CreateStudListingRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateStudListingRequest.copyWith(...)` or like so:`instanceOfCreateStudListingRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateStudListingRequestCWProxy get copyWith =>
      _$CreateStudListingRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateStudListingRequest _$CreateStudListingRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CreateStudListingRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['sire_label']);
    final val = CreateStudListingRequest(
      sireLabel: $checkedConvert('sire_label', (v) => v as String),
      title: $checkedConvert('title', (v) => v as String?),
      feeCents: $checkedConvert('fee_cents', (v) => (v as num?)?.toInt()),
      currency: $checkedConvert('currency', (v) => v as String? ?? 'CNY'),
      notes: $checkedConvert('notes', (v) => v as String?),
      published: $checkedConvert('published', (v) => v as bool? ?? true),
    );
    return val;
  },
  fieldKeyMap: const {'sireLabel': 'sire_label', 'feeCents': 'fee_cents'},
);

Map<String, dynamic> _$CreateStudListingRequestToJson(
  CreateStudListingRequest instance,
) => <String, dynamic>{
  'sire_label': instance.sireLabel,
  'title': ?instance.title,
  'fee_cents': ?instance.feeCents,
  'currency': ?instance.currency,
  'notes': ?instance.notes,
  'published': ?instance.published,
};
