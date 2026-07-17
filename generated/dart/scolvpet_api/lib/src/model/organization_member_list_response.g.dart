// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_member_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OrganizationMemberListResponseCWProxy {
  OrganizationMemberListResponse data(List<OrganizationMember> data);

  OrganizationMemberListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OrganizationMemberListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OrganizationMemberListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  OrganizationMemberListResponse call({
    List<OrganizationMember> data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOrganizationMemberListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOrganizationMemberListResponse.copyWith.fieldName(...)`
class _$OrganizationMemberListResponseCWProxyImpl
    implements _$OrganizationMemberListResponseCWProxy {
  const _$OrganizationMemberListResponseCWProxyImpl(this._value);

  final OrganizationMemberListResponse _value;

  @override
  OrganizationMemberListResponse data(List<OrganizationMember> data) =>
      this(data: data);

  @override
  OrganizationMemberListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OrganizationMemberListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OrganizationMemberListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  OrganizationMemberListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return OrganizationMemberListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<OrganizationMember>,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $OrganizationMemberListResponseCopyWith
    on OrganizationMemberListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfOrganizationMemberListResponse.copyWith(...)` or like so:`instanceOfOrganizationMemberListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OrganizationMemberListResponseCWProxy get copyWith =>
      _$OrganizationMemberListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganizationMemberListResponse _$OrganizationMemberListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('OrganizationMemberListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = OrganizationMemberListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => OrganizationMember.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$OrganizationMemberListResponseToJson(
  OrganizationMemberListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'meta': instance.meta.toJson(),
};
