// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hamster_create_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HamsterCreateRequestCWProxy {
  HamsterCreateRequest internalCode(String internalCode);

  HamsterCreateRequest name(String? name);

  HamsterCreateRequest speciesRuleVersionId(String speciesRuleVersionId);

  HamsterCreateRequest varietyCode(String? varietyCode);

  HamsterCreateRequest sex(Sex sex);

  HamsterCreateRequest sexConfidence(num? sexConfidence);

  HamsterCreateRequest birthDate(DateTime? birthDate);

  HamsterCreateRequest sourceType(HamsterSourceType sourceType);

  HamsterCreateRequest coverMediaId(String? coverMediaId);

  HamsterCreateRequest notes(String? notes);

  HamsterCreateRequest sireId(String? sireId);

  HamsterCreateRequest damId(String? damId);

  HamsterCreateRequest litterId(String? litterId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HamsterCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HamsterCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  HamsterCreateRequest call({
    String internalCode,
    String? name,
    String speciesRuleVersionId,
    String? varietyCode,
    Sex sex,
    num? sexConfidence,
    DateTime? birthDate,
    HamsterSourceType sourceType,
    String? coverMediaId,
    String? notes,
    String? sireId,
    String? damId,
    String? litterId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHamsterCreateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHamsterCreateRequest.copyWith.fieldName(...)`
class _$HamsterCreateRequestCWProxyImpl
    implements _$HamsterCreateRequestCWProxy {
  const _$HamsterCreateRequestCWProxyImpl(this._value);

  final HamsterCreateRequest _value;

  @override
  HamsterCreateRequest internalCode(String internalCode) =>
      this(internalCode: internalCode);

  @override
  HamsterCreateRequest name(String? name) => this(name: name);

  @override
  HamsterCreateRequest speciesRuleVersionId(String speciesRuleVersionId) =>
      this(speciesRuleVersionId: speciesRuleVersionId);

  @override
  HamsterCreateRequest varietyCode(String? varietyCode) =>
      this(varietyCode: varietyCode);

  @override
  HamsterCreateRequest sex(Sex sex) => this(sex: sex);

  @override
  HamsterCreateRequest sexConfidence(num? sexConfidence) =>
      this(sexConfidence: sexConfidence);

  @override
  HamsterCreateRequest birthDate(DateTime? birthDate) =>
      this(birthDate: birthDate);

  @override
  HamsterCreateRequest sourceType(HamsterSourceType sourceType) =>
      this(sourceType: sourceType);

  @override
  HamsterCreateRequest coverMediaId(String? coverMediaId) =>
      this(coverMediaId: coverMediaId);

  @override
  HamsterCreateRequest notes(String? notes) => this(notes: notes);

  @override
  HamsterCreateRequest sireId(String? sireId) => this(sireId: sireId);

  @override
  HamsterCreateRequest damId(String? damId) => this(damId: damId);

  @override
  HamsterCreateRequest litterId(String? litterId) => this(litterId: litterId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HamsterCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HamsterCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  HamsterCreateRequest call({
    Object? internalCode = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? speciesRuleVersionId = const $CopyWithPlaceholder(),
    Object? varietyCode = const $CopyWithPlaceholder(),
    Object? sex = const $CopyWithPlaceholder(),
    Object? sexConfidence = const $CopyWithPlaceholder(),
    Object? birthDate = const $CopyWithPlaceholder(),
    Object? sourceType = const $CopyWithPlaceholder(),
    Object? coverMediaId = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? sireId = const $CopyWithPlaceholder(),
    Object? damId = const $CopyWithPlaceholder(),
    Object? litterId = const $CopyWithPlaceholder(),
  }) {
    return HamsterCreateRequest(
      internalCode: internalCode == const $CopyWithPlaceholder()
          ? _value.internalCode
          // ignore: cast_nullable_to_non_nullable
          : internalCode as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      speciesRuleVersionId: speciesRuleVersionId == const $CopyWithPlaceholder()
          ? _value.speciesRuleVersionId
          // ignore: cast_nullable_to_non_nullable
          : speciesRuleVersionId as String,
      varietyCode: varietyCode == const $CopyWithPlaceholder()
          ? _value.varietyCode
          // ignore: cast_nullable_to_non_nullable
          : varietyCode as String?,
      sex: sex == const $CopyWithPlaceholder()
          ? _value.sex
          // ignore: cast_nullable_to_non_nullable
          : sex as Sex,
      sexConfidence: sexConfidence == const $CopyWithPlaceholder()
          ? _value.sexConfidence
          // ignore: cast_nullable_to_non_nullable
          : sexConfidence as num?,
      birthDate: birthDate == const $CopyWithPlaceholder()
          ? _value.birthDate
          // ignore: cast_nullable_to_non_nullable
          : birthDate as DateTime?,
      sourceType: sourceType == const $CopyWithPlaceholder()
          ? _value.sourceType
          // ignore: cast_nullable_to_non_nullable
          : sourceType as HamsterSourceType,
      coverMediaId: coverMediaId == const $CopyWithPlaceholder()
          ? _value.coverMediaId
          // ignore: cast_nullable_to_non_nullable
          : coverMediaId as String?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
      sireId: sireId == const $CopyWithPlaceholder()
          ? _value.sireId
          // ignore: cast_nullable_to_non_nullable
          : sireId as String?,
      damId: damId == const $CopyWithPlaceholder()
          ? _value.damId
          // ignore: cast_nullable_to_non_nullable
          : damId as String?,
      litterId: litterId == const $CopyWithPlaceholder()
          ? _value.litterId
          // ignore: cast_nullable_to_non_nullable
          : litterId as String?,
    );
  }
}

extension $HamsterCreateRequestCopyWith on HamsterCreateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfHamsterCreateRequest.copyWith(...)` or like so:`instanceOfHamsterCreateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HamsterCreateRequestCWProxy get copyWith =>
      _$HamsterCreateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HamsterCreateRequest _$HamsterCreateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'HamsterCreateRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'internal_code',
        'species_rule_version_id',
        'sex',
        'source_type',
      ],
    );
    final val = HamsterCreateRequest(
      internalCode: $checkedConvert('internal_code', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String?),
      speciesRuleVersionId: $checkedConvert(
        'species_rule_version_id',
        (v) => v as String,
      ),
      varietyCode: $checkedConvert('variety_code', (v) => v as String?),
      sex: $checkedConvert('sex', (v) => $enumDecode(_$SexEnumMap, v)),
      sexConfidence: $checkedConvert('sex_confidence', (v) => v as num?),
      birthDate: $checkedConvert(
        'birth_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      sourceType: $checkedConvert(
        'source_type',
        (v) => $enumDecode(_$HamsterSourceTypeEnumMap, v),
      ),
      coverMediaId: $checkedConvert('cover_media_id', (v) => v as String?),
      notes: $checkedConvert('notes', (v) => v as String?),
      sireId: $checkedConvert('sire_id', (v) => v as String?),
      damId: $checkedConvert('dam_id', (v) => v as String?),
      litterId: $checkedConvert('litter_id', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'internalCode': 'internal_code',
    'speciesRuleVersionId': 'species_rule_version_id',
    'varietyCode': 'variety_code',
    'sexConfidence': 'sex_confidence',
    'birthDate': 'birth_date',
    'sourceType': 'source_type',
    'coverMediaId': 'cover_media_id',
    'sireId': 'sire_id',
    'damId': 'dam_id',
    'litterId': 'litter_id',
  },
);

Map<String, dynamic> _$HamsterCreateRequestToJson(
  HamsterCreateRequest instance,
) => <String, dynamic>{
  'internal_code': instance.internalCode,
  'name': ?instance.name,
  'species_rule_version_id': instance.speciesRuleVersionId,
  'variety_code': ?instance.varietyCode,
  'sex': _$SexEnumMap[instance.sex]!,
  'sex_confidence': ?instance.sexConfidence,
  'birth_date': ?instance.birthDate?.toIso8601String(),
  'source_type': _$HamsterSourceTypeEnumMap[instance.sourceType]!,
  'cover_media_id': ?instance.coverMediaId,
  'notes': ?instance.notes,
  'sire_id': ?instance.sireId,
  'dam_id': ?instance.damId,
  'litter_id': ?instance.litterId,
};

const _$SexEnumMap = {
  Sex.male: 'male',
  Sex.female: 'female',
  Sex.unknown: 'unknown',
};

const _$HamsterSourceTypeEnumMap = {
  HamsterSourceType.bornHere: 'born_here',
  HamsterSourceType.introduced: 'introduced',
  HamsterSourceType.customer: 'customer',
  HamsterSourceType.imported: 'imported',
};
