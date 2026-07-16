// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'litter_parent_create_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LitterParentCreateRequestCWProxy {
  LitterParentCreateRequest hamsterId(String hamsterId);

  LitterParentCreateRequest role(LitterParentCreateRequestRoleEnum role);

  LitterParentCreateRequest evidenceType(
    LitterParentCreateRequestEvidenceTypeEnum evidenceType,
  );

  LitterParentCreateRequest confidence(num confidence);

  LitterParentCreateRequest correctionReason(String? correctionReason);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LitterParentCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LitterParentCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  LitterParentCreateRequest call({
    String hamsterId,
    LitterParentCreateRequestRoleEnum role,
    LitterParentCreateRequestEvidenceTypeEnum evidenceType,
    num confidence,
    String? correctionReason,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLitterParentCreateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLitterParentCreateRequest.copyWith.fieldName(...)`
class _$LitterParentCreateRequestCWProxyImpl
    implements _$LitterParentCreateRequestCWProxy {
  const _$LitterParentCreateRequestCWProxyImpl(this._value);

  final LitterParentCreateRequest _value;

  @override
  LitterParentCreateRequest hamsterId(String hamsterId) =>
      this(hamsterId: hamsterId);

  @override
  LitterParentCreateRequest role(LitterParentCreateRequestRoleEnum role) =>
      this(role: role);

  @override
  LitterParentCreateRequest evidenceType(
    LitterParentCreateRequestEvidenceTypeEnum evidenceType,
  ) => this(evidenceType: evidenceType);

  @override
  LitterParentCreateRequest confidence(num confidence) =>
      this(confidence: confidence);

  @override
  LitterParentCreateRequest correctionReason(String? correctionReason) =>
      this(correctionReason: correctionReason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LitterParentCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LitterParentCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  LitterParentCreateRequest call({
    Object? hamsterId = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? evidenceType = const $CopyWithPlaceholder(),
    Object? confidence = const $CopyWithPlaceholder(),
    Object? correctionReason = const $CopyWithPlaceholder(),
  }) {
    return LitterParentCreateRequest(
      hamsterId: hamsterId == const $CopyWithPlaceholder()
          ? _value.hamsterId
          // ignore: cast_nullable_to_non_nullable
          : hamsterId as String,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as LitterParentCreateRequestRoleEnum,
      evidenceType: evidenceType == const $CopyWithPlaceholder()
          ? _value.evidenceType
          // ignore: cast_nullable_to_non_nullable
          : evidenceType as LitterParentCreateRequestEvidenceTypeEnum,
      confidence: confidence == const $CopyWithPlaceholder()
          ? _value.confidence
          // ignore: cast_nullable_to_non_nullable
          : confidence as num,
      correctionReason: correctionReason == const $CopyWithPlaceholder()
          ? _value.correctionReason
          // ignore: cast_nullable_to_non_nullable
          : correctionReason as String?,
    );
  }
}

extension $LitterParentCreateRequestCopyWith on LitterParentCreateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfLitterParentCreateRequest.copyWith(...)` or like so:`instanceOfLitterParentCreateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LitterParentCreateRequestCWProxy get copyWith =>
      _$LitterParentCreateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LitterParentCreateRequest _$LitterParentCreateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'LitterParentCreateRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['hamster_id', 'role', 'evidence_type', 'confidence'],
    );
    final val = LitterParentCreateRequest(
      hamsterId: $checkedConvert('hamster_id', (v) => v as String),
      role: $checkedConvert(
        'role',
        (v) => $enumDecode(_$LitterParentCreateRequestRoleEnumEnumMap, v),
      ),
      evidenceType: $checkedConvert(
        'evidence_type',
        (v) =>
            $enumDecode(_$LitterParentCreateRequestEvidenceTypeEnumEnumMap, v),
      ),
      confidence: $checkedConvert('confidence', (v) => v as num),
      correctionReason: $checkedConvert(
        'correction_reason',
        (v) => v as String?,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'hamsterId': 'hamster_id',
    'evidenceType': 'evidence_type',
    'correctionReason': 'correction_reason',
  },
);

Map<String, dynamic> _$LitterParentCreateRequestToJson(
  LitterParentCreateRequest instance,
) => <String, dynamic>{
  'hamster_id': instance.hamsterId,
  'role': _$LitterParentCreateRequestRoleEnumEnumMap[instance.role]!,
  'evidence_type':
      _$LitterParentCreateRequestEvidenceTypeEnumEnumMap[instance
          .evidenceType]!,
  'confidence': instance.confidence,
  'correction_reason': ?instance.correctionReason,
};

const _$LitterParentCreateRequestRoleEnumEnumMap = {
  LitterParentCreateRequestRoleEnum.sire: 'sire',
  LitterParentCreateRequestRoleEnum.dam: 'dam',
};

const _$LitterParentCreateRequestEvidenceTypeEnumEnumMap = {
  LitterParentCreateRequestEvidenceTypeEnum.breedingPlan: 'breeding_plan',
  LitterParentCreateRequestEvidenceTypeEnum.imported: 'imported',
  LitterParentCreateRequestEvidenceTypeEnum.manual: 'manual',
  LitterParentCreateRequestEvidenceTypeEnum.verifiedDocument:
      'verified_document',
};
