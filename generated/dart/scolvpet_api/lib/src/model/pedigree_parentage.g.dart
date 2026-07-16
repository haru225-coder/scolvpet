// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedigree_parentage.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PedigreeParentageCWProxy {
  PedigreeParentage id(String id);

  PedigreeParentage ownerId(String ownerId);

  PedigreeParentage childHamsterId(String childHamsterId);

  PedigreeParentage parentHamsterId(String parentHamsterId);

  PedigreeParentage role(PedigreeParentageRoleEnum role);

  PedigreeParentage evidenceType(
    PedigreeParentageEvidenceTypeEnum evidenceType,
  );

  PedigreeParentage confidence(num confidence);

  PedigreeParentage validFrom(DateTime validFrom);

  PedigreeParentage validTo(DateTime? validTo);

  PedigreeParentage notes(String? notes);

  PedigreeParentage version(int version);

  PedigreeParentage createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PedigreeParentage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PedigreeParentage(...).copyWith(id: 12, name: "My name")
  /// ````
  PedigreeParentage call({
    String id,
    String ownerId,
    String childHamsterId,
    String parentHamsterId,
    PedigreeParentageRoleEnum role,
    PedigreeParentageEvidenceTypeEnum evidenceType,
    num confidence,
    DateTime validFrom,
    DateTime? validTo,
    String? notes,
    int version,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPedigreeParentage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPedigreeParentage.copyWith.fieldName(...)`
class _$PedigreeParentageCWProxyImpl implements _$PedigreeParentageCWProxy {
  const _$PedigreeParentageCWProxyImpl(this._value);

  final PedigreeParentage _value;

  @override
  PedigreeParentage id(String id) => this(id: id);

  @override
  PedigreeParentage ownerId(String ownerId) => this(ownerId: ownerId);

  @override
  PedigreeParentage childHamsterId(String childHamsterId) =>
      this(childHamsterId: childHamsterId);

  @override
  PedigreeParentage parentHamsterId(String parentHamsterId) =>
      this(parentHamsterId: parentHamsterId);

  @override
  PedigreeParentage role(PedigreeParentageRoleEnum role) => this(role: role);

  @override
  PedigreeParentage evidenceType(
    PedigreeParentageEvidenceTypeEnum evidenceType,
  ) => this(evidenceType: evidenceType);

  @override
  PedigreeParentage confidence(num confidence) => this(confidence: confidence);

  @override
  PedigreeParentage validFrom(DateTime validFrom) => this(validFrom: validFrom);

  @override
  PedigreeParentage validTo(DateTime? validTo) => this(validTo: validTo);

  @override
  PedigreeParentage notes(String? notes) => this(notes: notes);

  @override
  PedigreeParentage version(int version) => this(version: version);

  @override
  PedigreeParentage createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PedigreeParentage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PedigreeParentage(...).copyWith(id: 12, name: "My name")
  /// ````
  PedigreeParentage call({
    Object? id = const $CopyWithPlaceholder(),
    Object? ownerId = const $CopyWithPlaceholder(),
    Object? childHamsterId = const $CopyWithPlaceholder(),
    Object? parentHamsterId = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? evidenceType = const $CopyWithPlaceholder(),
    Object? confidence = const $CopyWithPlaceholder(),
    Object? validFrom = const $CopyWithPlaceholder(),
    Object? validTo = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return PedigreeParentage(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      ownerId: ownerId == const $CopyWithPlaceholder()
          ? _value.ownerId
          // ignore: cast_nullable_to_non_nullable
          : ownerId as String,
      childHamsterId: childHamsterId == const $CopyWithPlaceholder()
          ? _value.childHamsterId
          // ignore: cast_nullable_to_non_nullable
          : childHamsterId as String,
      parentHamsterId: parentHamsterId == const $CopyWithPlaceholder()
          ? _value.parentHamsterId
          // ignore: cast_nullable_to_non_nullable
          : parentHamsterId as String,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as PedigreeParentageRoleEnum,
      evidenceType: evidenceType == const $CopyWithPlaceholder()
          ? _value.evidenceType
          // ignore: cast_nullable_to_non_nullable
          : evidenceType as PedigreeParentageEvidenceTypeEnum,
      confidence: confidence == const $CopyWithPlaceholder()
          ? _value.confidence
          // ignore: cast_nullable_to_non_nullable
          : confidence as num,
      validFrom: validFrom == const $CopyWithPlaceholder()
          ? _value.validFrom
          // ignore: cast_nullable_to_non_nullable
          : validFrom as DateTime,
      validTo: validTo == const $CopyWithPlaceholder()
          ? _value.validTo
          // ignore: cast_nullable_to_non_nullable
          : validTo as DateTime?,
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
    );
  }
}

extension $PedigreeParentageCopyWith on PedigreeParentage {
  /// Returns a callable class that can be used as follows: `instanceOfPedigreeParentage.copyWith(...)` or like so:`instanceOfPedigreeParentage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PedigreeParentageCWProxy get copyWith =>
      _$PedigreeParentageCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PedigreeParentage _$PedigreeParentageFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PedigreeParentage',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'owner_id',
        'child_hamster_id',
        'parent_hamster_id',
        'role',
        'evidence_type',
        'confidence',
        'valid_from',
        'version',
        'created_at',
      ],
    );
    final val = PedigreeParentage(
      id: $checkedConvert('id', (v) => v as String),
      ownerId: $checkedConvert('owner_id', (v) => v as String),
      childHamsterId: $checkedConvert('child_hamster_id', (v) => v as String),
      parentHamsterId: $checkedConvert('parent_hamster_id', (v) => v as String),
      role: $checkedConvert(
        'role',
        (v) => $enumDecode(_$PedigreeParentageRoleEnumEnumMap, v),
      ),
      evidenceType: $checkedConvert(
        'evidence_type',
        (v) => $enumDecode(_$PedigreeParentageEvidenceTypeEnumEnumMap, v),
      ),
      confidence: $checkedConvert('confidence', (v) => v as num),
      validFrom: $checkedConvert(
        'valid_from',
        (v) => DateTime.parse(v as String),
      ),
      validTo: $checkedConvert(
        'valid_to',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      notes: $checkedConvert('notes', (v) => v as String?),
      version: $checkedConvert('version', (v) => (v as num).toInt()),
      createdAt: $checkedConvert(
        'created_at',
        (v) => DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'ownerId': 'owner_id',
    'childHamsterId': 'child_hamster_id',
    'parentHamsterId': 'parent_hamster_id',
    'evidenceType': 'evidence_type',
    'validFrom': 'valid_from',
    'validTo': 'valid_to',
    'createdAt': 'created_at',
  },
);

Map<String, dynamic> _$PedigreeParentageToJson(PedigreeParentage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'owner_id': instance.ownerId,
      'child_hamster_id': instance.childHamsterId,
      'parent_hamster_id': instance.parentHamsterId,
      'role': _$PedigreeParentageRoleEnumEnumMap[instance.role]!,
      'evidence_type':
          _$PedigreeParentageEvidenceTypeEnumEnumMap[instance.evidenceType]!,
      'confidence': instance.confidence,
      'valid_from': instance.validFrom.toIso8601String(),
      'valid_to': ?instance.validTo?.toIso8601String(),
      'notes': ?instance.notes,
      'version': instance.version,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$PedigreeParentageRoleEnumEnumMap = {
  PedigreeParentageRoleEnum.sire: 'sire',
  PedigreeParentageRoleEnum.dam: 'dam',
};

const _$PedigreeParentageEvidenceTypeEnumEnumMap = {
  PedigreeParentageEvidenceTypeEnum.litterDerived: 'litter_derived',
  PedigreeParentageEvidenceTypeEnum.breedingPlan: 'breeding_plan',
  PedigreeParentageEvidenceTypeEnum.imported: 'imported',
  PedigreeParentageEvidenceTypeEnum.manual: 'manual',
  PedigreeParentageEvidenceTypeEnum.verifiedDocument: 'verified_document',
};
