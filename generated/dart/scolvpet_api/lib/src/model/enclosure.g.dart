// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enclosure.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EnclosureCWProxy {
  Enclosure id(String id);

  Enclosure ownerId(String ownerId);

  Enclosure code(String code);

  Enclosure rackCode(String? rackCode);

  Enclosure levelCode(String? levelCode);

  Enclosure dimensions(EnclosureDimensions? dimensions);

  Enclosure state(EnclosureState state);

  Enclosure cleanlinessState(CleanlinessState cleanlinessState);

  Enclosure capacity(int? capacity);

  Enclosure equipment(List<String>? equipment);

  Enclosure lastCleanedAt(DateTime? lastCleanedAt);

  Enclosure currentStays(List<EnclosureStay>? currentStays);

  Enclosure version(int version);

  Enclosure createdAt(DateTime createdAt);

  Enclosure updatedAt(DateTime updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Enclosure(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Enclosure(...).copyWith(id: 12, name: "My name")
  /// ````
  Enclosure call({
    String id,
    String ownerId,
    String code,
    String? rackCode,
    String? levelCode,
    EnclosureDimensions? dimensions,
    EnclosureState state,
    CleanlinessState cleanlinessState,
    int? capacity,
    List<String>? equipment,
    DateTime? lastCleanedAt,
    List<EnclosureStay>? currentStays,
    int version,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEnclosure.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEnclosure.copyWith.fieldName(...)`
class _$EnclosureCWProxyImpl implements _$EnclosureCWProxy {
  const _$EnclosureCWProxyImpl(this._value);

  final Enclosure _value;

  @override
  Enclosure id(String id) => this(id: id);

  @override
  Enclosure ownerId(String ownerId) => this(ownerId: ownerId);

  @override
  Enclosure code(String code) => this(code: code);

  @override
  Enclosure rackCode(String? rackCode) => this(rackCode: rackCode);

  @override
  Enclosure levelCode(String? levelCode) => this(levelCode: levelCode);

  @override
  Enclosure dimensions(EnclosureDimensions? dimensions) =>
      this(dimensions: dimensions);

  @override
  Enclosure state(EnclosureState state) => this(state: state);

  @override
  Enclosure cleanlinessState(CleanlinessState cleanlinessState) =>
      this(cleanlinessState: cleanlinessState);

  @override
  Enclosure capacity(int? capacity) => this(capacity: capacity);

  @override
  Enclosure equipment(List<String>? equipment) => this(equipment: equipment);

  @override
  Enclosure lastCleanedAt(DateTime? lastCleanedAt) =>
      this(lastCleanedAt: lastCleanedAt);

  @override
  Enclosure currentStays(List<EnclosureStay>? currentStays) =>
      this(currentStays: currentStays);

  @override
  Enclosure version(int version) => this(version: version);

  @override
  Enclosure createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  Enclosure updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Enclosure(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Enclosure(...).copyWith(id: 12, name: "My name")
  /// ````
  Enclosure call({
    Object? id = const $CopyWithPlaceholder(),
    Object? ownerId = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? rackCode = const $CopyWithPlaceholder(),
    Object? levelCode = const $CopyWithPlaceholder(),
    Object? dimensions = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
    Object? cleanlinessState = const $CopyWithPlaceholder(),
    Object? capacity = const $CopyWithPlaceholder(),
    Object? equipment = const $CopyWithPlaceholder(),
    Object? lastCleanedAt = const $CopyWithPlaceholder(),
    Object? currentStays = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return Enclosure(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      ownerId: ownerId == const $CopyWithPlaceholder()
          ? _value.ownerId
          // ignore: cast_nullable_to_non_nullable
          : ownerId as String,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      rackCode: rackCode == const $CopyWithPlaceholder()
          ? _value.rackCode
          // ignore: cast_nullable_to_non_nullable
          : rackCode as String?,
      levelCode: levelCode == const $CopyWithPlaceholder()
          ? _value.levelCode
          // ignore: cast_nullable_to_non_nullable
          : levelCode as String?,
      dimensions: dimensions == const $CopyWithPlaceholder()
          ? _value.dimensions
          // ignore: cast_nullable_to_non_nullable
          : dimensions as EnclosureDimensions?,
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as EnclosureState,
      cleanlinessState: cleanlinessState == const $CopyWithPlaceholder()
          ? _value.cleanlinessState
          // ignore: cast_nullable_to_non_nullable
          : cleanlinessState as CleanlinessState,
      capacity: capacity == const $CopyWithPlaceholder()
          ? _value.capacity
          // ignore: cast_nullable_to_non_nullable
          : capacity as int?,
      equipment: equipment == const $CopyWithPlaceholder()
          ? _value.equipment
          // ignore: cast_nullable_to_non_nullable
          : equipment as List<String>?,
      lastCleanedAt: lastCleanedAt == const $CopyWithPlaceholder()
          ? _value.lastCleanedAt
          // ignore: cast_nullable_to_non_nullable
          : lastCleanedAt as DateTime?,
      currentStays: currentStays == const $CopyWithPlaceholder()
          ? _value.currentStays
          // ignore: cast_nullable_to_non_nullable
          : currentStays as List<EnclosureStay>?,
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

extension $EnclosureCopyWith on Enclosure {
  /// Returns a callable class that can be used as follows: `instanceOfEnclosure.copyWith(...)` or like so:`instanceOfEnclosure.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EnclosureCWProxy get copyWith => _$EnclosureCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Enclosure _$EnclosureFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Enclosure',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'owner_id',
        'code',
        'state',
        'cleanliness_state',
        'version',
        'created_at',
        'updated_at',
      ],
    );
    final val = Enclosure(
      id: $checkedConvert('id', (v) => v as String),
      ownerId: $checkedConvert('owner_id', (v) => v as String),
      code: $checkedConvert('code', (v) => v as String),
      rackCode: $checkedConvert('rack_code', (v) => v as String?),
      levelCode: $checkedConvert('level_code', (v) => v as String?),
      dimensions: $checkedConvert(
        'dimensions',
        (v) => v == null
            ? null
            : EnclosureDimensions.fromJson(v as Map<String, dynamic>),
      ),
      state: $checkedConvert(
        'state',
        (v) => $enumDecode(_$EnclosureStateEnumMap, v),
      ),
      cleanlinessState: $checkedConvert(
        'cleanliness_state',
        (v) => $enumDecode(_$CleanlinessStateEnumMap, v),
      ),
      capacity: $checkedConvert('capacity', (v) => (v as num?)?.toInt() ?? 1),
      equipment: $checkedConvert(
        'equipment',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      lastCleanedAt: $checkedConvert(
        'last_cleaned_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      currentStays: $checkedConvert(
        'current_stays',
        (v) => (v as List<dynamic>?)
            ?.map((e) => EnclosureStay.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
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
    'rackCode': 'rack_code',
    'levelCode': 'level_code',
    'cleanlinessState': 'cleanliness_state',
    'lastCleanedAt': 'last_cleaned_at',
    'currentStays': 'current_stays',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
  },
);

Map<String, dynamic> _$EnclosureToJson(Enclosure instance) => <String, dynamic>{
  'id': instance.id,
  'owner_id': instance.ownerId,
  'code': instance.code,
  'rack_code': ?instance.rackCode,
  'level_code': ?instance.levelCode,
  'dimensions': ?instance.dimensions?.toJson(),
  'state': _$EnclosureStateEnumMap[instance.state]!,
  'cleanliness_state': _$CleanlinessStateEnumMap[instance.cleanlinessState]!,
  'capacity': ?instance.capacity,
  'equipment': ?instance.equipment,
  'last_cleaned_at': ?instance.lastCleanedAt?.toIso8601String(),
  'current_stays': ?instance.currentStays?.map((e) => e.toJson()).toList(),
  'version': instance.version,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$EnclosureStateEnumMap = {
  EnclosureState.vacant: 'vacant',
  EnclosureState.occupiedSingle: 'occupied_single',
  EnclosureState.pairingTemp: 'pairing_temp',
  EnclosureState.gestation: 'gestation',
  EnclosureState.damWithLitter: 'dam_with_litter',
  EnclosureState.isolation: 'isolation',
  EnclosureState.cleaningDue: 'cleaning_due',
  EnclosureState.disabled: 'disabled',
};

const _$CleanlinessStateEnumMap = {
  CleanlinessState.clean: 'clean',
  CleanlinessState.partialDue: 'partial_due',
  CleanlinessState.fullDue: 'full_due',
};
