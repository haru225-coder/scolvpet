// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OrganizationResponseCWProxy {
  OrganizationResponse data(Organization data);

  OrganizationResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OrganizationResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OrganizationResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  OrganizationResponse call({Organization data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOrganizationResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOrganizationResponse.copyWith.fieldName(...)`
class _$OrganizationResponseCWProxyImpl
    implements _$OrganizationResponseCWProxy {
  const _$OrganizationResponseCWProxyImpl(this._value);

  final OrganizationResponse _value;

  @override
  OrganizationResponse data(Organization data) => this(data: data);

  @override
  OrganizationResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OrganizationResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OrganizationResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  OrganizationResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return OrganizationResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as Organization,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $OrganizationResponseCopyWith on OrganizationResponse {
  /// Returns a callable class that can be used as follows: `instanceOfOrganizationResponse.copyWith(...)` or like so:`instanceOfOrganizationResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OrganizationResponseCWProxy get copyWith =>
      _$OrganizationResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganizationResponse _$OrganizationResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('OrganizationResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = OrganizationResponse(
    data: $checkedConvert(
      'data',
      (v) => Organization.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$OrganizationResponseToJson(
  OrganizationResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
