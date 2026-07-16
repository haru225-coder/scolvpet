// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'litter.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LitterCWProxy {
  Litter id(String id);

  Litter ownerId(String ownerId);

  Litter origin(LitterOriginEnum origin);

  Litter code(String code);

  Litter breedingPlanId(String? breedingPlanId);

  Litter sireId(String? sireId);

  Litter damId(String? damId);

  Litter bornAt(DateTime? bornAt);

  Litter initialAliveCount(int initialAliveCount);

  Litter initialOtherCount(int initialOtherCount);

  Litter currentManagedCount(int currentManagedCount);

  Litter state(LitterState state);

  Litter enclosureId(String? enclosureId);

  Litter damCondition(DamCondition damCondition);

  Litter weanedAt(DateTime? weanedAt);

  Litter sexSeparatedAt(DateTime? sexSeparatedAt);

  Litter reconciledAt(DateTime? reconciledAt);

  Litter notes(String? notes);

  Litter version(int version);

  Litter createdAt(DateTime createdAt);

  Litter updatedAt(DateTime updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Litter(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Litter(...).copyWith(id: 12, name: "My name")
  /// ````
  Litter call({
    String id,
    String ownerId,
    LitterOriginEnum origin,
    String code,
    String? breedingPlanId,
    String? sireId,
    String? damId,
    DateTime? bornAt,
    int initialAliveCount,
    int initialOtherCount,
    int currentManagedCount,
    LitterState state,
    String? enclosureId,
    DamCondition damCondition,
    DateTime? weanedAt,
    DateTime? sexSeparatedAt,
    DateTime? reconciledAt,
    String? notes,
    int version,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLitter.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLitter.copyWith.fieldName(...)`
class _$LitterCWProxyImpl implements _$LitterCWProxy {
  const _$LitterCWProxyImpl(this._value);

  final Litter _value;

  @override
  Litter id(String id) => this(id: id);

  @override
  Litter ownerId(String ownerId) => this(ownerId: ownerId);

  @override
  Litter origin(LitterOriginEnum origin) => this(origin: origin);

  @override
  Litter code(String code) => this(code: code);

  @override
  Litter breedingPlanId(String? breedingPlanId) =>
      this(breedingPlanId: breedingPlanId);

  @override
  Litter sireId(String? sireId) => this(sireId: sireId);

  @override
  Litter damId(String? damId) => this(damId: damId);

  @override
  Litter bornAt(DateTime? bornAt) => this(bornAt: bornAt);

  @override
  Litter initialAliveCount(int initialAliveCount) =>
      this(initialAliveCount: initialAliveCount);

  @override
  Litter initialOtherCount(int initialOtherCount) =>
      this(initialOtherCount: initialOtherCount);

  @override
  Litter currentManagedCount(int currentManagedCount) =>
      this(currentManagedCount: currentManagedCount);

  @override
  Litter state(LitterState state) => this(state: state);

  @override
  Litter enclosureId(String? enclosureId) => this(enclosureId: enclosureId);

  @override
  Litter damCondition(DamCondition damCondition) =>
      this(damCondition: damCondition);

  @override
  Litter weanedAt(DateTime? weanedAt) => this(weanedAt: weanedAt);

  @override
  Litter sexSeparatedAt(DateTime? sexSeparatedAt) =>
      this(sexSeparatedAt: sexSeparatedAt);

  @override
  Litter reconciledAt(DateTime? reconciledAt) =>
      this(reconciledAt: reconciledAt);

  @override
  Litter notes(String? notes) => this(notes: notes);

  @override
  Litter version(int version) => this(version: version);

  @override
  Litter createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  Litter updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Litter(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Litter(...).copyWith(id: 12, name: "My name")
  /// ````
  Litter call({
    Object? id = const $CopyWithPlaceholder(),
    Object? ownerId = const $CopyWithPlaceholder(),
    Object? origin = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? breedingPlanId = const $CopyWithPlaceholder(),
    Object? sireId = const $CopyWithPlaceholder(),
    Object? damId = const $CopyWithPlaceholder(),
    Object? bornAt = const $CopyWithPlaceholder(),
    Object? initialAliveCount = const $CopyWithPlaceholder(),
    Object? initialOtherCount = const $CopyWithPlaceholder(),
    Object? currentManagedCount = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
    Object? enclosureId = const $CopyWithPlaceholder(),
    Object? damCondition = const $CopyWithPlaceholder(),
    Object? weanedAt = const $CopyWithPlaceholder(),
    Object? sexSeparatedAt = const $CopyWithPlaceholder(),
    Object? reconciledAt = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return Litter(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      ownerId: ownerId == const $CopyWithPlaceholder()
          ? _value.ownerId
          // ignore: cast_nullable_to_non_nullable
          : ownerId as String,
      origin: origin == const $CopyWithPlaceholder()
          ? _value.origin
          // ignore: cast_nullable_to_non_nullable
          : origin as LitterOriginEnum,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      breedingPlanId: breedingPlanId == const $CopyWithPlaceholder()
          ? _value.breedingPlanId
          // ignore: cast_nullable_to_non_nullable
          : breedingPlanId as String?,
      sireId: sireId == const $CopyWithPlaceholder()
          ? _value.sireId
          // ignore: cast_nullable_to_non_nullable
          : sireId as String?,
      damId: damId == const $CopyWithPlaceholder()
          ? _value.damId
          // ignore: cast_nullable_to_non_nullable
          : damId as String?,
      bornAt: bornAt == const $CopyWithPlaceholder()
          ? _value.bornAt
          // ignore: cast_nullable_to_non_nullable
          : bornAt as DateTime?,
      initialAliveCount: initialAliveCount == const $CopyWithPlaceholder()
          ? _value.initialAliveCount
          // ignore: cast_nullable_to_non_nullable
          : initialAliveCount as int,
      initialOtherCount: initialOtherCount == const $CopyWithPlaceholder()
          ? _value.initialOtherCount
          // ignore: cast_nullable_to_non_nullable
          : initialOtherCount as int,
      currentManagedCount: currentManagedCount == const $CopyWithPlaceholder()
          ? _value.currentManagedCount
          // ignore: cast_nullable_to_non_nullable
          : currentManagedCount as int,
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as LitterState,
      enclosureId: enclosureId == const $CopyWithPlaceholder()
          ? _value.enclosureId
          // ignore: cast_nullable_to_non_nullable
          : enclosureId as String?,
      damCondition: damCondition == const $CopyWithPlaceholder()
          ? _value.damCondition
          // ignore: cast_nullable_to_non_nullable
          : damCondition as DamCondition,
      weanedAt: weanedAt == const $CopyWithPlaceholder()
          ? _value.weanedAt
          // ignore: cast_nullable_to_non_nullable
          : weanedAt as DateTime?,
      sexSeparatedAt: sexSeparatedAt == const $CopyWithPlaceholder()
          ? _value.sexSeparatedAt
          // ignore: cast_nullable_to_non_nullable
          : sexSeparatedAt as DateTime?,
      reconciledAt: reconciledAt == const $CopyWithPlaceholder()
          ? _value.reconciledAt
          // ignore: cast_nullable_to_non_nullable
          : reconciledAt as DateTime?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
    );
  }
}

extension $LitterCopyWith on Litter {
  /// Returns a callable class that can be used as follows: `instanceOfLitter.copyWith(...)` or like so:`instanceOfLitter.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LitterCWProxy get copyWith => _$LitterCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Litter _$LitterFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Litter',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'owner_id',
        'origin',
        'code',
        'initial_alive_count',
        'initial_other_count',
        'current_managed_count',
        'state',
        'dam_condition',
        'version',
        'created_at',
        'updated_at',
      ],
    );
    final val = Litter(
      id: $checkedConvert('id', (v) => v as String),
      ownerId: $checkedConvert('owner_id', (v) => v as String),
      origin: $checkedConvert(
        'origin',
        (v) => $enumDecode(_$LitterOriginEnumEnumMap, v),
      ),
      code: $checkedConvert('code', (v) => v as String),
      breedingPlanId: $checkedConvert('breeding_plan_id', (v) => v as String?),
      sireId: $checkedConvert('sire_id', (v) => v as String?),
      damId: $checkedConvert('dam_id', (v) => v as String?),
      bornAt: $checkedConvert(
        'born_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      initialAliveCount: $checkedConvert(
        'initial_alive_count',
        (v) => (v as num).toInt(),
      ),
      initialOtherCount: $checkedConvert(
        'initial_other_count',
        (v) => (v as num).toInt(),
      ),
      currentManagedCount: $checkedConvert(
        'current_managed_count',
        (v) => (v as num).toInt(),
      ),
      state: $checkedConvert(
        'state',
        (v) => $enumDecode(_$LitterStateEnumMap, v),
      ),
      enclosureId: $checkedConvert('enclosure_id', (v) => v as String?),
      damCondition: $checkedConvert(
        'dam_condition',
        (v) => DamCondition.fromJson(v as Map<String, dynamic>),
      ),
      weanedAt: $checkedConvert(
        'weaned_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      sexSeparatedAt: $checkedConvert(
        'sex_separated_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      reconciledAt: $checkedConvert(
        'reconciled_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      notes: $checkedConvert('notes', (v) => v as String?),
      version: $checkedConvert('version', (v) => (v as num).toInt()),
      createdAt: $checkedConvert(
        'created_at',
        (v) => DateTime.parse(v as String),
      ),
      updatedAt: $checkedConvert(
        'updated_at',
        (v) => DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'ownerId': 'owner_id',
    'breedingPlanId': 'breeding_plan_id',
    'sireId': 'sire_id',
    'damId': 'dam_id',
    'bornAt': 'born_at',
    'initialAliveCount': 'initial_alive_count',
    'initialOtherCount': 'initial_other_count',
    'currentManagedCount': 'current_managed_count',
    'enclosureId': 'enclosure_id',
    'damCondition': 'dam_condition',
    'weanedAt': 'weaned_at',
    'sexSeparatedAt': 'sex_separated_at',
    'reconciledAt': 'reconciled_at',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
  },
);

Map<String, dynamic> _$LitterToJson(Litter instance) => <String, dynamic>{
  'id': instance.id,
  'owner_id': instance.ownerId,
  'origin': _$LitterOriginEnumEnumMap[instance.origin]!,
  'code': instance.code,
  'breeding_plan_id': ?instance.breedingPlanId,
  'sire_id': ?instance.sireId,
  'dam_id': ?instance.damId,
  'born_at': ?instance.bornAt?.toIso8601String(),
  'initial_alive_count': instance.initialAliveCount,
  'initial_other_count': instance.initialOtherCount,
  'current_managed_count': instance.currentManagedCount,
  'state': _$LitterStateEnumMap[instance.state]!,
  'enclosure_id': ?instance.enclosureId,
  'dam_condition': instance.damCondition.toJson(),
  'weaned_at': ?instance.weanedAt?.toIso8601String(),
  'sex_separated_at': ?instance.sexSeparatedAt?.toIso8601String(),
  'reconciled_at': ?instance.reconciledAt?.toIso8601String(),
  'notes': ?instance.notes,
  'version': instance.version,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$LitterOriginEnumEnumMap = {
  LitterOriginEnum.breeding: 'breeding',
  LitterOriginEnum.import_: 'import',
};

const _$LitterStateEnumMap = {
  LitterState.newborn: 'newborn',
  LitterState.nursing: 'nursing',
  LitterState.weaningDue: 'weaning_due',
  LitterState.sexingDue: 'sexing_due',
  LitterState.individualizing: 'individualizing',
  LitterState.closed: 'closed',
  LitterState.voided: 'voided',
};
