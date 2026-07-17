// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_organization_member_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpdateOrganizationMemberRequestCWProxy {
  UpdateOrganizationMemberRequest role(
    UpdateOrganizationMemberRequestRoleEnum? role,
  );

  UpdateOrganizationMemberRequest displayName(String? displayName);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateOrganizationMemberRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateOrganizationMemberRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateOrganizationMemberRequest call({
    UpdateOrganizationMemberRequestRoleEnum? role,
    String? displayName,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpdateOrganizationMemberRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpdateOrganizationMemberRequest.copyWith.fieldName(...)`
class _$UpdateOrganizationMemberRequestCWProxyImpl
    implements _$UpdateOrganizationMemberRequestCWProxy {
  const _$UpdateOrganizationMemberRequestCWProxyImpl(this._value);

  final UpdateOrganizationMemberRequest _value;

  @override
  UpdateOrganizationMemberRequest role(
    UpdateOrganizationMemberRequestRoleEnum? role,
  ) => this(role: role);

  @override
  UpdateOrganizationMemberRequest displayName(String? displayName) =>
      this(displayName: displayName);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateOrganizationMemberRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateOrganizationMemberRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateOrganizationMemberRequest call({
    Object? role = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
  }) {
    return UpdateOrganizationMemberRequest(
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as UpdateOrganizationMemberRequestRoleEnum?,
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String?,
    );
  }
}

extension $UpdateOrganizationMemberRequestCopyWith
    on UpdateOrganizationMemberRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUpdateOrganizationMemberRequest.copyWith(...)` or like so:`instanceOfUpdateOrganizationMemberRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpdateOrganizationMemberRequestCWProxy get copyWith =>
      _$UpdateOrganizationMemberRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateOrganizationMemberRequest _$UpdateOrganizationMemberRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'UpdateOrganizationMemberRequest',
  json,
  ($checkedConvert) {
    final val = UpdateOrganizationMemberRequest(
      role: $checkedConvert(
        'role',
        (v) => $enumDecodeNullable(
          _$UpdateOrganizationMemberRequestRoleEnumEnumMap,
          v,
        ),
      ),
      displayName: $checkedConvert('display_name', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {'displayName': 'display_name'},
);

Map<String, dynamic> _$UpdateOrganizationMemberRequestToJson(
  UpdateOrganizationMemberRequest instance,
) => <String, dynamic>{
  'role': ?_$UpdateOrganizationMemberRequestRoleEnumEnumMap[instance.role],
  'display_name': ?instance.displayName,
};

const _$UpdateOrganizationMemberRequestRoleEnumEnumMap = {
  UpdateOrganizationMemberRequestRoleEnum.breeder: 'breeder',
  UpdateOrganizationMemberRequestRoleEnum.caretaker: 'caretaker',
  UpdateOrganizationMemberRequestRoleEnum.staff: 'staff',
  UpdateOrganizationMemberRequestRoleEnum.viewer: 'viewer',
};
