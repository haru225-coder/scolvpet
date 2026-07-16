// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pup_identity.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PupIdentityCWProxy {
  PupIdentity id(String id);

  PupIdentity litterId(String litterId);

  PupIdentity temporaryCode(String temporaryCode);

  PupIdentity sex(Sex sex);

  PupIdentity sexConfidence(num? sexConfidence);

  PupIdentity phenotypeSummary(Map<String, Object>? phenotypeSummary);

  PupIdentity destination(PupIdentityDestinationEnum? destination);

  PupIdentity currentEnclosureId(String? currentEnclosureId);

  PupIdentity hamsterId(String? hamsterId);

  PupIdentity outcomeStatus(PupOutcomeStatus outcomeStatus);

  PupIdentity profileStatus(PupProfileStatus profileStatus);

  PupIdentity version(int version);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PupIdentity(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PupIdentity(...).copyWith(id: 12, name: "My name")
  /// ````
  PupIdentity call({
    String id,
    String litterId,
    String temporaryCode,
    Sex sex,
    num? sexConfidence,
    Map<String, Object>? phenotypeSummary,
    PupIdentityDestinationEnum? destination,
    String? currentEnclosureId,
    String? hamsterId,
    PupOutcomeStatus outcomeStatus,
    PupProfileStatus profileStatus,
    int version,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPupIdentity.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPupIdentity.copyWith.fieldName(...)`
class _$PupIdentityCWProxyImpl implements _$PupIdentityCWProxy {
  const _$PupIdentityCWProxyImpl(this._value);

  final PupIdentity _value;

  @override
  PupIdentity id(String id) => this(id: id);

  @override
  PupIdentity litterId(String litterId) => this(litterId: litterId);

  @override
  PupIdentity temporaryCode(String temporaryCode) =>
      this(temporaryCode: temporaryCode);

  @override
  PupIdentity sex(Sex sex) => this(sex: sex);

  @override
  PupIdentity sexConfidence(num? sexConfidence) =>
      this(sexConfidence: sexConfidence);

  @override
  PupIdentity phenotypeSummary(Map<String, Object>? phenotypeSummary) =>
      this(phenotypeSummary: phenotypeSummary);

  @override
  PupIdentity destination(PupIdentityDestinationEnum? destination) =>
      this(destination: destination);

  @override
  PupIdentity currentEnclosureId(String? currentEnclosureId) =>
      this(currentEnclosureId: currentEnclosureId);

  @override
  PupIdentity hamsterId(String? hamsterId) => this(hamsterId: hamsterId);

  @override
  PupIdentity outcomeStatus(PupOutcomeStatus outcomeStatus) =>
      this(outcomeStatus: outcomeStatus);

  @override
  PupIdentity profileStatus(PupProfileStatus profileStatus) =>
      this(profileStatus: profileStatus);

  @override
  PupIdentity version(int version) => this(version: version);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PupIdentity(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PupIdentity(...).copyWith(id: 12, name: "My name")
  /// ````
  PupIdentity call({
    Object? id = const $CopyWithPlaceholder(),
    Object? litterId = const $CopyWithPlaceholder(),
    Object? temporaryCode = const $CopyWithPlaceholder(),
    Object? sex = const $CopyWithPlaceholder(),
    Object? sexConfidence = const $CopyWithPlaceholder(),
    Object? phenotypeSummary = const $CopyWithPlaceholder(),
    Object? destination = const $CopyWithPlaceholder(),
    Object? currentEnclosureId = const $CopyWithPlaceholder(),
    Object? hamsterId = const $CopyWithPlaceholder(),
    Object? outcomeStatus = const $CopyWithPlaceholder(),
    Object? profileStatus = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
  }) {
    return PupIdentity(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      litterId: litterId == const $CopyWithPlaceholder()
          ? _value.litterId
          // ignore: cast_nullable_to_non_nullable
          : litterId as String,
      temporaryCode: temporaryCode == const $CopyWithPlaceholder()
          ? _value.temporaryCode
          // ignore: cast_nullable_to_non_nullable
          : temporaryCode as String,
      sex: sex == const $CopyWithPlaceholder()
          ? _value.sex
          // ignore: cast_nullable_to_non_nullable
          : sex as Sex,
      sexConfidence: sexConfidence == const $CopyWithPlaceholder()
          ? _value.sexConfidence
          // ignore: cast_nullable_to_non_nullable
          : sexConfidence as num?,
      phenotypeSummary: phenotypeSummary == const $CopyWithPlaceholder()
          ? _value.phenotypeSummary
          // ignore: cast_nullable_to_non_nullable
          : phenotypeSummary as Map<String, Object>?,
      destination: destination == const $CopyWithPlaceholder()
          ? _value.destination
          // ignore: cast_nullable_to_non_nullable
          : destination as PupIdentityDestinationEnum?,
      currentEnclosureId: currentEnclosureId == const $CopyWithPlaceholder()
          ? _value.currentEnclosureId
          // ignore: cast_nullable_to_non_nullable
          : currentEnclosureId as String?,
      hamsterId: hamsterId == const $CopyWithPlaceholder()
          ? _value.hamsterId
          // ignore: cast_nullable_to_non_nullable
          : hamsterId as String?,
      outcomeStatus: outcomeStatus == const $CopyWithPlaceholder()
          ? _value.outcomeStatus
          // ignore: cast_nullable_to_non_nullable
          : outcomeStatus as PupOutcomeStatus,
      profileStatus: profileStatus == const $CopyWithPlaceholder()
          ? _value.profileStatus
          // ignore: cast_nullable_to_non_nullable
          : profileStatus as PupProfileStatus,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
    );
  }
}

extension $PupIdentityCopyWith on PupIdentity {
  /// Returns a callable class that can be used as follows: `instanceOfPupIdentity.copyWith(...)` or like so:`instanceOfPupIdentity.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PupIdentityCWProxy get copyWith => _$PupIdentityCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PupIdentity _$PupIdentityFromJson(Map<String, dynamic> json) => $checkedCreate(
  'PupIdentity',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'litter_id',
        'temporary_code',
        'sex',
        'outcome_status',
        'profile_status',
        'version',
      ],
    );
    final val = PupIdentity(
      id: $checkedConvert('id', (v) => v as String),
      litterId: $checkedConvert('litter_id', (v) => v as String),
      temporaryCode: $checkedConvert('temporary_code', (v) => v as String),
      sex: $checkedConvert('sex', (v) => $enumDecode(_$SexEnumMap, v)),
      sexConfidence: $checkedConvert('sex_confidence', (v) => v as num?),
      phenotypeSummary: $checkedConvert(
        'phenotype_summary',
        (v) => (v as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, e as Object),
        ),
      ),
      destination: $checkedConvert(
        'destination',
        (v) => $enumDecodeNullable(_$PupIdentityDestinationEnumEnumMap, v),
      ),
      currentEnclosureId: $checkedConvert(
        'current_enclosure_id',
        (v) => v as String?,
      ),
      hamsterId: $checkedConvert('hamster_id', (v) => v as String?),
      outcomeStatus: $checkedConvert(
        'outcome_status',
        (v) => $enumDecode(_$PupOutcomeStatusEnumMap, v),
      ),
      profileStatus: $checkedConvert(
        'profile_status',
        (v) => $enumDecode(_$PupProfileStatusEnumMap, v),
      ),
      version: $checkedConvert('version', (v) => (v as num).toInt()),
    );
    return val;
  },
  fieldKeyMap: const {
    'litterId': 'litter_id',
    'temporaryCode': 'temporary_code',
    'sexConfidence': 'sex_confidence',
    'phenotypeSummary': 'phenotype_summary',
    'currentEnclosureId': 'current_enclosure_id',
    'hamsterId': 'hamster_id',
    'outcomeStatus': 'outcome_status',
    'profileStatus': 'profile_status',
  },
);

Map<String, dynamic> _$PupIdentityToJson(PupIdentity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'litter_id': instance.litterId,
      'temporary_code': instance.temporaryCode,
      'sex': _$SexEnumMap[instance.sex]!,
      'sex_confidence': ?instance.sexConfidence,
      'phenotype_summary': ?instance.phenotypeSummary,
      'destination': ?_$PupIdentityDestinationEnumEnumMap[instance.destination],
      'current_enclosure_id': ?instance.currentEnclosureId,
      'hamster_id': ?instance.hamsterId,
      'outcome_status': _$PupOutcomeStatusEnumMap[instance.outcomeStatus]!,
      'profile_status': _$PupProfileStatusEnumMap[instance.profileStatus]!,
      'version': instance.version,
    };

const _$SexEnumMap = {
  Sex.male: 'male',
  Sex.female: 'female',
  Sex.unknown: 'unknown',
};

const _$PupIdentityDestinationEnumEnumMap = {
  PupIdentityDestinationEnum.breeding: 'breeding',
  PupIdentityDestinationEnum.reserved: 'reserved',
  PupIdentityDestinationEnum.transfer: 'transfer',
  PupIdentityDestinationEnum.undecided: 'undecided',
};

const _$PupOutcomeStatusEnumMap = {
  PupOutcomeStatus.alive: 'alive',
  PupOutcomeStatus.deceased: 'deceased',
  PupOutcomeStatus.transferredOut: 'transferred_out',
};

const _$PupProfileStatusEnumMap = {
  PupProfileStatus.unindividualized: 'unindividualized',
  PupProfileStatus.individualized: 'individualized',
  PupProfileStatus.voided: 'voided',
};
