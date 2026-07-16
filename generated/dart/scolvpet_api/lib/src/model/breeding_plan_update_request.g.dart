// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breeding_plan_update_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BreedingPlanUpdateRequestCWProxy {
  BreedingPlanUpdateRequest name(String? name);

  BreedingPlanUpdateRequest sireId(String? sireId);

  BreedingPlanUpdateRequest damId(String? damId);

  BreedingPlanUpdateRequest ruleVersionId(String? ruleVersionId);

  BreedingPlanUpdateRequest plannedPairingAt(DateTime? plannedPairingAt);

  BreedingPlanUpdateRequest objectiveTraits(
    Map<String, Object>? objectiveTraits,
  );

  BreedingPlanUpdateRequest notes(String? notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BreedingPlanUpdateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BreedingPlanUpdateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  BreedingPlanUpdateRequest call({
    String? name,
    String? sireId,
    String? damId,
    String? ruleVersionId,
    DateTime? plannedPairingAt,
    Map<String, Object>? objectiveTraits,
    String? notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBreedingPlanUpdateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBreedingPlanUpdateRequest.copyWith.fieldName(...)`
class _$BreedingPlanUpdateRequestCWProxyImpl
    implements _$BreedingPlanUpdateRequestCWProxy {
  const _$BreedingPlanUpdateRequestCWProxyImpl(this._value);

  final BreedingPlanUpdateRequest _value;

  @override
  BreedingPlanUpdateRequest name(String? name) => this(name: name);

  @override
  BreedingPlanUpdateRequest sireId(String? sireId) => this(sireId: sireId);

  @override
  BreedingPlanUpdateRequest damId(String? damId) => this(damId: damId);

  @override
  BreedingPlanUpdateRequest ruleVersionId(String? ruleVersionId) =>
      this(ruleVersionId: ruleVersionId);

  @override
  BreedingPlanUpdateRequest plannedPairingAt(DateTime? plannedPairingAt) =>
      this(plannedPairingAt: plannedPairingAt);

  @override
  BreedingPlanUpdateRequest objectiveTraits(
    Map<String, Object>? objectiveTraits,
  ) => this(objectiveTraits: objectiveTraits);

  @override
  BreedingPlanUpdateRequest notes(String? notes) => this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BreedingPlanUpdateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BreedingPlanUpdateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  BreedingPlanUpdateRequest call({
    Object? name = const $CopyWithPlaceholder(),
    Object? sireId = const $CopyWithPlaceholder(),
    Object? damId = const $CopyWithPlaceholder(),
    Object? ruleVersionId = const $CopyWithPlaceholder(),
    Object? plannedPairingAt = const $CopyWithPlaceholder(),
    Object? objectiveTraits = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return BreedingPlanUpdateRequest(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      sireId: sireId == const $CopyWithPlaceholder()
          ? _value.sireId
          // ignore: cast_nullable_to_non_nullable
          : sireId as String?,
      damId: damId == const $CopyWithPlaceholder()
          ? _value.damId
          // ignore: cast_nullable_to_non_nullable
          : damId as String?,
      ruleVersionId: ruleVersionId == const $CopyWithPlaceholder()
          ? _value.ruleVersionId
          // ignore: cast_nullable_to_non_nullable
          : ruleVersionId as String?,
      plannedPairingAt: plannedPairingAt == const $CopyWithPlaceholder()
          ? _value.plannedPairingAt
          // ignore: cast_nullable_to_non_nullable
          : plannedPairingAt as DateTime?,
      objectiveTraits: objectiveTraits == const $CopyWithPlaceholder()
          ? _value.objectiveTraits
          // ignore: cast_nullable_to_non_nullable
          : objectiveTraits as Map<String, Object>?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
    );
  }
}

extension $BreedingPlanUpdateRequestCopyWith on BreedingPlanUpdateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfBreedingPlanUpdateRequest.copyWith(...)` or like so:`instanceOfBreedingPlanUpdateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BreedingPlanUpdateRequestCWProxy get copyWith =>
      _$BreedingPlanUpdateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BreedingPlanUpdateRequest _$BreedingPlanUpdateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'BreedingPlanUpdateRequest',
  json,
  ($checkedConvert) {
    final val = BreedingPlanUpdateRequest(
      name: $checkedConvert('name', (v) => v as String?),
      sireId: $checkedConvert('sire_id', (v) => v as String?),
      damId: $checkedConvert('dam_id', (v) => v as String?),
      ruleVersionId: $checkedConvert('rule_version_id', (v) => v as String?),
      plannedPairingAt: $checkedConvert(
        'planned_pairing_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      objectiveTraits: $checkedConvert(
        'objective_traits',
        (v) => (v as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, e as Object),
        ),
      ),
      notes: $checkedConvert('notes', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'sireId': 'sire_id',
    'damId': 'dam_id',
    'ruleVersionId': 'rule_version_id',
    'plannedPairingAt': 'planned_pairing_at',
    'objectiveTraits': 'objective_traits',
  },
);

Map<String, dynamic> _$BreedingPlanUpdateRequestToJson(
  BreedingPlanUpdateRequest instance,
) => <String, dynamic>{
  'name': ?instance.name,
  'sire_id': ?instance.sireId,
  'dam_id': ?instance.damId,
  'rule_version_id': ?instance.ruleVersionId,
  'planned_pairing_at': ?instance.plannedPairingAt?.toIso8601String(),
  'objective_traits': ?instance.objectiveTraits,
  'notes': ?instance.notes,
};
