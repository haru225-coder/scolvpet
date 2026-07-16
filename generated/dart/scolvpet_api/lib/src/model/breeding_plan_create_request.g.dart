// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breeding_plan_create_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BreedingPlanCreateRequestCWProxy {
  BreedingPlanCreateRequest name(String? name);

  BreedingPlanCreateRequest sireId(String sireId);

  BreedingPlanCreateRequest damId(String damId);

  BreedingPlanCreateRequest ruleVersionId(String ruleVersionId);

  BreedingPlanCreateRequest plannedPairingAt(DateTime? plannedPairingAt);

  BreedingPlanCreateRequest objectiveTraits(
    Map<String, Object>? objectiveTraits,
  );

  BreedingPlanCreateRequest notes(String? notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BreedingPlanCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BreedingPlanCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  BreedingPlanCreateRequest call({
    String? name,
    String sireId,
    String damId,
    String ruleVersionId,
    DateTime? plannedPairingAt,
    Map<String, Object>? objectiveTraits,
    String? notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBreedingPlanCreateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBreedingPlanCreateRequest.copyWith.fieldName(...)`
class _$BreedingPlanCreateRequestCWProxyImpl
    implements _$BreedingPlanCreateRequestCWProxy {
  const _$BreedingPlanCreateRequestCWProxyImpl(this._value);

  final BreedingPlanCreateRequest _value;

  @override
  BreedingPlanCreateRequest name(String? name) => this(name: name);

  @override
  BreedingPlanCreateRequest sireId(String sireId) => this(sireId: sireId);

  @override
  BreedingPlanCreateRequest damId(String damId) => this(damId: damId);

  @override
  BreedingPlanCreateRequest ruleVersionId(String ruleVersionId) =>
      this(ruleVersionId: ruleVersionId);

  @override
  BreedingPlanCreateRequest plannedPairingAt(DateTime? plannedPairingAt) =>
      this(plannedPairingAt: plannedPairingAt);

  @override
  BreedingPlanCreateRequest objectiveTraits(
    Map<String, Object>? objectiveTraits,
  ) => this(objectiveTraits: objectiveTraits);

  @override
  BreedingPlanCreateRequest notes(String? notes) => this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BreedingPlanCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BreedingPlanCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  BreedingPlanCreateRequest call({
    Object? name = const $CopyWithPlaceholder(),
    Object? sireId = const $CopyWithPlaceholder(),
    Object? damId = const $CopyWithPlaceholder(),
    Object? ruleVersionId = const $CopyWithPlaceholder(),
    Object? plannedPairingAt = const $CopyWithPlaceholder(),
    Object? objectiveTraits = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return BreedingPlanCreateRequest(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      sireId: sireId == const $CopyWithPlaceholder()
          ? _value.sireId
          // ignore: cast_nullable_to_non_nullable
          : sireId as String,
      damId: damId == const $CopyWithPlaceholder()
          ? _value.damId
          // ignore: cast_nullable_to_non_nullable
          : damId as String,
      ruleVersionId: ruleVersionId == const $CopyWithPlaceholder()
          ? _value.ruleVersionId
          // ignore: cast_nullable_to_non_nullable
          : ruleVersionId as String,
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

extension $BreedingPlanCreateRequestCopyWith on BreedingPlanCreateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfBreedingPlanCreateRequest.copyWith(...)` or like so:`instanceOfBreedingPlanCreateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BreedingPlanCreateRequestCWProxy get copyWith =>
      _$BreedingPlanCreateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BreedingPlanCreateRequest _$BreedingPlanCreateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'BreedingPlanCreateRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['sire_id', 'dam_id', 'rule_version_id'],
    );
    final val = BreedingPlanCreateRequest(
      name: $checkedConvert('name', (v) => v as String?),
      sireId: $checkedConvert('sire_id', (v) => v as String),
      damId: $checkedConvert('dam_id', (v) => v as String),
      ruleVersionId: $checkedConvert('rule_version_id', (v) => v as String),
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

Map<String, dynamic> _$BreedingPlanCreateRequestToJson(
  BreedingPlanCreateRequest instance,
) => <String, dynamic>{
  'name': ?instance.name,
  'sire_id': instance.sireId,
  'dam_id': instance.damId,
  'rule_version_id': instance.ruleVersionId,
  'planned_pairing_at': ?instance.plannedPairingAt?.toIso8601String(),
  'objective_traits': ?instance.objectiveTraits,
  'notes': ?instance.notes,
};
