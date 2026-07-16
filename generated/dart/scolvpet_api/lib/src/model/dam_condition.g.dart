// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dam_condition.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DamConditionCWProxy {
  DamCondition status(DamConditionStatusEnum status);

  DamCondition structuredChecks(Map<String, Object>? structuredChecks);

  DamCondition notes(String? notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DamCondition(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DamCondition(...).copyWith(id: 12, name: "My name")
  /// ````
  DamCondition call({
    DamConditionStatusEnum status,
    Map<String, Object>? structuredChecks,
    String? notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDamCondition.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDamCondition.copyWith.fieldName(...)`
class _$DamConditionCWProxyImpl implements _$DamConditionCWProxy {
  const _$DamConditionCWProxyImpl(this._value);

  final DamCondition _value;

  @override
  DamCondition status(DamConditionStatusEnum status) => this(status: status);

  @override
  DamCondition structuredChecks(Map<String, Object>? structuredChecks) =>
      this(structuredChecks: structuredChecks);

  @override
  DamCondition notes(String? notes) => this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DamCondition(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DamCondition(...).copyWith(id: 12, name: "My name")
  /// ````
  DamCondition call({
    Object? status = const $CopyWithPlaceholder(),
    Object? structuredChecks = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return DamCondition(
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as DamConditionStatusEnum,
      structuredChecks: structuredChecks == const $CopyWithPlaceholder()
          ? _value.structuredChecks
          // ignore: cast_nullable_to_non_nullable
          : structuredChecks as Map<String, Object>?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
    );
  }
}

extension $DamConditionCopyWith on DamCondition {
  /// Returns a callable class that can be used as follows: `instanceOfDamCondition.copyWith(...)` or like so:`instanceOfDamCondition.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DamConditionCWProxy get copyWith => _$DamConditionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DamCondition _$DamConditionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DamCondition', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['status']);
      final val = DamCondition(
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$DamConditionStatusEnumEnumMap, v),
        ),
        structuredChecks: $checkedConvert(
          'structured_checks',
          (v) => (v as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as Object),
          ),
        ),
        notes: $checkedConvert('notes', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'structuredChecks': 'structured_checks'});

Map<String, dynamic> _$DamConditionToJson(DamCondition instance) =>
    <String, dynamic>{
      'status': _$DamConditionStatusEnumEnumMap[instance.status]!,
      'structured_checks': ?instance.structuredChecks,
      'notes': ?instance.notes,
    };

const _$DamConditionStatusEnumEnumMap = {
  DamConditionStatusEnum.stable: 'stable',
  DamConditionStatusEnum.needsObservation: 'needs_observation',
  DamConditionStatusEnum.requiresCare: 'requires_care',
  DamConditionStatusEnum.deceased: 'deceased',
};
