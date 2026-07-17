// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upsert_miniprogram_config_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpsertMiniprogramConfigRequestCWProxy {
  UpsertMiniprogramConfigRequest displayName(String? displayName);

  UpsertMiniprogramConfigRequest appId(String? appId);

  UpsertMiniprogramConfigRequest boundPublicSlug(String? boundPublicSlug);

  UpsertMiniprogramConfigRequest enabled(bool? enabled);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpsertMiniprogramConfigRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpsertMiniprogramConfigRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpsertMiniprogramConfigRequest call({
    String? displayName,
    String? appId,
    String? boundPublicSlug,
    bool? enabled,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpsertMiniprogramConfigRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpsertMiniprogramConfigRequest.copyWith.fieldName(...)`
class _$UpsertMiniprogramConfigRequestCWProxyImpl
    implements _$UpsertMiniprogramConfigRequestCWProxy {
  const _$UpsertMiniprogramConfigRequestCWProxyImpl(this._value);

  final UpsertMiniprogramConfigRequest _value;

  @override
  UpsertMiniprogramConfigRequest displayName(String? displayName) =>
      this(displayName: displayName);

  @override
  UpsertMiniprogramConfigRequest appId(String? appId) => this(appId: appId);

  @override
  UpsertMiniprogramConfigRequest boundPublicSlug(String? boundPublicSlug) =>
      this(boundPublicSlug: boundPublicSlug);

  @override
  UpsertMiniprogramConfigRequest enabled(bool? enabled) =>
      this(enabled: enabled);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpsertMiniprogramConfigRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpsertMiniprogramConfigRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpsertMiniprogramConfigRequest call({
    Object? displayName = const $CopyWithPlaceholder(),
    Object? appId = const $CopyWithPlaceholder(),
    Object? boundPublicSlug = const $CopyWithPlaceholder(),
    Object? enabled = const $CopyWithPlaceholder(),
  }) {
    return UpsertMiniprogramConfigRequest(
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String?,
      appId: appId == const $CopyWithPlaceholder()
          ? _value.appId
          // ignore: cast_nullable_to_non_nullable
          : appId as String?,
      boundPublicSlug: boundPublicSlug == const $CopyWithPlaceholder()
          ? _value.boundPublicSlug
          // ignore: cast_nullable_to_non_nullable
          : boundPublicSlug as String?,
      enabled: enabled == const $CopyWithPlaceholder()
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as bool?,
    );
  }
}

extension $UpsertMiniprogramConfigRequestCopyWith
    on UpsertMiniprogramConfigRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUpsertMiniprogramConfigRequest.copyWith(...)` or like so:`instanceOfUpsertMiniprogramConfigRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpsertMiniprogramConfigRequestCWProxy get copyWith =>
      _$UpsertMiniprogramConfigRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpsertMiniprogramConfigRequest _$UpsertMiniprogramConfigRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'UpsertMiniprogramConfigRequest',
  json,
  ($checkedConvert) {
    final val = UpsertMiniprogramConfigRequest(
      displayName: $checkedConvert('display_name', (v) => v as String?),
      appId: $checkedConvert('app_id', (v) => v as String?),
      boundPublicSlug: $checkedConvert(
        'bound_public_slug',
        (v) => v as String?,
      ),
      enabled: $checkedConvert('enabled', (v) => v as bool?),
    );
    return val;
  },
  fieldKeyMap: const {
    'displayName': 'display_name',
    'appId': 'app_id',
    'boundPublicSlug': 'bound_public_slug',
  },
);

Map<String, dynamic> _$UpsertMiniprogramConfigRequestToJson(
  UpsertMiniprogramConfigRequest instance,
) => <String, dynamic>{
  'display_name': ?instance.displayName,
  'app_id': ?instance.appId,
  'bound_public_slug': ?instance.boundPublicSlug,
  'enabled': ?instance.enabled,
};
