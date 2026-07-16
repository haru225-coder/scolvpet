// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirm_birth_live_litter_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ConfirmBirthLiveLitterDataCWProxy {
  ConfirmBirthLiveLitterData resultType(
    ConfirmBirthLiveLitterDataResultTypeEnum resultType,
  );

  ConfirmBirthLiveLitterData breedingPlan(BreedingPlan breedingPlan);

  ConfirmBirthLiveLitterData litter(Litter litter);

  ConfirmBirthLiveLitterData pupIdentityCount(int pupIdentityCount);

  ConfirmBirthLiveLitterData pupIdentities(List<PupIdentity> pupIdentities);

  ConfirmBirthLiveLitterData initialCountEvent(
    LitterCountEvent initialCountEvent,
  );

  ConfirmBirthLiveLitterData celebrationJob(AsyncJob? celebrationJob);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConfirmBirthLiveLitterData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConfirmBirthLiveLitterData(...).copyWith(id: 12, name: "My name")
  /// ````
  ConfirmBirthLiveLitterData call({
    ConfirmBirthLiveLitterDataResultTypeEnum resultType,
    BreedingPlan breedingPlan,
    Litter litter,
    int pupIdentityCount,
    List<PupIdentity> pupIdentities,
    LitterCountEvent initialCountEvent,
    AsyncJob? celebrationJob,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfConfirmBirthLiveLitterData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfConfirmBirthLiveLitterData.copyWith.fieldName(...)`
class _$ConfirmBirthLiveLitterDataCWProxyImpl
    implements _$ConfirmBirthLiveLitterDataCWProxy {
  const _$ConfirmBirthLiveLitterDataCWProxyImpl(this._value);

  final ConfirmBirthLiveLitterData _value;

  @override
  ConfirmBirthLiveLitterData resultType(
    ConfirmBirthLiveLitterDataResultTypeEnum resultType,
  ) => this(resultType: resultType);

  @override
  ConfirmBirthLiveLitterData breedingPlan(BreedingPlan breedingPlan) =>
      this(breedingPlan: breedingPlan);

  @override
  ConfirmBirthLiveLitterData litter(Litter litter) => this(litter: litter);

  @override
  ConfirmBirthLiveLitterData pupIdentityCount(int pupIdentityCount) =>
      this(pupIdentityCount: pupIdentityCount);

  @override
  ConfirmBirthLiveLitterData pupIdentities(List<PupIdentity> pupIdentities) =>
      this(pupIdentities: pupIdentities);

  @override
  ConfirmBirthLiveLitterData initialCountEvent(
    LitterCountEvent initialCountEvent,
  ) => this(initialCountEvent: initialCountEvent);

  @override
  ConfirmBirthLiveLitterData celebrationJob(AsyncJob? celebrationJob) =>
      this(celebrationJob: celebrationJob);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConfirmBirthLiveLitterData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConfirmBirthLiveLitterData(...).copyWith(id: 12, name: "My name")
  /// ````
  ConfirmBirthLiveLitterData call({
    Object? resultType = const $CopyWithPlaceholder(),
    Object? breedingPlan = const $CopyWithPlaceholder(),
    Object? litter = const $CopyWithPlaceholder(),
    Object? pupIdentityCount = const $CopyWithPlaceholder(),
    Object? pupIdentities = const $CopyWithPlaceholder(),
    Object? initialCountEvent = const $CopyWithPlaceholder(),
    Object? celebrationJob = const $CopyWithPlaceholder(),
  }) {
    return ConfirmBirthLiveLitterData(
      resultType: resultType == const $CopyWithPlaceholder()
          ? _value.resultType
          // ignore: cast_nullable_to_non_nullable
          : resultType as ConfirmBirthLiveLitterDataResultTypeEnum,
      breedingPlan: breedingPlan == const $CopyWithPlaceholder()
          ? _value.breedingPlan
          // ignore: cast_nullable_to_non_nullable
          : breedingPlan as BreedingPlan,
      litter: litter == const $CopyWithPlaceholder()
          ? _value.litter
          // ignore: cast_nullable_to_non_nullable
          : litter as Litter,
      pupIdentityCount: pupIdentityCount == const $CopyWithPlaceholder()
          ? _value.pupIdentityCount
          // ignore: cast_nullable_to_non_nullable
          : pupIdentityCount as int,
      pupIdentities: pupIdentities == const $CopyWithPlaceholder()
          ? _value.pupIdentities
          // ignore: cast_nullable_to_non_nullable
          : pupIdentities as List<PupIdentity>,
      initialCountEvent: initialCountEvent == const $CopyWithPlaceholder()
          ? _value.initialCountEvent
          // ignore: cast_nullable_to_non_nullable
          : initialCountEvent as LitterCountEvent,
      celebrationJob: celebrationJob == const $CopyWithPlaceholder()
          ? _value.celebrationJob
          // ignore: cast_nullable_to_non_nullable
          : celebrationJob as AsyncJob?,
    );
  }
}

extension $ConfirmBirthLiveLitterDataCopyWith on ConfirmBirthLiveLitterData {
  /// Returns a callable class that can be used as follows: `instanceOfConfirmBirthLiveLitterData.copyWith(...)` or like so:`instanceOfConfirmBirthLiveLitterData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ConfirmBirthLiveLitterDataCWProxy get copyWith =>
      _$ConfirmBirthLiveLitterDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfirmBirthLiveLitterData _$ConfirmBirthLiveLitterDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ConfirmBirthLiveLitterData',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'result_type',
        'breeding_plan',
        'litter',
        'pup_identity_count',
        'pup_identities',
        'initial_count_event',
      ],
    );
    final val = ConfirmBirthLiveLitterData(
      resultType: $checkedConvert(
        'result_type',
        (v) =>
            $enumDecode(_$ConfirmBirthLiveLitterDataResultTypeEnumEnumMap, v),
      ),
      breedingPlan: $checkedConvert(
        'breeding_plan',
        (v) => BreedingPlan.fromJson(v as Map<String, dynamic>),
      ),
      litter: $checkedConvert(
        'litter',
        (v) => Litter.fromJson(v as Map<String, dynamic>),
      ),
      pupIdentityCount: $checkedConvert(
        'pup_identity_count',
        (v) => (v as num).toInt(),
      ),
      pupIdentities: $checkedConvert(
        'pup_identities',
        (v) => (v as List<dynamic>)
            .map((e) => PupIdentity.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      initialCountEvent: $checkedConvert(
        'initial_count_event',
        (v) => LitterCountEvent.fromJson(v as Map<String, dynamic>),
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
    'pupIdentityCount': 'pup_identity_count',
    'pupIdentities': 'pup_identities',
    'initialCountEvent': 'initial_count_event',
    'celebrationJob': 'celebration_job',
  },
);

Map<String, dynamic> _$ConfirmBirthLiveLitterDataToJson(
  ConfirmBirthLiveLitterData instance,
) => <String, dynamic>{
  'result_type':
      _$ConfirmBirthLiveLitterDataResultTypeEnumEnumMap[instance.resultType]!,
  'breeding_plan': instance.breedingPlan.toJson(),
  'litter': instance.litter.toJson(),
  'pup_identity_count': instance.pupIdentityCount,
  'pup_identities': instance.pupIdentities.map((e) => e.toJson()).toList(),
  'initial_count_event': instance.initialCountEvent.toJson(),
  'celebration_job': ?instance.celebrationJob?.toJson(),
};

const _$ConfirmBirthLiveLitterDataResultTypeEnumEnumMap = {
  ConfirmBirthLiveLitterDataResultTypeEnum.liveLitter: 'live_litter',
};
