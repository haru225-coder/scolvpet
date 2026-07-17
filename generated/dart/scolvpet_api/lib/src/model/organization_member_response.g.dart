// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_member_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OrganizationMemberResponseCWProxy {
  OrganizationMemberResponse data(OrganizationMember data);

  OrganizationMemberResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OrganizationMemberResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OrganizationMemberResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  OrganizationMemberResponse call({OrganizationMember data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOrganizationMemberResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOrganizationMemberResponse.copyWith.fieldName(...)`
class _$OrganizationMemberResponseCWProxyImpl
    implements _$OrganizationMemberResponseCWProxy {
  const _$OrganizationMemberResponseCWProxyImpl(this._value);

  final OrganizationMemberResponse _value;

  @override
  OrganizationMemberResponse data(OrganizationMember data) => this(data: data);

  @override
  OrganizationMemberResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OrganizationMemberResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OrganizationMemberResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  OrganizationMemberResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return OrganizationMemberResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as OrganizationMember,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $OrganizationMemberResponseCopyWith on OrganizationMemberResponse {
  /// Returns a callable class that can be used as follows: `instanceOfOrganizationMemberResponse.copyWith(...)` or like so:`instanceOfOrganizationMemberResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OrganizationMemberResponseCWProxy get copyWith =>
      _$OrganizationMemberResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganizationMemberResponse _$OrganizationMemberResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('OrganizationMemberResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = OrganizationMemberResponse(
    data: $checkedConvert(
      'data',
      (v) => OrganizationMember.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$OrganizationMemberResponseToJson(
  OrganizationMemberResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
