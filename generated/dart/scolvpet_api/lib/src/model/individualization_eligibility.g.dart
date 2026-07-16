// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'individualization_eligibility.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$IndividualizationEligibilityCWProxy {
  IndividualizationEligibility litterId(String litterId);

  IndividualizationEligibility litterVersion(int litterVersion);

  IndividualizationEligibility eligibleSetToken(String eligibleSetToken);

  IndividualizationEligibility eligiblePupIdentityIds(
    Set<String> eligiblePupIdentityIds,
  );

  IndividualizationEligibility eligibleCount(int eligibleCount);

  IndividualizationEligibility blockers(
    List<IndividualizationEligibilityBlocker> blockers,
  );

  IndividualizationEligibility canIndividualize(bool canIndividualize);

  IndividualizationEligibility computedAt(DateTime computedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IndividualizationEligibility(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IndividualizationEligibility(...).copyWith(id: 12, name: "My name")
  /// ````
  IndividualizationEligibility call({
    String litterId,
    int litterVersion,
    String eligibleSetToken,
    Set<String> eligiblePupIdentityIds,
    int eligibleCount,
    List<IndividualizationEligibilityBlocker> blockers,
    bool canIndividualize,
    DateTime computedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfIndividualizationEligibility.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfIndividualizationEligibility.copyWith.fieldName(...)`
class _$IndividualizationEligibilityCWProxyImpl
    implements _$IndividualizationEligibilityCWProxy {
  const _$IndividualizationEligibilityCWProxyImpl(this._value);

  final IndividualizationEligibility _value;

  @override
  IndividualizationEligibility litterId(String litterId) =>
      this(litterId: litterId);

  @override
  IndividualizationEligibility litterVersion(int litterVersion) =>
      this(litterVersion: litterVersion);

  @override
  IndividualizationEligibility eligibleSetToken(String eligibleSetToken) =>
      this(eligibleSetToken: eligibleSetToken);

  @override
  IndividualizationEligibility eligiblePupIdentityIds(
    Set<String> eligiblePupIdentityIds,
  ) => this(eligiblePupIdentityIds: eligiblePupIdentityIds);

  @override
  IndividualizationEligibility eligibleCount(int eligibleCount) =>
      this(eligibleCount: eligibleCount);

  @override
  IndividualizationEligibility blockers(
    List<IndividualizationEligibilityBlocker> blockers,
  ) => this(blockers: blockers);

  @override
  IndividualizationEligibility canIndividualize(bool canIndividualize) =>
      this(canIndividualize: canIndividualize);

  @override
  IndividualizationEligibility computedAt(DateTime computedAt) =>
      this(computedAt: computedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IndividualizationEligibility(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IndividualizationEligibility(...).copyWith(id: 12, name: "My name")
  /// ````
  IndividualizationEligibility call({
    Object? litterId = const $CopyWithPlaceholder(),
    Object? litterVersion = const $CopyWithPlaceholder(),
    Object? eligibleSetToken = const $CopyWithPlaceholder(),
    Object? eligiblePupIdentityIds = const $CopyWithPlaceholder(),
    Object? eligibleCount = const $CopyWithPlaceholder(),
    Object? blockers = const $CopyWithPlaceholder(),
    Object? canIndividualize = const $CopyWithPlaceholder(),
    Object? computedAt = const $CopyWithPlaceholder(),
  }) {
    return IndividualizationEligibility(
      litterId: litterId == const $CopyWithPlaceholder()
          ? _value.litterId
          // ignore: cast_nullable_to_non_nullable
          : litterId as String,
      litterVersion: litterVersion == const $CopyWithPlaceholder()
          ? _value.litterVersion
          // ignore: cast_nullable_to_non_nullable
          : litterVersion as int,
      eligibleSetToken: eligibleSetToken == const $CopyWithPlaceholder()
          ? _value.eligibleSetToken
          // ignore: cast_nullable_to_non_nullable
          : eligibleSetToken as String,
      eligiblePupIdentityIds:
          eligiblePupIdentityIds == const $CopyWithPlaceholder()
          ? _value.eligiblePupIdentityIds
          // ignore: cast_nullable_to_non_nullable
          : eligiblePupIdentityIds as Set<String>,
      eligibleCount: eligibleCount == const $CopyWithPlaceholder()
          ? _value.eligibleCount
          // ignore: cast_nullable_to_non_nullable
          : eligibleCount as int,
      blockers: blockers == const $CopyWithPlaceholder()
          ? _value.blockers
          // ignore: cast_nullable_to_non_nullable
          : blockers as List<IndividualizationEligibilityBlocker>,
      canIndividualize: canIndividualize == const $CopyWithPlaceholder()
          ? _value.canIndividualize
          // ignore: cast_nullable_to_non_nullable
          : canIndividualize as bool,
      computedAt: computedAt == const $CopyWithPlaceholder()
          ? _value.computedAt
          // ignore: cast_nullable_to_non_nullable
          : computedAt as DateTime,
    );
  }
}

extension $IndividualizationEligibilityCopyWith
    on IndividualizationEligibility {
  /// Returns a callable class that can be used as follows: `instanceOfIndividualizationEligibility.copyWith(...)` or like so:`instanceOfIndividualizationEligibility.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$IndividualizationEligibilityCWProxy get copyWith =>
      _$IndividualizationEligibilityCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IndividualizationEligibility _$IndividualizationEligibilityFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'IndividualizationEligibility',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'litter_id',
        'litter_version',
        'eligible_set_token',
        'eligible_pup_identity_ids',
        'eligible_count',
        'blockers',
        'can_individualize',
        'computed_at',
      ],
    );
    final val = IndividualizationEligibility(
      litterId: $checkedConvert('litter_id', (v) => v as String),
      litterVersion: $checkedConvert(
        'litter_version',
        (v) => (v as num).toInt(),
      ),
      eligibleSetToken: $checkedConvert(
        'eligible_set_token',
        (v) => v as String,
      ),
      eligiblePupIdentityIds: $checkedConvert(
        'eligible_pup_identity_ids',
        (v) => (v as List<dynamic>).map((e) => e as String).toSet(),
      ),
      eligibleCount: $checkedConvert(
        'eligible_count',
        (v) => (v as num).toInt(),
      ),
      blockers: $checkedConvert(
        'blockers',
        (v) => (v as List<dynamic>)
            .map(
              (e) => IndividualizationEligibilityBlocker.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList(),
      ),
      canIndividualize: $checkedConvert('can_individualize', (v) => v as bool),
      computedAt: $checkedConvert(
        'computed_at',
        (v) => DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'litterId': 'litter_id',
    'litterVersion': 'litter_version',
    'eligibleSetToken': 'eligible_set_token',
    'eligiblePupIdentityIds': 'eligible_pup_identity_ids',
    'eligibleCount': 'eligible_count',
    'canIndividualize': 'can_individualize',
    'computedAt': 'computed_at',
  },
);

Map<String, dynamic> _$IndividualizationEligibilityToJson(
  IndividualizationEligibility instance,
) => <String, dynamic>{
  'litter_id': instance.litterId,
  'litter_version': instance.litterVersion,
  'eligible_set_token': instance.eligibleSetToken,
  'eligible_pup_identity_ids': instance.eligiblePupIdentityIds.toList(),
  'eligible_count': instance.eligibleCount,
  'blockers': instance.blockers.map((e) => e.toJson()).toList(),
  'can_individualize': instance.canIndividualize,
  'computed_at': instance.computedAt.toIso8601String(),
};
