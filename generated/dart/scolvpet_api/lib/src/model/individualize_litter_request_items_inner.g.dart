// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'individualize_litter_request_items_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$IndividualizeLitterRequestItemsInnerCWProxy {
  IndividualizeLitterRequestItemsInner pupIdentityId(String pupIdentityId);

  IndividualizeLitterRequestItemsInner internalCode(String internalCode);

  IndividualizeLitterRequestItemsInner name(String? name);

  IndividualizeLitterRequestItemsInner varietyCode(String? varietyCode);

  IndividualizeLitterRequestItemsInner coverMediaId(String? coverMediaId);

  IndividualizeLitterRequestItemsInner notes(String? notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IndividualizeLitterRequestItemsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IndividualizeLitterRequestItemsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  IndividualizeLitterRequestItemsInner call({
    String pupIdentityId,
    String internalCode,
    String? name,
    String? varietyCode,
    String? coverMediaId,
    String? notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfIndividualizeLitterRequestItemsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfIndividualizeLitterRequestItemsInner.copyWith.fieldName(...)`
class _$IndividualizeLitterRequestItemsInnerCWProxyImpl
    implements _$IndividualizeLitterRequestItemsInnerCWProxy {
  const _$IndividualizeLitterRequestItemsInnerCWProxyImpl(this._value);

  final IndividualizeLitterRequestItemsInner _value;

  @override
  IndividualizeLitterRequestItemsInner pupIdentityId(String pupIdentityId) =>
      this(pupIdentityId: pupIdentityId);

  @override
  IndividualizeLitterRequestItemsInner internalCode(String internalCode) =>
      this(internalCode: internalCode);

  @override
  IndividualizeLitterRequestItemsInner name(String? name) => this(name: name);

  @override
  IndividualizeLitterRequestItemsInner varietyCode(String? varietyCode) =>
      this(varietyCode: varietyCode);

  @override
  IndividualizeLitterRequestItemsInner coverMediaId(String? coverMediaId) =>
      this(coverMediaId: coverMediaId);

  @override
  IndividualizeLitterRequestItemsInner notes(String? notes) =>
      this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IndividualizeLitterRequestItemsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IndividualizeLitterRequestItemsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  IndividualizeLitterRequestItemsInner call({
    Object? pupIdentityId = const $CopyWithPlaceholder(),
    Object? internalCode = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? varietyCode = const $CopyWithPlaceholder(),
    Object? coverMediaId = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return IndividualizeLitterRequestItemsInner(
      pupIdentityId: pupIdentityId == const $CopyWithPlaceholder()
          ? _value.pupIdentityId
          // ignore: cast_nullable_to_non_nullable
          : pupIdentityId as String,
      internalCode: internalCode == const $CopyWithPlaceholder()
          ? _value.internalCode
          // ignore: cast_nullable_to_non_nullable
          : internalCode as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      varietyCode: varietyCode == const $CopyWithPlaceholder()
          ? _value.varietyCode
          // ignore: cast_nullable_to_non_nullable
          : varietyCode as String?,
      coverMediaId: coverMediaId == const $CopyWithPlaceholder()
          ? _value.coverMediaId
          // ignore: cast_nullable_to_non_nullable
          : coverMediaId as String?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
    );
  }
}

extension $IndividualizeLitterRequestItemsInnerCopyWith
    on IndividualizeLitterRequestItemsInner {
  /// Returns a callable class that can be used as follows: `instanceOfIndividualizeLitterRequestItemsInner.copyWith(...)` or like so:`instanceOfIndividualizeLitterRequestItemsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$IndividualizeLitterRequestItemsInnerCWProxy get copyWith =>
      _$IndividualizeLitterRequestItemsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IndividualizeLitterRequestItemsInner
_$IndividualizeLitterRequestItemsInnerFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'IndividualizeLitterRequestItemsInner',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['pup_identity_id', 'internal_code'],
        );
        final val = IndividualizeLitterRequestItemsInner(
          pupIdentityId: $checkedConvert('pup_identity_id', (v) => v as String),
          internalCode: $checkedConvert('internal_code', (v) => v as String),
          name: $checkedConvert('name', (v) => v as String?),
          varietyCode: $checkedConvert('variety_code', (v) => v as String?),
          coverMediaId: $checkedConvert('cover_media_id', (v) => v as String?),
          notes: $checkedConvert('notes', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'pupIdentityId': 'pup_identity_id',
        'internalCode': 'internal_code',
        'varietyCode': 'variety_code',
        'coverMediaId': 'cover_media_id',
      },
    );

Map<String, dynamic> _$IndividualizeLitterRequestItemsInnerToJson(
  IndividualizeLitterRequestItemsInner instance,
) => <String, dynamic>{
  'pup_identity_id': instance.pupIdentityId,
  'internal_code': instance.internalCode,
  'name': ?instance.name,
  'variety_code': ?instance.varietyCode,
  'cover_media_id': ?instance.coverMediaId,
  'notes': ?instance.notes,
};
