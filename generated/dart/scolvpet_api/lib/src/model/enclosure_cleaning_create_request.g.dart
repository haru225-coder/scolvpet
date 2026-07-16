// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enclosure_cleaning_create_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EnclosureCleaningCreateRequestCWProxy {
  EnclosureCleaningCreateRequest cleaningType(
    EnclosureCleaningType cleaningType,
  );

  EnclosureCleaningCreateRequest performedAt(DateTime performedAt);

  EnclosureCleaningCreateRequest supplies(Map<String, Object>? supplies);

  EnclosureCleaningCreateRequest notes(String? notes);

  EnclosureCleaningCreateRequest correctsCleaningRecordId(
    String? correctsCleaningRecordId,
  );

  EnclosureCleaningCreateRequest correctionReason(String? correctionReason);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureCleaningCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureCleaningCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureCleaningCreateRequest call({
    EnclosureCleaningType cleaningType,
    DateTime performedAt,
    Map<String, Object>? supplies,
    String? notes,
    String? correctsCleaningRecordId,
    String? correctionReason,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEnclosureCleaningCreateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEnclosureCleaningCreateRequest.copyWith.fieldName(...)`
class _$EnclosureCleaningCreateRequestCWProxyImpl
    implements _$EnclosureCleaningCreateRequestCWProxy {
  const _$EnclosureCleaningCreateRequestCWProxyImpl(this._value);

  final EnclosureCleaningCreateRequest _value;

  @override
  EnclosureCleaningCreateRequest cleaningType(
    EnclosureCleaningType cleaningType,
  ) => this(cleaningType: cleaningType);

  @override
  EnclosureCleaningCreateRequest performedAt(DateTime performedAt) =>
      this(performedAt: performedAt);

  @override
  EnclosureCleaningCreateRequest supplies(Map<String, Object>? supplies) =>
      this(supplies: supplies);

  @override
  EnclosureCleaningCreateRequest notes(String? notes) => this(notes: notes);

  @override
  EnclosureCleaningCreateRequest correctsCleaningRecordId(
    String? correctsCleaningRecordId,
  ) => this(correctsCleaningRecordId: correctsCleaningRecordId);

  @override
  EnclosureCleaningCreateRequest correctionReason(String? correctionReason) =>
      this(correctionReason: correctionReason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureCleaningCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureCleaningCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureCleaningCreateRequest call({
    Object? cleaningType = const $CopyWithPlaceholder(),
    Object? performedAt = const $CopyWithPlaceholder(),
    Object? supplies = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? correctsCleaningRecordId = const $CopyWithPlaceholder(),
    Object? correctionReason = const $CopyWithPlaceholder(),
  }) {
    return EnclosureCleaningCreateRequest(
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
          : supplies as Map<String, Object>?,
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
    );
  }
}

extension $EnclosureCleaningCreateRequestCopyWith
    on EnclosureCleaningCreateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfEnclosureCleaningCreateRequest.copyWith(...)` or like so:`instanceOfEnclosureCleaningCreateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EnclosureCleaningCreateRequestCWProxy get copyWith =>
      _$EnclosureCleaningCreateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnclosureCleaningCreateRequest _$EnclosureCleaningCreateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'EnclosureCleaningCreateRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['cleaning_type', 'performed_at']);
    final val = EnclosureCleaningCreateRequest(
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
        (v) => (v as Map<String, dynamic>?)?.map(
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
    );
    return val;
  },
  fieldKeyMap: const {
    'cleaningType': 'cleaning_type',
    'performedAt': 'performed_at',
    'correctsCleaningRecordId': 'corrects_cleaning_record_id',
    'correctionReason': 'correction_reason',
  },
);

Map<String, dynamic> _$EnclosureCleaningCreateRequestToJson(
  EnclosureCleaningCreateRequest instance,
) => <String, dynamic>{
  'cleaning_type': _$EnclosureCleaningTypeEnumMap[instance.cleaningType]!,
  'performed_at': instance.performedAt.toIso8601String(),
  'supplies': ?instance.supplies,
  'notes': ?instance.notes,
  'corrects_cleaning_record_id': ?instance.correctsCleaningRecordId,
  'correction_reason': ?instance.correctionReason,
};

const _$EnclosureCleaningTypeEnumMap = {
  EnclosureCleaningType.partial: 'partial',
  EnclosureCleaningType.full: 'full',
  EnclosureCleaningType.disinfection: 'disinfection',
};
