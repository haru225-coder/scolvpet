// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enclosure_cleaning.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EnclosureCleaningCWProxy {
  EnclosureCleaning id(String id);

  EnclosureCleaning enclosureId(String enclosureId);

  EnclosureCleaning cleaningType(EnclosureCleaningType cleaningType);

  EnclosureCleaning performedAt(DateTime performedAt);

  EnclosureCleaning supplies(Map<String, Object> supplies);

  EnclosureCleaning notes(String? notes);

  EnclosureCleaning correctsCleaningRecordId(String? correctsCleaningRecordId);

  EnclosureCleaning correctionReason(String? correctionReason);

  EnclosureCleaning createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureCleaning(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureCleaning(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureCleaning call({
    String id,
    String enclosureId,
    EnclosureCleaningType cleaningType,
    DateTime performedAt,
    Map<String, Object> supplies,
    String? notes,
    String? correctsCleaningRecordId,
    String? correctionReason,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEnclosureCleaning.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEnclosureCleaning.copyWith.fieldName(...)`
class _$EnclosureCleaningCWProxyImpl implements _$EnclosureCleaningCWProxy {
  const _$EnclosureCleaningCWProxyImpl(this._value);

  final EnclosureCleaning _value;

  @override
  EnclosureCleaning id(String id) => this(id: id);

  @override
  EnclosureCleaning enclosureId(String enclosureId) =>
      this(enclosureId: enclosureId);

  @override
  EnclosureCleaning cleaningType(EnclosureCleaningType cleaningType) =>
      this(cleaningType: cleaningType);

  @override
  EnclosureCleaning performedAt(DateTime performedAt) =>
      this(performedAt: performedAt);

  @override
  EnclosureCleaning supplies(Map<String, Object> supplies) =>
      this(supplies: supplies);

  @override
  EnclosureCleaning notes(String? notes) => this(notes: notes);

  @override
  EnclosureCleaning correctsCleaningRecordId(
    String? correctsCleaningRecordId,
  ) => this(correctsCleaningRecordId: correctsCleaningRecordId);

  @override
  EnclosureCleaning correctionReason(String? correctionReason) =>
      this(correctionReason: correctionReason);

  @override
  EnclosureCleaning createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureCleaning(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureCleaning(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureCleaning call({
    Object? id = const $CopyWithPlaceholder(),
    Object? enclosureId = const $CopyWithPlaceholder(),
    Object? cleaningType = const $CopyWithPlaceholder(),
    Object? performedAt = const $CopyWithPlaceholder(),
    Object? supplies = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? correctsCleaningRecordId = const $CopyWithPlaceholder(),
    Object? correctionReason = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return EnclosureCleaning(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      enclosureId: enclosureId == const $CopyWithPlaceholder()
          ? _value.enclosureId
          // ignore: cast_nullable_to_non_nullable
          : enclosureId as String,
      cleaningType: cleaningType == const $CopyWithPlaceholder()
          ? _value.cleaningType
          // ignore: cast_nullable_to_non_nullable
          : cleaningType as EnclosureCleaningType,
      performedAt: performedAt == const $CopyWithPlaceholder()
          ? _value.performedAt
          // ignore: cast_nullable_to_non_nullable
          : performedAt as DateTime,
      supplies: supplies == const $CopyWithPlaceholder()
          ? _value.supplies
          // ignore: cast_nullable_to_non_nullable
          : supplies as Map<String, Object>,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
      correctsCleaningRecordId:
          correctsCleaningRecordId == const $CopyWithPlaceholder()
          ? _value.correctsCleaningRecordId
          // ignore: cast_nullable_to_non_nullable
          : correctsCleaningRecordId as String?,
      correctionReason: correctionReason == const $CopyWithPlaceholder()
          ? _value.correctionReason
          // ignore: cast_nullable_to_non_nullable
          : correctionReason as String?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $EnclosureCleaningCopyWith on EnclosureCleaning {
  /// Returns a callable class that can be used as follows: `instanceOfEnclosureCleaning.copyWith(...)` or like so:`instanceOfEnclosureCleaning.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EnclosureCleaningCWProxy get copyWith =>
      _$EnclosureCleaningCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnclosureCleaning _$EnclosureCleaningFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'EnclosureCleaning',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'enclosure_id',
            'cleaning_type',
            'performed_at',
            'supplies',
            'created_at',
          ],
        );
        final val = EnclosureCleaning(
          id: $checkedConvert('id', (v) => v as String),
          enclosureId: $checkedConvert('enclosure_id', (v) => v as String),
          cleaningType: $checkedConvert(
            'cleaning_type',
            (v) => $enumDecode(_$EnclosureCleaningTypeEnumMap, v),
          ),
          performedAt: $checkedConvert(
            'performed_at',
            (v) => DateTime.parse(v as String),
          ),
          supplies: $checkedConvert(
            'supplies',
            (v) => (v as Map<String, dynamic>).map(
              (k, e) => MapEntry(k, e as Object),
            ),
          ),
          notes: $checkedConvert('notes', (v) => v as String?),
          correctsCleaningRecordId: $checkedConvert(
            'corrects_cleaning_record_id',
            (v) => v as String?,
          ),
          correctionReason: $checkedConvert(
            'correction_reason',
            (v) => v as String?,
          ),
          createdAt: $checkedConvert(
            'created_at',
            (v) => DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'enclosureId': 'enclosure_id',
        'cleaningType': 'cleaning_type',
        'performedAt': 'performed_at',
        'correctsCleaningRecordId': 'corrects_cleaning_record_id',
        'correctionReason': 'correction_reason',
        'createdAt': 'created_at',
      },
    );

Map<String, dynamic> _$EnclosureCleaningToJson(EnclosureCleaning instance) =>
    <String, dynamic>{
      'id': instance.id,
      'enclosure_id': instance.enclosureId,
      'cleaning_type': _$EnclosureCleaningTypeEnumMap[instance.cleaningType]!,
      'performed_at': instance.performedAt.toIso8601String(),
      'supplies': instance.supplies,
      'notes': ?instance.notes,
      'corrects_cleaning_record_id': ?instance.correctsCleaningRecordId,
      'correction_reason': ?instance.correctionReason,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$EnclosureCleaningTypeEnumMap = {
  EnclosureCleaningType.partial: 'partial',
  EnclosureCleaningType.full: 'full',
  EnclosureCleaningType.disinfection: 'disinfection',
};
