// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stud_listing.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StudListingCWProxy {
  StudListing id(String id);

  StudListing ownerId(String ownerId);

  StudListing sireLabel(String sireLabel);

  StudListing title(String title);

  StudListing feeCents(int feeCents);

  StudListing currency(String currency);

  StudListing notes(String? notes);

  StudListing published(bool published);

  StudListing version(int version);

  StudListing updatedAt(DateTime updatedAt);

  StudListing catteryName(String? catteryName);

  StudListing isMine(bool isMine);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StudListing(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StudListing(...).copyWith(id: 12, name: "My name")
  /// ````
  StudListing call({
    String id,
    String ownerId,
    String sireLabel,
    String title,
    int feeCents,
    String currency,
    String? notes,
    bool published,
    int version,
    DateTime updatedAt,
    String? catteryName,
    bool isMine,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStudListing.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStudListing.copyWith.fieldName(...)`
class _$StudListingCWProxyImpl implements _$StudListingCWProxy {
  const _$StudListingCWProxyImpl(this._value);

  final StudListing _value;

  @override
  StudListing id(String id) => this(id: id);

  @override
  StudListing ownerId(String ownerId) => this(ownerId: ownerId);

  @override
  StudListing sireLabel(String sireLabel) => this(sireLabel: sireLabel);

  @override
  StudListing title(String title) => this(title: title);

  @override
  StudListing feeCents(int feeCents) => this(feeCents: feeCents);

  @override
  StudListing currency(String currency) => this(currency: currency);

  @override
  StudListing notes(String? notes) => this(notes: notes);

  @override
  StudListing published(bool published) => this(published: published);

  @override
  StudListing version(int version) => this(version: version);

  @override
  StudListing updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  StudListing catteryName(String? catteryName) =>
      this(catteryName: catteryName);

  @override
  StudListing isMine(bool isMine) => this(isMine: isMine);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StudListing(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StudListing(...).copyWith(id: 12, name: "My name")
  /// ````
  StudListing call({
    Object? id = const $CopyWithPlaceholder(),
    Object? ownerId = const $CopyWithPlaceholder(),
    Object? sireLabel = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? feeCents = const $CopyWithPlaceholder(),
    Object? currency = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? published = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
    Object? catteryName = const $CopyWithPlaceholder(),
    Object? isMine = const $CopyWithPlaceholder(),
  }) {
    return StudListing(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      ownerId: ownerId == const $CopyWithPlaceholder()
          ? _value.ownerId
          // ignore: cast_nullable_to_non_nullable
          : ownerId as String,
      sireLabel: sireLabel == const $CopyWithPlaceholder()
          ? _value.sireLabel
          // ignore: cast_nullable_to_non_nullable
          : sireLabel as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      feeCents: feeCents == const $CopyWithPlaceholder()
          ? _value.feeCents
          // ignore: cast_nullable_to_non_nullable
          : feeCents as int,
      currency: currency == const $CopyWithPlaceholder()
          ? _value.currency
          // ignore: cast_nullable_to_non_nullable
          : currency as String,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
      published: published == const $CopyWithPlaceholder()
          ? _value.published
          // ignore: cast_nullable_to_non_nullable
          : published as bool,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
      catteryName: catteryName == const $CopyWithPlaceholder()
          ? _value.catteryName
          // ignore: cast_nullable_to_non_nullable
          : catteryName as String?,
      isMine: isMine == const $CopyWithPlaceholder()
          ? _value.isMine
          // ignore: cast_nullable_to_non_nullable
          : isMine as bool,
    );
  }
}

extension $StudListingCopyWith on StudListing {
  /// Returns a callable class that can be used as follows: `instanceOfStudListing.copyWith(...)` or like so:`instanceOfStudListing.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StudListingCWProxy get copyWith => _$StudListingCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudListing _$StudListingFromJson(Map<String, dynamic> json) => $checkedCreate(
  'StudListing',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'owner_id',
        'sire_label',
        'title',
        'fee_cents',
        'currency',
        'published',
        'version',
        'updated_at',
        'is_mine',
      ],
    );
    final val = StudListing(
      id: $checkedConvert('id', (v) => v as String),
      ownerId: $checkedConvert('owner_id', (v) => v as String),
      sireLabel: $checkedConvert('sire_label', (v) => v as String),
      title: $checkedConvert('title', (v) => v as String),
      feeCents: $checkedConvert('fee_cents', (v) => (v as num).toInt()),
      currency: $checkedConvert('currency', (v) => v as String),
      notes: $checkedConvert('notes', (v) => v as String?),
      published: $checkedConvert('published', (v) => v as bool),
      version: $checkedConvert('version', (v) => (v as num).toInt()),
      updatedAt: $checkedConvert(
        'updated_at',
        (v) => DateTime.parse(v as String),
      ),
      catteryName: $checkedConvert('cattery_name', (v) => v as String?),
      isMine: $checkedConvert('is_mine', (v) => v as bool),
    );
    return val;
  },
  fieldKeyMap: const {
    'ownerId': 'owner_id',
    'sireLabel': 'sire_label',
    'feeCents': 'fee_cents',
    'updatedAt': 'updated_at',
    'catteryName': 'cattery_name',
    'isMine': 'is_mine',
  },
);

Map<String, dynamic> _$StudListingToJson(StudListing instance) =>
    <String, dynamic>{
      'id': instance.id,
      'owner_id': instance.ownerId,
      'sire_label': instance.sireLabel,
      'title': instance.title,
      'fee_cents': instance.feeCents,
      'currency': instance.currency,
      'notes': ?instance.notes,
      'published': instance.published,
      'version': instance.version,
      'updated_at': instance.updatedAt.toIso8601String(),
      'cattery_name': ?instance.catteryName,
      'is_mine': instance.isMine,
    };
