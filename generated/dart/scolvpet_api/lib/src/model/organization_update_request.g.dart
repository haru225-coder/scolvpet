// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_update_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OrganizationUpdateRequestCWProxy {
  OrganizationUpdateRequest name(String? name);

  OrganizationUpdateRequest mode(OrganizationUpdateRequestModeEnum? mode);

  OrganizationUpdateRequest timezone(String? timezone);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OrganizationUpdateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OrganizationUpdateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  OrganizationUpdateRequest call({
    String? name,
    OrganizationUpdateRequestModeEnum? mode,
    String? timezone,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOrganizationUpdateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOrganizationUpdateRequest.copyWith.fieldName(...)`
class _$OrganizationUpdateRequestCWProxyImpl
    implements _$OrganizationUpdateRequestCWProxy {
  const _$OrganizationUpdateRequestCWProxyImpl(this._value);

  final OrganizationUpdateRequest _value;

  @override
  OrganizationUpdateRequest name(String? name) => this(name: name);

  @override
  OrganizationUpdateRequest mode(OrganizationUpdateRequestModeEnum? mode) =>
      this(mode: mode);

  @override
  OrganizationUpdateRequest timezone(String? timezone) =>
      this(timezone: timezone);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OrganizationUpdateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OrganizationUpdateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  OrganizationUpdateRequest call({
    Object? name = const $CopyWithPlaceholder(),
    Object? mode = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
  }) {
    return OrganizationUpdateRequest(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      mode: mode == const $CopyWithPlaceholder()
          ? _value.mode
          // ignore: cast_nullable_to_non_nullable
          : mode as OrganizationUpdateRequestModeEnum?,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String?,
    );
  }
}

extension $OrganizationUpdateRequestCopyWith on OrganizationUpdateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfOrganizationUpdateRequest.copyWith(...)` or like so:`instanceOfOrganizationUpdateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OrganizationUpdateRequestCWProxy get copyWith =>
      _$OrganizationUpdateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganizationUpdateRequest _$OrganizationUpdateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('OrganizationUpdateRequest', json, ($checkedConvert) {
  final val = OrganizationUpdateRequest(
    name: $checkedConvert('name', (v) => v as String?),
    mode: $checkedConvert(
      'mode',
      (v) => $enumDecodeNullable(_$OrganizationUpdateRequestModeEnumEnumMap, v),
    ),
    timezone: $checkedConvert('timezone', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$OrganizationUpdateRequestToJson(
  OrganizationUpdateRequest instance,
) => <String, dynamic>{
  'name': ?instance.name,
  'mode': ?_$OrganizationUpdateRequestModeEnumEnumMap[instance.mode],
  'timezone': ?instance.timezone,
};

const _$OrganizationUpdateRequestModeEnumEnumMap = {
  OrganizationUpdateRequestModeEnum.personal: 'personal',
  OrganizationUpdateRequestModeEnum.professional: 'professional',
};
