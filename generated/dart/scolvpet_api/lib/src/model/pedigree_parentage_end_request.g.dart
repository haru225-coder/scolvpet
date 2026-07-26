// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedigree_parentage_end_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PedigreeParentageEndRequestCWProxy {
  PedigreeParentageEndRequest childHamsterId(String childHamsterId);

  PedigreeParentageEndRequest role(PedigreeParentageEndRequestRoleEnum role);

  PedigreeParentageEndRequest correctionReason(String correctionReason);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PedigreeParentageEndRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PedigreeParentageEndRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PedigreeParentageEndRequest call({
    String childHamsterId,
    PedigreeParentageEndRequestRoleEnum role,
    String correctionReason,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPedigreeParentageEndRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPedigreeParentageEndRequest.copyWith.fieldName(...)`
class _$PedigreeParentageEndRequestCWProxyImpl
    implements _$PedigreeParentageEndRequestCWProxy {
  const _$PedigreeParentageEndRequestCWProxyImpl(this._value);

  final PedigreeParentageEndRequest _value;

  @override
  PedigreeParentageEndRequest childHamsterId(String childHamsterId) =>
      this(childHamsterId: childHamsterId);

  @override
  PedigreeParentageEndRequest role(PedigreeParentageEndRequestRoleEnum role) =>
      this(role: role);

  @override
  PedigreeParentageEndRequest correctionReason(String correctionReason) =>
      this(correctionReason: correctionReason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PedigreeParentageEndRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PedigreeParentageEndRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PedigreeParentageEndRequest call({
    Object? childHamsterId = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? correctionReason = const $CopyWithPlaceholder(),
  }) {
    return PedigreeParentageEndRequest(
      childHamsterId: childHamsterId == const $CopyWithPlaceholder()
          ? _value.childHamsterId
          // ignore: cast_nullable_to_non_nullable
          : childHamsterId as String,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as PedigreeParentageEndRequestRoleEnum,
      correctionReason: correctionReason == const $CopyWithPlaceholder()
          ? _value.correctionReason
          // ignore: cast_nullable_to_non_nullable
          : correctionReason as String,
    );
  }
}

extension $PedigreeParentageEndRequestCopyWith on PedigreeParentageEndRequest {
  /// Returns a callable class that can be used as follows: `instanceOfPedigreeParentageEndRequest.copyWith(...)` or like so:`instanceOfPedigreeParentageEndRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PedigreeParentageEndRequestCWProxy get copyWith =>
      _$PedigreeParentageEndRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PedigreeParentageEndRequest _$PedigreeParentageEndRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PedigreeParentageEndRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['child_hamster_id', 'role', 'correction_reason'],
    );
    final val = PedigreeParentageEndRequest(
      childHamsterId: $checkedConvert('child_hamster_id', (v) => v as String),
      role: $checkedConvert(
        'role',
        (v) => $enumDecode(_$PedigreeParentageEndRequestRoleEnumEnumMap, v),
      ),
      correctionReason: $checkedConvert(
        'correction_reason',
        (v) => v as String,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'childHamsterId': 'child_hamster_id',
    'correctionReason': 'correction_reason',
  },
);

Map<String, dynamic> _$PedigreeParentageEndRequestToJson(
  PedigreeParentageEndRequest instance,
) => <String, dynamic>{
  'child_hamster_id': instance.childHamsterId,
  'role': _$PedigreeParentageEndRequestRoleEnumEnumMap[instance.role]!,
  'correction_reason': instance.correctionReason,
};

const _$PedigreeParentageEndRequestRoleEnumEnumMap = {
  PedigreeParentageEndRequestRoleEnum.sire: 'sire',
  PedigreeParentageEndRequestRoleEnum.dam: 'dam',
};
