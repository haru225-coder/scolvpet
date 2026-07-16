// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'litter_parent.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LitterParentCWProxy {
  LitterParent id(String id);

  LitterParent litterId(String litterId);

  LitterParent hamsterId(String hamsterId);

  LitterParent role(LitterParentRoleEnum role);

  LitterParent evidenceType(LitterParentEvidenceTypeEnum evidenceType);

  LitterParent confidence(num confidence);

  LitterParent version(int version);

  LitterParent createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LitterParent(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LitterParent(...).copyWith(id: 12, name: "My name")
  /// ````
  LitterParent call({
    String id,
    String litterId,
    String hamsterId,
    LitterParentRoleEnum role,
    LitterParentEvidenceTypeEnum evidenceType,
    num confidence,
    int version,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLitterParent.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLitterParent.copyWith.fieldName(...)`
class _$LitterParentCWProxyImpl implements _$LitterParentCWProxy {
  const _$LitterParentCWProxyImpl(this._value);

  final LitterParent _value;

  @override
  LitterParent id(String id) => this(id: id);

  @override
  LitterParent litterId(String litterId) => this(litterId: litterId);

  @override
  LitterParent hamsterId(String hamsterId) => this(hamsterId: hamsterId);

  @override
  LitterParent role(LitterParentRoleEnum role) => this(role: role);

  @override
  LitterParent evidenceType(LitterParentEvidenceTypeEnum evidenceType) =>
      this(evidenceType: evidenceType);

  @override
  LitterParent confidence(num confidence) => this(confidence: confidence);

  @override
  LitterParent version(int version) => this(version: version);

  @override
  LitterParent createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LitterParent(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LitterParent(...).copyWith(id: 12, name: "My name")
  /// ````
  LitterParent call({
    Object? id = const $CopyWithPlaceholder(),
    Object? litterId = const $CopyWithPlaceholder(),
    Object? hamsterId = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? evidenceType = const $CopyWithPlaceholder(),
    Object? confidence = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return LitterParent(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      litterId: litterId == const $CopyWithPlaceholder()
          ? _value.litterId
          // ignore: cast_nullable_to_non_nullable
          : litterId as String,
      hamsterId: hamsterId == const $CopyWithPlaceholder()
          ? _value.hamsterId
          // ignore: cast_nullable_to_non_nullable
          : hamsterId as String,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as LitterParentRoleEnum,
      evidenceType: evidenceType == const $CopyWithPlaceholder()
          ? _value.evidenceType
          // ignore: cast_nullable_to_non_nullable
          : evidenceType as LitterParentEvidenceTypeEnum,
      confidence: confidence == const $CopyWithPlaceholder()
          ? _value.confidence
          // ignore: cast_nullable_to_non_nullable
          : confidence as num,
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

extension $LitterParentCopyWith on LitterParent {
  /// Returns a callable class that can be used as follows: `instanceOfLitterParent.copyWith(...)` or like so:`instanceOfLitterParent.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LitterParentCWProxy get copyWith => _$LitterParentCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LitterParent _$LitterParentFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'LitterParent',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'litter_id',
            'hamster_id',
            'role',
            'evidence_type',
            'confidence',
            'version',
            'created_at',
          ],
        );
        final val = LitterParent(
          id: $checkedConvert('id', (v) => v as String),
          litterId: $checkedConvert('litter_id', (v) => v as String),
          hamsterId: $checkedConvert('hamster_id', (v) => v as String),
          role: $checkedConvert(
            'role',
            (v) => $enumDecode(_$LitterParentRoleEnumEnumMap, v),
          ),
          evidenceType: $checkedConvert(
            'evidence_type',
            (v) => $enumDecode(_$LitterParentEvidenceTypeEnumEnumMap, v),
          ),
          confidence: $checkedConvert('confidence', (v) => v as num),
          version: $checkedConvert('version', (v) => (v as num).toInt()),
          createdAt: $checkedConvert(
            'created_at',
            (v) => DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'litterId': 'litter_id',
        'hamsterId': 'hamster_id',
        'evidenceType': 'evidence_type',
        'createdAt': 'created_at',
      },
    );

Map<String, dynamic> _$LitterParentToJson(LitterParent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'litter_id': instance.litterId,
      'hamster_id': instance.hamsterId,
      'role': _$LitterParentRoleEnumEnumMap[instance.role]!,
      'evidence_type':
          _$LitterParentEvidenceTypeEnumEnumMap[instance.evidenceType]!,
      'confidence': instance.confidence,
      'version': instance.version,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$LitterParentRoleEnumEnumMap = {
  LitterParentRoleEnum.sire: 'sire',
  LitterParentRoleEnum.dam: 'dam',
};

const _$LitterParentEvidenceTypeEnumEnumMap = {
  LitterParentEvidenceTypeEnum.breedingPlan: 'breeding_plan',
  LitterParentEvidenceTypeEnum.imported: 'imported',
  LitterParentEvidenceTypeEnum.manual: 'manual',
  LitterParentEvidenceTypeEnum.verifiedDocument: 'verified_document',
};
