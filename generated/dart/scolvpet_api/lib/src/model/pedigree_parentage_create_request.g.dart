// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedigree_parentage_create_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PedigreeParentageCreateRequestCWProxy {
  PedigreeParentageCreateRequest childHamsterId(String childHamsterId);

  PedigreeParentageCreateRequest parentHamsterId(String parentHamsterId);

  PedigreeParentageCreateRequest role(
    PedigreeParentageCreateRequestRoleEnum role,
  );

  PedigreeParentageCreateRequest evidenceType(
    PedigreeParentageCreateRequestEvidenceTypeEnum evidenceType,
  );

  PedigreeParentageCreateRequest confidence(num confidence);

  PedigreeParentageCreateRequest validFrom(DateTime validFrom);

  PedigreeParentageCreateRequest notes(String? notes);

  PedigreeParentageCreateRequest correctionReason(String? correctionReason);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PedigreeParentageCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PedigreeParentageCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PedigreeParentageCreateRequest call({
    String childHamsterId,
    String parentHamsterId,
    PedigreeParentageCreateRequestRoleEnum role,
    PedigreeParentageCreateRequestEvidenceTypeEnum evidenceType,
    num confidence,
    DateTime validFrom,
    String? notes,
    String? correctionReason,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPedigreeParentageCreateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPedigreeParentageCreateRequest.copyWith.fieldName(...)`
class _$PedigreeParentageCreateRequestCWProxyImpl
    implements _$PedigreeParentageCreateRequestCWProxy {
  const _$PedigreeParentageCreateRequestCWProxyImpl(this._value);

  final PedigreeParentageCreateRequest _value;

  @override
  PedigreeParentageCreateRequest childHamsterId(String childHamsterId) =>
      this(childHamsterId: childHamsterId);

  @override
  PedigreeParentageCreateRequest parentHamsterId(String parentHamsterId) =>
      this(parentHamsterId: parentHamsterId);

  @override
  PedigreeParentageCreateRequest role(
    PedigreeParentageCreateRequestRoleEnum role,
  ) => this(role: role);

  @override
  PedigreeParentageCreateRequest evidenceType(
    PedigreeParentageCreateRequestEvidenceTypeEnum evidenceType,
  ) => this(evidenceType: evidenceType);

  @override
  PedigreeParentageCreateRequest confidence(num confidence) =>
      this(confidence: confidence);

  @override
  PedigreeParentageCreateRequest validFrom(DateTime validFrom) =>
      this(validFrom: validFrom);

  @override
  PedigreeParentageCreateRequest notes(String? notes) => this(notes: notes);

  @override
  PedigreeParentageCreateRequest correctionReason(String? correctionReason) =>
      this(correctionReason: correctionReason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PedigreeParentageCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PedigreeParentageCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PedigreeParentageCreateRequest call({
    Object? childHamsterId = const $CopyWithPlaceholder(),
    Object? parentHamsterId = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? evidenceType = const $CopyWithPlaceholder(),
    Object? confidence = const $CopyWithPlaceholder(),
    Object? validFrom = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? correctionReason = const $CopyWithPlaceholder(),
  }) {
    return PedigreeParentageCreateRequest(
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
          : role as PedigreeParentageCreateRequestRoleEnum,
      evidenceType: evidenceType == const $CopyWithPlaceholder()
          ? _value.evidenceType
          // ignore: cast_nullable_to_non_nullable
          : evidenceType as PedigreeParentageCreateRequestEvidenceTypeEnum,
      confidence: confidence == const $CopyWithPlaceholder()
          ? _value.confidence
          // ignore: cast_nullable_to_non_nullable
          : confidence as num,
      validFrom: validFrom == const $CopyWithPlaceholder()
          ? _value.validFrom
          // ignore: cast_nullable_to_non_nullable
          : validFrom as DateTime,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
      correctionReason: correctionReason == const $CopyWithPlaceholder()
          ? _value.correctionReason
          // ignore: cast_nullable_to_non_nullable
          : correctionReason as String?,
    );
  }
}

extension $PedigreeParentageCreateRequestCopyWith
    on PedigreeParentageCreateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfPedigreeParentageCreateRequest.copyWith(...)` or like so:`instanceOfPedigreeParentageCreateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PedigreeParentageCreateRequestCWProxy get copyWith =>
      _$PedigreeParentageCreateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PedigreeParentageCreateRequest _$PedigreeParentageCreateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PedigreeParentageCreateRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'child_hamster_id',
        'parent_hamster_id',
        'role',
        'evidence_type',
        'confidence',
        'valid_from',
      ],
    );
    final val = PedigreeParentageCreateRequest(
      childHamsterId: $checkedConvert('child_hamster_id', (v) => v as String),
      parentHamsterId: $checkedConvert('parent_hamster_id', (v) => v as String),
      role: $checkedConvert(
        'role',
        (v) => $enumDecode(_$PedigreeParentageCreateRequestRoleEnumEnumMap, v),
      ),
      evidenceType: $checkedConvert(
        'evidence_type',
        (v) => $enumDecode(
          _$PedigreeParentageCreateRequestEvidenceTypeEnumEnumMap,
          v,
        ),
      ),
      confidence: $checkedConvert('confidence', (v) => v as num),
      validFrom: $checkedConvert(
        'valid_from',
        (v) => DateTime.parse(v as String),
      ),
      notes: $checkedConvert('notes', (v) => v as String?),
      correctionReason: $checkedConvert(
        'correction_reason',
        (v) => v as String?,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'childHamsterId': 'child_hamster_id',
    'parentHamsterId': 'parent_hamster_id',
    'evidenceType': 'evidence_type',
    'validFrom': 'valid_from',
    'correctionReason': 'correction_reason',
  },
);

Map<String, dynamic> _$PedigreeParentageCreateRequestToJson(
  PedigreeParentageCreateRequest instance,
) => <String, dynamic>{
  'child_hamster_id': instance.childHamsterId,
  'parent_hamster_id': instance.parentHamsterId,
  'role': _$PedigreeParentageCreateRequestRoleEnumEnumMap[instance.role]!,
  'evidence_type':
      _$PedigreeParentageCreateRequestEvidenceTypeEnumEnumMap[instance
          .evidenceType]!,
  'confidence': instance.confidence,
  'valid_from': instance.validFrom.toIso8601String(),
  'notes': ?instance.notes,
  'correction_reason': ?instance.correctionReason,
};

const _$PedigreeParentageCreateRequestRoleEnumEnumMap = {
  PedigreeParentageCreateRequestRoleEnum.sire: 'sire',
  PedigreeParentageCreateRequestRoleEnum.dam: 'dam',
};

const _$PedigreeParentageCreateRequestEvidenceTypeEnumEnumMap = {
  PedigreeParentageCreateRequestEvidenceTypeEnum.litterDerived:
      'litter_derived',
  PedigreeParentageCreateRequestEvidenceTypeEnum.breedingPlan: 'breeding_plan',
  PedigreeParentageCreateRequestEvidenceTypeEnum.imported: 'imported',
  PedigreeParentageCreateRequestEvidenceTypeEnum.manual: 'manual',
  PedigreeParentageCreateRequestEvidenceTypeEnum.verifiedDocument:
      'verified_document',
};
