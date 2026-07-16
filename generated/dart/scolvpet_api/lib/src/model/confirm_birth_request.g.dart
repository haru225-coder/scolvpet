// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirm_birth_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ConfirmBirthRequestCWProxy {
  ConfirmBirthRequest bornAt(DateTime bornAt);

  ConfirmBirthRequest enclosureId(String? enclosureId);

  ConfirmBirthRequest initialAliveCount(int initialAliveCount);

  ConfirmBirthRequest initialOtherCount(int initialOtherCount);

  ConfirmBirthRequest damCondition(DamCondition damCondition);

  ConfirmBirthRequest outcomeReason(String outcomeReason);

  ConfirmBirthRequest temporaryCodePrefix(String? temporaryCodePrefix);

  ConfirmBirthRequest temporaryCodes(Set<String>? temporaryCodes);

  ConfirmBirthRequest timezone(String timezone);

  ConfirmBirthRequest notes(String? notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConfirmBirthRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConfirmBirthRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ConfirmBirthRequest call({
    DateTime bornAt,
    String? enclosureId,
    int initialAliveCount,
    int initialOtherCount,
    DamCondition damCondition,
    String outcomeReason,
    String? temporaryCodePrefix,
    Set<String>? temporaryCodes,
    String timezone,
    String? notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfConfirmBirthRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfConfirmBirthRequest.copyWith.fieldName(...)`
class _$ConfirmBirthRequestCWProxyImpl implements _$ConfirmBirthRequestCWProxy {
  const _$ConfirmBirthRequestCWProxyImpl(this._value);

  final ConfirmBirthRequest _value;

  @override
  ConfirmBirthRequest bornAt(DateTime bornAt) => this(bornAt: bornAt);

  @override
  ConfirmBirthRequest enclosureId(String? enclosureId) =>
      this(enclosureId: enclosureId);

  @override
  ConfirmBirthRequest initialAliveCount(int initialAliveCount) =>
      this(initialAliveCount: initialAliveCount);

  @override
  ConfirmBirthRequest initialOtherCount(int initialOtherCount) =>
      this(initialOtherCount: initialOtherCount);

  @override
  ConfirmBirthRequest damCondition(DamCondition damCondition) =>
      this(damCondition: damCondition);

  @override
  ConfirmBirthRequest outcomeReason(String outcomeReason) =>
      this(outcomeReason: outcomeReason);

  @override
  ConfirmBirthRequest temporaryCodePrefix(String? temporaryCodePrefix) =>
      this(temporaryCodePrefix: temporaryCodePrefix);

  @override
  ConfirmBirthRequest temporaryCodes(Set<String>? temporaryCodes) =>
      this(temporaryCodes: temporaryCodes);

  @override
  ConfirmBirthRequest timezone(String timezone) => this(timezone: timezone);

  @override
  ConfirmBirthRequest notes(String? notes) => this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConfirmBirthRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConfirmBirthRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ConfirmBirthRequest call({
    Object? bornAt = const $CopyWithPlaceholder(),
    Object? enclosureId = const $CopyWithPlaceholder(),
    Object? initialAliveCount = const $CopyWithPlaceholder(),
    Object? initialOtherCount = const $CopyWithPlaceholder(),
    Object? damCondition = const $CopyWithPlaceholder(),
    Object? outcomeReason = const $CopyWithPlaceholder(),
    Object? temporaryCodePrefix = const $CopyWithPlaceholder(),
    Object? temporaryCodes = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return ConfirmBirthRequest(
      bornAt: bornAt == const $CopyWithPlaceholder()
          ? _value.bornAt
          // ignore: cast_nullable_to_non_nullable
          : bornAt as DateTime,
      enclosureId: enclosureId == const $CopyWithPlaceholder()
          ? _value.enclosureId
          // ignore: cast_nullable_to_non_nullable
          : enclosureId as String?,
      initialAliveCount: initialAliveCount == const $CopyWithPlaceholder()
          ? _value.initialAliveCount
          // ignore: cast_nullable_to_non_nullable
          : initialAliveCount as int,
      initialOtherCount: initialOtherCount == const $CopyWithPlaceholder()
          ? _value.initialOtherCount
          // ignore: cast_nullable_to_non_nullable
          : initialOtherCount as int,
      damCondition: damCondition == const $CopyWithPlaceholder()
          ? _value.damCondition
          // ignore: cast_nullable_to_non_nullable
          : damCondition as DamCondition,
      outcomeReason: outcomeReason == const $CopyWithPlaceholder()
          ? _value.outcomeReason
          // ignore: cast_nullable_to_non_nullable
          : outcomeReason as String,
      temporaryCodePrefix: temporaryCodePrefix == const $CopyWithPlaceholder()
          ? _value.temporaryCodePrefix
          // ignore: cast_nullable_to_non_nullable
          : temporaryCodePrefix as String?,
      temporaryCodes: temporaryCodes == const $CopyWithPlaceholder()
          ? _value.temporaryCodes
          // ignore: cast_nullable_to_non_nullable
          : temporaryCodes as Set<String>?,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
    );
  }
}

extension $ConfirmBirthRequestCopyWith on ConfirmBirthRequest {
  /// Returns a callable class that can be used as follows: `instanceOfConfirmBirthRequest.copyWith(...)` or like so:`instanceOfConfirmBirthRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ConfirmBirthRequestCWProxy get copyWith =>
      _$ConfirmBirthRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfirmBirthRequest _$ConfirmBirthRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ConfirmBirthRequest',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'born_at',
            'initial_alive_count',
            'initial_other_count',
            'dam_condition',
            'outcome_reason',
            'timezone',
          ],
        );
        final val = ConfirmBirthRequest(
          bornAt: $checkedConvert(
            'born_at',
            (v) => DateTime.parse(v as String),
          ),
          enclosureId: $checkedConvert('enclosure_id', (v) => v as String?),
          initialAliveCount: $checkedConvert(
            'initial_alive_count',
            (v) => (v as num).toInt(),
          ),
          initialOtherCount: $checkedConvert(
            'initial_other_count',
            (v) => (v as num).toInt(),
          ),
          damCondition: $checkedConvert(
            'dam_condition',
            (v) => DamCondition.fromJson(v as Map<String, dynamic>),
          ),
          outcomeReason: $checkedConvert('outcome_reason', (v) => v as String),
          temporaryCodePrefix: $checkedConvert(
            'temporary_code_prefix',
            (v) => v as String?,
          ),
          temporaryCodes: $checkedConvert(
            'temporary_codes',
            (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet(),
          ),
          timezone: $checkedConvert('timezone', (v) => v as String),
          notes: $checkedConvert('notes', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'bornAt': 'born_at',
        'enclosureId': 'enclosure_id',
        'initialAliveCount': 'initial_alive_count',
        'initialOtherCount': 'initial_other_count',
        'damCondition': 'dam_condition',
        'outcomeReason': 'outcome_reason',
        'temporaryCodePrefix': 'temporary_code_prefix',
        'temporaryCodes': 'temporary_codes',
      },
    );

Map<String, dynamic> _$ConfirmBirthRequestToJson(
  ConfirmBirthRequest instance,
) => <String, dynamic>{
  'born_at': instance.bornAt.toIso8601String(),
  'enclosure_id': ?instance.enclosureId,
  'initial_alive_count': instance.initialAliveCount,
  'initial_other_count': instance.initialOtherCount,
  'dam_condition': instance.damCondition.toJson(),
  'outcome_reason': instance.outcomeReason,
  'temporary_code_prefix': ?instance.temporaryCodePrefix,
  'temporary_codes': ?instance.temporaryCodes?.toList(),
  'timezone': instance.timezone,
  'notes': ?instance.notes,
};
