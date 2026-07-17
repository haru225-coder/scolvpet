// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_member.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OrganizationMemberCWProxy {
  OrganizationMember id(String id);

  OrganizationMember organizationId(String organizationId);

  OrganizationMember accountId(String? accountId);

  OrganizationMember phone(String phone);

  OrganizationMember displayName(String? displayName);

  OrganizationMember role(OrganizationMemberRoleEnum role);

  OrganizationMember status(OrganizationMemberStatusEnum status);

  OrganizationMember invitedAt(DateTime invitedAt);

  OrganizationMember acceptedAt(DateTime? acceptedAt);

  OrganizationMember revokedAt(DateTime? revokedAt);

  OrganizationMember version(int version);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OrganizationMember(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OrganizationMember(...).copyWith(id: 12, name: "My name")
  /// ````
  OrganizationMember call({
    String id,
    String organizationId,
    String? accountId,
    String phone,
    String? displayName,
    OrganizationMemberRoleEnum role,
    OrganizationMemberStatusEnum status,
    DateTime invitedAt,
    DateTime? acceptedAt,
    DateTime? revokedAt,
    int version,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOrganizationMember.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOrganizationMember.copyWith.fieldName(...)`
class _$OrganizationMemberCWProxyImpl implements _$OrganizationMemberCWProxy {
  const _$OrganizationMemberCWProxyImpl(this._value);

  final OrganizationMember _value;

  @override
  OrganizationMember id(String id) => this(id: id);

  @override
  OrganizationMember organizationId(String organizationId) =>
      this(organizationId: organizationId);

  @override
  OrganizationMember accountId(String? accountId) => this(accountId: accountId);

  @override
  OrganizationMember phone(String phone) => this(phone: phone);

  @override
  OrganizationMember displayName(String? displayName) =>
      this(displayName: displayName);

  @override
  OrganizationMember role(OrganizationMemberRoleEnum role) => this(role: role);

  @override
  OrganizationMember status(OrganizationMemberStatusEnum status) =>
      this(status: status);

  @override
  OrganizationMember invitedAt(DateTime invitedAt) =>
      this(invitedAt: invitedAt);

  @override
  OrganizationMember acceptedAt(DateTime? acceptedAt) =>
      this(acceptedAt: acceptedAt);

  @override
  OrganizationMember revokedAt(DateTime? revokedAt) =>
      this(revokedAt: revokedAt);

  @override
  OrganizationMember version(int version) => this(version: version);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OrganizationMember(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OrganizationMember(...).copyWith(id: 12, name: "My name")
  /// ````
  OrganizationMember call({
    Object? id = const $CopyWithPlaceholder(),
    Object? organizationId = const $CopyWithPlaceholder(),
    Object? accountId = const $CopyWithPlaceholder(),
    Object? phone = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? invitedAt = const $CopyWithPlaceholder(),
    Object? acceptedAt = const $CopyWithPlaceholder(),
    Object? revokedAt = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
  }) {
    return OrganizationMember(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      organizationId: organizationId == const $CopyWithPlaceholder()
          ? _value.organizationId
          // ignore: cast_nullable_to_non_nullable
          : organizationId as String,
      accountId: accountId == const $CopyWithPlaceholder()
          ? _value.accountId
          // ignore: cast_nullable_to_non_nullable
          : accountId as String?,
      phone: phone == const $CopyWithPlaceholder()
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String,
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String?,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as OrganizationMemberRoleEnum,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as OrganizationMemberStatusEnum,
      invitedAt: invitedAt == const $CopyWithPlaceholder()
          ? _value.invitedAt
          // ignore: cast_nullable_to_non_nullable
          : invitedAt as DateTime,
      acceptedAt: acceptedAt == const $CopyWithPlaceholder()
          ? _value.acceptedAt
          // ignore: cast_nullable_to_non_nullable
          : acceptedAt as DateTime?,
      revokedAt: revokedAt == const $CopyWithPlaceholder()
          ? _value.revokedAt
          // ignore: cast_nullable_to_non_nullable
          : revokedAt as DateTime?,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
    );
  }
}

extension $OrganizationMemberCopyWith on OrganizationMember {
  /// Returns a callable class that can be used as follows: `instanceOfOrganizationMember.copyWith(...)` or like so:`instanceOfOrganizationMember.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OrganizationMemberCWProxy get copyWith =>
      _$OrganizationMemberCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganizationMember _$OrganizationMemberFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'OrganizationMember',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'organization_id',
            'phone',
            'role',
            'status',
            'invited_at',
            'version',
          ],
        );
        final val = OrganizationMember(
          id: $checkedConvert('id', (v) => v as String),
          organizationId: $checkedConvert(
            'organization_id',
            (v) => v as String,
          ),
          accountId: $checkedConvert('account_id', (v) => v as String?),
          phone: $checkedConvert('phone', (v) => v as String),
          displayName: $checkedConvert('display_name', (v) => v as String?),
          role: $checkedConvert(
            'role',
            (v) => $enumDecode(_$OrganizationMemberRoleEnumEnumMap, v),
          ),
          status: $checkedConvert(
            'status',
            (v) => $enumDecode(_$OrganizationMemberStatusEnumEnumMap, v),
          ),
          invitedAt: $checkedConvert(
            'invited_at',
            (v) => DateTime.parse(v as String),
          ),
          acceptedAt: $checkedConvert(
            'accepted_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          revokedAt: $checkedConvert(
            'revoked_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          version: $checkedConvert('version', (v) => (v as num).toInt()),
        );
        return val;
      },
      fieldKeyMap: const {
        'organizationId': 'organization_id',
        'accountId': 'account_id',
        'displayName': 'display_name',
        'invitedAt': 'invited_at',
        'acceptedAt': 'accepted_at',
        'revokedAt': 'revoked_at',
      },
    );

Map<String, dynamic> _$OrganizationMemberToJson(OrganizationMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organization_id': instance.organizationId,
      'account_id': ?instance.accountId,
      'phone': instance.phone,
      'display_name': ?instance.displayName,
      'role': _$OrganizationMemberRoleEnumEnumMap[instance.role]!,
      'status': _$OrganizationMemberStatusEnumEnumMap[instance.status]!,
      'invited_at': instance.invitedAt.toIso8601String(),
      'accepted_at': ?instance.acceptedAt?.toIso8601String(),
      'revoked_at': ?instance.revokedAt?.toIso8601String(),
      'version': instance.version,
    };

const _$OrganizationMemberRoleEnumEnumMap = {
  OrganizationMemberRoleEnum.owner: 'owner',
  OrganizationMemberRoleEnum.breeder: 'breeder',
  OrganizationMemberRoleEnum.caretaker: 'caretaker',
  OrganizationMemberRoleEnum.staff: 'staff',
  OrganizationMemberRoleEnum.viewer: 'viewer',
};

const _$OrganizationMemberStatusEnumEnumMap = {
  OrganizationMemberStatusEnum.invited: 'invited',
  OrganizationMemberStatusEnum.active: 'active',
  OrganizationMemberStatusEnum.revoked: 'revoked',
};
