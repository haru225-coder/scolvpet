// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_organization_member_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$InviteOrganizationMemberRequestCWProxy {
  InviteOrganizationMemberRequest phone(String phone);

  InviteOrganizationMemberRequest role(
    InviteOrganizationMemberRequestRoleEnum role,
  );

  InviteOrganizationMemberRequest displayName(String? displayName);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `InviteOrganizationMemberRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// InviteOrganizationMemberRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  InviteOrganizationMemberRequest call({
    String phone,
    InviteOrganizationMemberRequestRoleEnum role,
    String? displayName,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfInviteOrganizationMemberRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfInviteOrganizationMemberRequest.copyWith.fieldName(...)`
class _$InviteOrganizationMemberRequestCWProxyImpl
    implements _$InviteOrganizationMemberRequestCWProxy {
  const _$InviteOrganizationMemberRequestCWProxyImpl(this._value);

  final InviteOrganizationMemberRequest _value;

  @override
  InviteOrganizationMemberRequest phone(String phone) => this(phone: phone);

  @override
  InviteOrganizationMemberRequest role(
    InviteOrganizationMemberRequestRoleEnum role,
  ) => this(role: role);

  @override
  InviteOrganizationMemberRequest displayName(String? displayName) =>
      this(displayName: displayName);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `InviteOrganizationMemberRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// InviteOrganizationMemberRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  InviteOrganizationMemberRequest call({
    Object? phone = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
  }) {
    return InviteOrganizationMemberRequest(
      phone: phone == const $CopyWithPlaceholder()
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as InviteOrganizationMemberRequestRoleEnum,
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String?,
    );
  }
}

extension $InviteOrganizationMemberRequestCopyWith
    on InviteOrganizationMemberRequest {
  /// Returns a callable class that can be used as follows: `instanceOfInviteOrganizationMemberRequest.copyWith(...)` or like so:`instanceOfInviteOrganizationMemberRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$InviteOrganizationMemberRequestCWProxy get copyWith =>
      _$InviteOrganizationMemberRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InviteOrganizationMemberRequest _$InviteOrganizationMemberRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'InviteOrganizationMemberRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['phone', 'role']);
    final val = InviteOrganizationMemberRequest(
      phone: $checkedConvert('phone', (v) => v as String),
      role: $checkedConvert(
        'role',
        (v) => $enumDecode(_$InviteOrganizationMemberRequestRoleEnumEnumMap, v),
      ),
      displayName: $checkedConvert('display_name', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {'displayName': 'display_name'},
);

Map<String, dynamic> _$InviteOrganizationMemberRequestToJson(
  InviteOrganizationMemberRequest instance,
) => <String, dynamic>{
  'phone': instance.phone,
  'role': _$InviteOrganizationMemberRequestRoleEnumEnumMap[instance.role]!,
  'display_name': ?instance.displayName,
};

const _$InviteOrganizationMemberRequestRoleEnumEnumMap = {
  InviteOrganizationMemberRequestRoleEnum.breeder: 'breeder',
  InviteOrganizationMemberRequestRoleEnum.caretaker: 'caretaker',
  InviteOrganizationMemberRequestRoleEnum.staff: 'staff',
  InviteOrganizationMemberRequestRoleEnum.viewer: 'viewer',
};
