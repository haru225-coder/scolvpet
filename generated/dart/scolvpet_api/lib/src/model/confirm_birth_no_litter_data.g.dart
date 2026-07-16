// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirm_birth_no_litter_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ConfirmBirthNoLitterDataCWProxy {
  ConfirmBirthNoLitterData resultType(
    ConfirmBirthNoLitterDataResultTypeEnum resultType,
  );

  ConfirmBirthNoLitterData breedingPlan(BreedingPlan breedingPlan);

  ConfirmBirthNoLitterData birthEventId(String birthEventId);

  ConfirmBirthNoLitterData eventType(
    ConfirmBirthNoLitterDataEventTypeEnum eventType,
  );

  ConfirmBirthNoLitterData bornAt(DateTime bornAt);

  ConfirmBirthNoLitterData initialOtherCount(int initialOtherCount);

  ConfirmBirthNoLitterData outcomeReason(String outcomeReason);

  ConfirmBirthNoLitterData damCondition(DamCondition damCondition);

  ConfirmBirthNoLitterData celebrationJob(AsyncJob? celebrationJob);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConfirmBirthNoLitterData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConfirmBirthNoLitterData(...).copyWith(id: 12, name: "My name")
  /// ````
  ConfirmBirthNoLitterData call({
    ConfirmBirthNoLitterDataResultTypeEnum resultType,
    BreedingPlan breedingPlan,
    String birthEventId,
    ConfirmBirthNoLitterDataEventTypeEnum eventType,
    DateTime bornAt,
    int initialOtherCount,
    String outcomeReason,
    DamCondition damCondition,
    AsyncJob? celebrationJob,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfConfirmBirthNoLitterData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfConfirmBirthNoLitterData.copyWith.fieldName(...)`
class _$ConfirmBirthNoLitterDataCWProxyImpl
    implements _$ConfirmBirthNoLitterDataCWProxy {
  const _$ConfirmBirthNoLitterDataCWProxyImpl(this._value);

  final ConfirmBirthNoLitterData _value;

  @override
  ConfirmBirthNoLitterData resultType(
    ConfirmBirthNoLitterDataResultTypeEnum resultType,
  ) => this(resultType: resultType);

  @override
  ConfirmBirthNoLitterData breedingPlan(BreedingPlan breedingPlan) =>
      this(breedingPlan: breedingPlan);

  @override
  ConfirmBirthNoLitterData birthEventId(String birthEventId) =>
      this(birthEventId: birthEventId);

  @override
  ConfirmBirthNoLitterData eventType(
    ConfirmBirthNoLitterDataEventTypeEnum eventType,
  ) => this(eventType: eventType);

  @override
  ConfirmBirthNoLitterData bornAt(DateTime bornAt) => this(bornAt: bornAt);

  @override
  ConfirmBirthNoLitterData initialOtherCount(int initialOtherCount) =>
      this(initialOtherCount: initialOtherCount);

  @override
  ConfirmBirthNoLitterData outcomeReason(String outcomeReason) =>
      this(outcomeReason: outcomeReason);

  @override
  ConfirmBirthNoLitterData damCondition(DamCondition damCondition) =>
      this(damCondition: damCondition);

  @override
  ConfirmBirthNoLitterData celebrationJob(AsyncJob? celebrationJob) =>
      this(celebrationJob: celebrationJob);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConfirmBirthNoLitterData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConfirmBirthNoLitterData(...).copyWith(id: 12, name: "My name")
  /// ````
  ConfirmBirthNoLitterData call({
    Object? resultType = const $CopyWithPlaceholder(),
    Object? breedingPlan = const $CopyWithPlaceholder(),
    Object? birthEventId = const $CopyWithPlaceholder(),
    Object? eventType = const $CopyWithPlaceholder(),
    Object? bornAt = const $CopyWithPlaceholder(),
    Object? initialOtherCount = const $CopyWithPlaceholder(),
    Object? outcomeReason = const $CopyWithPlaceholder(),
    Object? damCondition = const $CopyWithPlaceholder(),
    Object? celebrationJob = const $CopyWithPlaceholder(),
  }) {
    return ConfirmBirthNoLitterData(
      resultType: resultType == const $CopyWithPlaceholder()
          ? _value.resultType
          // ignore: cast_nullable_to_non_nullable
          : resultType as ConfirmBirthNoLitterDataResultTypeEnum,
      breedingPlan: breedingPlan == const $CopyWithPlaceholder()
          ? _value.breedingPlan
          // ignore: cast_nullable_to_non_nullable
          : breedingPlan as BreedingPlan,
      birthEventId: birthEventId == const $CopyWithPlaceholder()
          ? _value.birthEventId
          // ignore: cast_nullable_to_non_nullable
          : birthEventId as String,
      eventType: eventType == const $CopyWithPlaceholder()
          ? _value.eventType
          // ignore: cast_nullable_to_non_nullable
          : eventType as ConfirmBirthNoLitterDataEventTypeEnum,
      bornAt: bornAt == const $CopyWithPlaceholder()
          ? _value.bornAt
          // ignore: cast_nullable_to_non_nullable
          : bornAt as DateTime,
      initialOtherCount: initialOtherCount == const $CopyWithPlaceholder()
          ? _value.initialOtherCount
          // ignore: cast_nullable_to_non_nullable
          : initialOtherCount as int,
      outcomeReason: outcomeReason == const $CopyWithPlaceholder()
          ? _value.outcomeReason
          // ignore: cast_nullable_to_non_nullable
          : outcomeReason as String,
      damCondition: damCondition == const $CopyWithPlaceholder()
          ? _value.damCondition
          // ignore: cast_nullable_to_non_nullable
          : damCondition as DamCondition,
      celebrationJob: celebrationJob == const $CopyWithPlaceholder()
          ? _value.celebrationJob
          // ignore: cast_nullable_to_non_nullable
          : celebrationJob as AsyncJob?,
    );
  }
}

extension $ConfirmBirthNoLitterDataCopyWith on ConfirmBirthNoLitterData {
  /// Returns a callable class that can be used as follows: `instanceOfConfirmBirthNoLitterData.copyWith(...)` or like so:`instanceOfConfirmBirthNoLitterData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ConfirmBirthNoLitterDataCWProxy get copyWith =>
      _$ConfirmBirthNoLitterDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfirmBirthNoLitterData _$ConfirmBirthNoLitterDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ConfirmBirthNoLitterData',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'result_type',
        'breeding_plan',
        'birth_event_id',
        'event_type',
        'born_at',
        'initial_other_count',
        'outcome_reason',
        'dam_condition',
      ],
    );
    final val = ConfirmBirthNoLitterData(
      resultType: $checkedConvert(
        'result_type',
        (v) => $enumDecode(_$ConfirmBirthNoLitterDataResultTypeEnumEnumMap, v),
      ),
      breedingPlan: $checkedConvert(
        'breeding_plan',
        (v) => BreedingPlan.fromJson(v as Map<String, dynamic>),
      ),
      birthEventId: $checkedConvert('birth_event_id', (v) => v as String),
      eventType: $checkedConvert(
        'event_type',
        (v) => $enumDecode(_$ConfirmBirthNoLitterDataEventTypeEnumEnumMap, v),
      ),
      bornAt: $checkedConvert('born_at', (v) => DateTime.parse(v as String)),
      initialOtherCount: $checkedConvert(
        'initial_other_count',
        (v) => (v as num).toInt(),
      ),
      outcomeReason: $checkedConvert('outcome_reason', (v) => v as String),
      damCondition: $checkedConvert(
        'dam_condition',
        (v) => DamCondition.fromJson(v as Map<String, dynamic>),
      ),
      celebrationJob: $checkedConvert(
        'celebration_job',
        (v) => v == null ? null : AsyncJob.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'resultType': 'result_type',
    'breedingPlan': 'breeding_plan',
    'birthEventId': 'birth_event_id',
    'eventType': 'event_type',
    'bornAt': 'born_at',
    'initialOtherCount': 'initial_other_count',
    'outcomeReason': 'outcome_reason',
    'damCondition': 'dam_condition',
    'celebrationJob': 'celebration_job',
  },
);

Map<String, dynamic> _$ConfirmBirthNoLitterDataToJson(
  ConfirmBirthNoLitterData instance,
) => <String, dynamic>{
  'result_type':
      _$ConfirmBirthNoLitterDataResultTypeEnumEnumMap[instance.resultType]!,
  'breeding_plan': instance.breedingPlan.toJson(),
  'birth_event_id': instance.birthEventId,
  'event_type':
      _$ConfirmBirthNoLitterDataEventTypeEnumEnumMap[instance.eventType]!,
  'born_at': instance.bornAt.toIso8601String(),
  'initial_other_count': instance.initialOtherCount,
  'outcome_reason': instance.outcomeReason,
  'dam_condition': instance.damCondition.toJson(),
  'celebration_job': ?instance.celebrationJob?.toJson(),
};

const _$ConfirmBirthNoLitterDataResultTypeEnumEnumMap = {
  ConfirmBirthNoLitterDataResultTypeEnum.noLitterOutcome: 'no_litter_outcome',
};

const _$ConfirmBirthNoLitterDataEventTypeEnumEnumMap = {
  ConfirmBirthNoLitterDataEventTypeEnum.BIRTH_CONFIRMED_NO_LIVE_PUPS:
      'BIRTH_CONFIRMED_NO_LIVE_PUPS',
};
