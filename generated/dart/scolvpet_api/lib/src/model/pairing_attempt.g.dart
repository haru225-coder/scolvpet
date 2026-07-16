// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_attempt.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PairingAttemptCWProxy {
  PairingAttempt id(String id);

  PairingAttempt breedingPlanId(String breedingPlanId);

  PairingAttempt sequence(int sequence);

  PairingAttempt enclosureId(String enclosureId);

  PairingAttempt startedAt(DateTime startedAt);

  PairingAttempt endedAt(DateTime? endedAt);

  PairingAttempt separatedAt(DateTime? separatedAt);

  PairingAttempt separationDeadline(DateTime separationDeadline);

  PairingAttempt status(PairingAttemptStatus status);

  PairingAttempt result(PairingResult? result);

  PairingAttempt conflictLevel(PairingAttemptConflictLevelEnum? conflictLevel);

  PairingAttempt sireDestinationEnclosureId(String? sireDestinationEnclosureId);

  PairingAttempt damDestinationEnclosureId(String? damDestinationEnclosureId);

  PairingAttempt notes(String? notes);

  PairingAttempt version(int version);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PairingAttempt(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PairingAttempt(...).copyWith(id: 12, name: "My name")
  /// ````
  PairingAttempt call({
    String id,
    String breedingPlanId,
    int sequence,
    String enclosureId,
    DateTime startedAt,
    DateTime? endedAt,
    DateTime? separatedAt,
    DateTime separationDeadline,
    PairingAttemptStatus status,
    PairingResult? result,
    PairingAttemptConflictLevelEnum? conflictLevel,
    String? sireDestinationEnclosureId,
    String? damDestinationEnclosureId,
    String? notes,
    int version,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPairingAttempt.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPairingAttempt.copyWith.fieldName(...)`
class _$PairingAttemptCWProxyImpl implements _$PairingAttemptCWProxy {
  const _$PairingAttemptCWProxyImpl(this._value);

  final PairingAttempt _value;

  @override
  PairingAttempt id(String id) => this(id: id);

  @override
  PairingAttempt breedingPlanId(String breedingPlanId) =>
      this(breedingPlanId: breedingPlanId);

  @override
  PairingAttempt sequence(int sequence) => this(sequence: sequence);

  @override
  PairingAttempt enclosureId(String enclosureId) =>
      this(enclosureId: enclosureId);

  @override
  PairingAttempt startedAt(DateTime startedAt) => this(startedAt: startedAt);

  @override
  PairingAttempt endedAt(DateTime? endedAt) => this(endedAt: endedAt);

  @override
  PairingAttempt separatedAt(DateTime? separatedAt) =>
      this(separatedAt: separatedAt);

  @override
  PairingAttempt separationDeadline(DateTime separationDeadline) =>
      this(separationDeadline: separationDeadline);

  @override
  PairingAttempt status(PairingAttemptStatus status) => this(status: status);

  @override
  PairingAttempt result(PairingResult? result) => this(result: result);

  @override
  PairingAttempt conflictLevel(
    PairingAttemptConflictLevelEnum? conflictLevel,
  ) => this(conflictLevel: conflictLevel);

  @override
  PairingAttempt sireDestinationEnclosureId(
    String? sireDestinationEnclosureId,
  ) => this(sireDestinationEnclosureId: sireDestinationEnclosureId);

  @override
  PairingAttempt damDestinationEnclosureId(String? damDestinationEnclosureId) =>
      this(damDestinationEnclosureId: damDestinationEnclosureId);

  @override
  PairingAttempt notes(String? notes) => this(notes: notes);

  @override
  PairingAttempt version(int version) => this(version: version);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PairingAttempt(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PairingAttempt(...).copyWith(id: 12, name: "My name")
  /// ````
  PairingAttempt call({
    Object? id = const $CopyWithPlaceholder(),
    Object? breedingPlanId = const $CopyWithPlaceholder(),
    Object? sequence = const $CopyWithPlaceholder(),
    Object? enclosureId = const $CopyWithPlaceholder(),
    Object? startedAt = const $CopyWithPlaceholder(),
    Object? endedAt = const $CopyWithPlaceholder(),
    Object? separatedAt = const $CopyWithPlaceholder(),
    Object? separationDeadline = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? result = const $CopyWithPlaceholder(),
    Object? conflictLevel = const $CopyWithPlaceholder(),
    Object? sireDestinationEnclosureId = const $CopyWithPlaceholder(),
    Object? damDestinationEnclosureId = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
  }) {
    return PairingAttempt(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      breedingPlanId: breedingPlanId == const $CopyWithPlaceholder()
          ? _value.breedingPlanId
          // ignore: cast_nullable_to_non_nullable
          : breedingPlanId as String,
      sequence: sequence == const $CopyWithPlaceholder()
          ? _value.sequence
          // ignore: cast_nullable_to_non_nullable
          : sequence as int,
      enclosureId: enclosureId == const $CopyWithPlaceholder()
          ? _value.enclosureId
          // ignore: cast_nullable_to_non_nullable
          : enclosureId as String,
      startedAt: startedAt == const $CopyWithPlaceholder()
          ? _value.startedAt
          // ignore: cast_nullable_to_non_nullable
          : startedAt as DateTime,
      endedAt: endedAt == const $CopyWithPlaceholder()
          ? _value.endedAt
          // ignore: cast_nullable_to_non_nullable
          : endedAt as DateTime?,
      separatedAt: separatedAt == const $CopyWithPlaceholder()
          ? _value.separatedAt
          // ignore: cast_nullable_to_non_nullable
          : separatedAt as DateTime?,
      separationDeadline: separationDeadline == const $CopyWithPlaceholder()
          ? _value.separationDeadline
          // ignore: cast_nullable_to_non_nullable
          : separationDeadline as DateTime,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as PairingAttemptStatus,
      result: result == const $CopyWithPlaceholder()
          ? _value.result
          // ignore: cast_nullable_to_non_nullable
          : result as PairingResult?,
      conflictLevel: conflictLevel == const $CopyWithPlaceholder()
          ? _value.conflictLevel
          // ignore: cast_nullable_to_non_nullable
          : conflictLevel as PairingAttemptConflictLevelEnum?,
      sireDestinationEnclosureId:
          sireDestinationEnclosureId == const $CopyWithPlaceholder()
          ? _value.sireDestinationEnclosureId
          // ignore: cast_nullable_to_non_nullable
          : sireDestinationEnclosureId as String?,
      damDestinationEnclosureId:
          damDestinationEnclosureId == const $CopyWithPlaceholder()
          ? _value.damDestinationEnclosureId
          // ignore: cast_nullable_to_non_nullable
          : damDestinationEnclosureId as String?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
    );
  }
}

extension $PairingAttemptCopyWith on PairingAttempt {
  /// Returns a callable class that can be used as follows: `instanceOfPairingAttempt.copyWith(...)` or like so:`instanceOfPairingAttempt.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PairingAttemptCWProxy get copyWith => _$PairingAttemptCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingAttempt _$PairingAttemptFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PairingAttempt',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'breeding_plan_id',
        'sequence',
        'enclosure_id',
        'started_at',
        'separation_deadline',
        'status',
        'result',
        'version',
      ],
    );
    final val = PairingAttempt(
      id: $checkedConvert('id', (v) => v as String),
      breedingPlanId: $checkedConvert('breeding_plan_id', (v) => v as String),
      sequence: $checkedConvert('sequence', (v) => (v as num).toInt()),
      enclosureId: $checkedConvert('enclosure_id', (v) => v as String),
      startedAt: $checkedConvert(
        'started_at',
        (v) => DateTime.parse(v as String),
      ),
      endedAt: $checkedConvert(
        'ended_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      separatedAt: $checkedConvert(
        'separated_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      separationDeadline: $checkedConvert(
        'separation_deadline',
        (v) => DateTime.parse(v as String),
      ),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$PairingAttemptStatusEnumMap, v),
      ),
      result: $checkedConvert(
        'result',
        (v) => $enumDecodeNullable(_$PairingResultEnumMap, v),
      ),
      conflictLevel: $checkedConvert(
        'conflict_level',
        (v) => $enumDecodeNullable(_$PairingAttemptConflictLevelEnumEnumMap, v),
      ),
      sireDestinationEnclosureId: $checkedConvert(
        'sire_destination_enclosure_id',
        (v) => v as String?,
      ),
      damDestinationEnclosureId: $checkedConvert(
        'dam_destination_enclosure_id',
        (v) => v as String?,
      ),
      notes: $checkedConvert('notes', (v) => v as String?),
      version: $checkedConvert('version', (v) => (v as num).toInt()),
    );
    return val;
  },
  fieldKeyMap: const {
    'breedingPlanId': 'breeding_plan_id',
    'enclosureId': 'enclosure_id',
    'startedAt': 'started_at',
    'endedAt': 'ended_at',
    'separatedAt': 'separated_at',
    'separationDeadline': 'separation_deadline',
    'conflictLevel': 'conflict_level',
    'sireDestinationEnclosureId': 'sire_destination_enclosure_id',
    'damDestinationEnclosureId': 'dam_destination_enclosure_id',
  },
);

Map<String, dynamic> _$PairingAttemptToJson(PairingAttempt instance) =>
    <String, dynamic>{
      'id': instance.id,
      'breeding_plan_id': instance.breedingPlanId,
      'sequence': instance.sequence,
      'enclosure_id': instance.enclosureId,
      'started_at': instance.startedAt.toIso8601String(),
      'ended_at': ?instance.endedAt?.toIso8601String(),
      'separated_at': ?instance.separatedAt?.toIso8601String(),
      'separation_deadline': instance.separationDeadline.toIso8601String(),
      'status': _$PairingAttemptStatusEnumMap[instance.status]!,
      'result': _$PairingResultEnumMap[instance.result],
      'conflict_level':
          ?_$PairingAttemptConflictLevelEnumEnumMap[instance.conflictLevel],
      'sire_destination_enclosure_id': ?instance.sireDestinationEnclosureId,
      'dam_destination_enclosure_id': ?instance.damDestinationEnclosureId,
      'notes': ?instance.notes,
      'version': instance.version,
    };

const _$PairingAttemptStatusEnumMap = {
  PairingAttemptStatus.active: 'active',
  PairingAttemptStatus.separated: 'separated',
  PairingAttemptStatus.safetyHold: 'safety_hold',
  PairingAttemptStatus.cancelled: 'cancelled',
};

const _$PairingResultEnumMap = {
  PairingResult.effective: 'effective',
  PairingResult.uncertain: 'uncertain',
  PairingResult.ineffective: 'ineffective',
  PairingResult.safetyStop: 'safety_stop',
};

const _$PairingAttemptConflictLevelEnumEnumMap = {
  PairingAttemptConflictLevelEnum.low: 'low',
  PairingAttemptConflictLevelEnum.medium: 'medium',
  PairingAttemptConflictLevelEnum.high: 'high',
  PairingAttemptConflictLevelEnum.critical: 'critical',
};
