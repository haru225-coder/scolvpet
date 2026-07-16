// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'litter_member.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LitterMemberCWProxy {
  LitterMember id(String id);

  LitterMember litterId(String litterId);

  LitterMember memberType(LitterMemberMemberTypeEnum memberType);

  LitterMember pupIdentityId(String? pupIdentityId);

  LitterMember hamsterId(String? hamsterId);

  LitterMember role(LitterMemberRoleEnum role);

  LitterMember joinedAt(DateTime joinedAt);

  LitterMember leftAt(DateTime? leftAt);

  LitterMember version(int version);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LitterMember(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LitterMember(...).copyWith(id: 12, name: "My name")
  /// ````
  LitterMember call({
    String id,
    String litterId,
    LitterMemberMemberTypeEnum memberType,
    String? pupIdentityId,
    String? hamsterId,
    LitterMemberRoleEnum role,
    DateTime joinedAt,
    DateTime? leftAt,
    int version,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLitterMember.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLitterMember.copyWith.fieldName(...)`
class _$LitterMemberCWProxyImpl implements _$LitterMemberCWProxy {
  const _$LitterMemberCWProxyImpl(this._value);

  final LitterMember _value;

  @override
  LitterMember id(String id) => this(id: id);

  @override
  LitterMember litterId(String litterId) => this(litterId: litterId);

  @override
  LitterMember memberType(LitterMemberMemberTypeEnum memberType) =>
      this(memberType: memberType);

  @override
  LitterMember pupIdentityId(String? pupIdentityId) =>
      this(pupIdentityId: pupIdentityId);

  @override
  LitterMember hamsterId(String? hamsterId) => this(hamsterId: hamsterId);

  @override
  LitterMember role(LitterMemberRoleEnum role) => this(role: role);

  @override
  LitterMember joinedAt(DateTime joinedAt) => this(joinedAt: joinedAt);

  @override
  LitterMember leftAt(DateTime? leftAt) => this(leftAt: leftAt);

  @override
  LitterMember version(int version) => this(version: version);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LitterMember(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LitterMember(...).copyWith(id: 12, name: "My name")
  /// ````
  LitterMember call({
    Object? id = const $CopyWithPlaceholder(),
    Object? litterId = const $CopyWithPlaceholder(),
    Object? memberType = const $CopyWithPlaceholder(),
    Object? pupIdentityId = const $CopyWithPlaceholder(),
    Object? hamsterId = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? joinedAt = const $CopyWithPlaceholder(),
    Object? leftAt = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
  }) {
    return LitterMember(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      litterId: litterId == const $CopyWithPlaceholder()
          ? _value.litterId
          // ignore: cast_nullable_to_non_nullable
          : litterId as String,
      memberType: memberType == const $CopyWithPlaceholder()
          ? _value.memberType
          // ignore: cast_nullable_to_non_nullable
          : memberType as LitterMemberMemberTypeEnum,
      pupIdentityId: pupIdentityId == const $CopyWithPlaceholder()
          ? _value.pupIdentityId
          // ignore: cast_nullable_to_non_nullable
          : pupIdentityId as String?,
      hamsterId: hamsterId == const $CopyWithPlaceholder()
          ? _value.hamsterId
          // ignore: cast_nullable_to_non_nullable
          : hamsterId as String?,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as LitterMemberRoleEnum,
      joinedAt: joinedAt == const $CopyWithPlaceholder()
          ? _value.joinedAt
          // ignore: cast_nullable_to_non_nullable
          : joinedAt as DateTime,
      leftAt: leftAt == const $CopyWithPlaceholder()
          ? _value.leftAt
          // ignore: cast_nullable_to_non_nullable
          : leftAt as DateTime?,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
    );
  }
}

extension $LitterMemberCopyWith on LitterMember {
  /// Returns a callable class that can be used as follows: `instanceOfLitterMember.copyWith(...)` or like so:`instanceOfLitterMember.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LitterMemberCWProxy get copyWith => _$LitterMemberCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LitterMember _$LitterMemberFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'LitterMember',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'litter_id',
            'member_type',
            'role',
            'joined_at',
            'version',
          ],
        );
        final val = LitterMember(
          id: $checkedConvert('id', (v) => v as String),
          litterId: $checkedConvert('litter_id', (v) => v as String),
          memberType: $checkedConvert(
            'member_type',
            (v) => $enumDecode(_$LitterMemberMemberTypeEnumEnumMap, v),
          ),
          pupIdentityId: $checkedConvert(
            'pup_identity_id',
            (v) => v as String?,
          ),
          hamsterId: $checkedConvert('hamster_id', (v) => v as String?),
          role: $checkedConvert(
            'role',
            (v) => $enumDecode(_$LitterMemberRoleEnumEnumMap, v),
          ),
          joinedAt: $checkedConvert(
            'joined_at',
            (v) => DateTime.parse(v as String),
          ),
          leftAt: $checkedConvert(
            'left_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          version: $checkedConvert('version', (v) => (v as num).toInt()),
        );
        return val;
      },
      fieldKeyMap: const {
        'litterId': 'litter_id',
        'memberType': 'member_type',
        'pupIdentityId': 'pup_identity_id',
        'hamsterId': 'hamster_id',
        'joinedAt': 'joined_at',
        'leftAt': 'left_at',
      },
    );

Map<String, dynamic> _$LitterMemberToJson(LitterMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'litter_id': instance.litterId,
      'member_type': _$LitterMemberMemberTypeEnumEnumMap[instance.memberType]!,
      'pup_identity_id': ?instance.pupIdentityId,
      'hamster_id': ?instance.hamsterId,
      'role': _$LitterMemberRoleEnumEnumMap[instance.role]!,
      'joined_at': instance.joinedAt.toIso8601String(),
      'left_at': ?instance.leftAt?.toIso8601String(),
      'version': instance.version,
    };

const _$LitterMemberMemberTypeEnumEnumMap = {
  LitterMemberMemberTypeEnum.pupIdentity: 'pup_identity',
  LitterMemberMemberTypeEnum.hamster: 'hamster',
};

const _$LitterMemberRoleEnumEnumMap = {
  LitterMemberRoleEnum.offspring: 'offspring',
};
