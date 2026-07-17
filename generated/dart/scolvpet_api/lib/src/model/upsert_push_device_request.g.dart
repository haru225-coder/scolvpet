// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upsert_push_device_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpsertPushDeviceRequestCWProxy {
  UpsertPushDeviceRequest platform(
    UpsertPushDeviceRequestPlatformEnum? platform,
  );

  UpsertPushDeviceRequest provider(
    UpsertPushDeviceRequestProviderEnum? provider,
  );

  UpsertPushDeviceRequest token(String token);

  UpsertPushDeviceRequest deviceName(String? deviceName);

  UpsertPushDeviceRequest appVersion(String? appVersion);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpsertPushDeviceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpsertPushDeviceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpsertPushDeviceRequest call({
    UpsertPushDeviceRequestPlatformEnum? platform,
    UpsertPushDeviceRequestProviderEnum? provider,
    String token,
    String? deviceName,
    String? appVersion,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpsertPushDeviceRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpsertPushDeviceRequest.copyWith.fieldName(...)`
class _$UpsertPushDeviceRequestCWProxyImpl
    implements _$UpsertPushDeviceRequestCWProxy {
  const _$UpsertPushDeviceRequestCWProxyImpl(this._value);

  final UpsertPushDeviceRequest _value;

  @override
  UpsertPushDeviceRequest platform(
    UpsertPushDeviceRequestPlatformEnum? platform,
  ) => this(platform: platform);

  @override
  UpsertPushDeviceRequest provider(
    UpsertPushDeviceRequestProviderEnum? provider,
  ) => this(provider: provider);

  @override
  UpsertPushDeviceRequest token(String token) => this(token: token);

  @override
  UpsertPushDeviceRequest deviceName(String? deviceName) =>
      this(deviceName: deviceName);

  @override
  UpsertPushDeviceRequest appVersion(String? appVersion) =>
      this(appVersion: appVersion);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpsertPushDeviceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpsertPushDeviceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpsertPushDeviceRequest call({
    Object? platform = const $CopyWithPlaceholder(),
    Object? provider = const $CopyWithPlaceholder(),
    Object? token = const $CopyWithPlaceholder(),
    Object? deviceName = const $CopyWithPlaceholder(),
    Object? appVersion = const $CopyWithPlaceholder(),
  }) {
    return UpsertPushDeviceRequest(
      platform: platform == const $CopyWithPlaceholder()
          ? _value.platform
          // ignore: cast_nullable_to_non_nullable
          : platform as UpsertPushDeviceRequestPlatformEnum?,
      provider: provider == const $CopyWithPlaceholder()
          ? _value.provider
          // ignore: cast_nullable_to_non_nullable
          : provider as UpsertPushDeviceRequestProviderEnum?,
      token: token == const $CopyWithPlaceholder()
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String,
      deviceName: deviceName == const $CopyWithPlaceholder()
          ? _value.deviceName
          // ignore: cast_nullable_to_non_nullable
          : deviceName as String?,
      appVersion: appVersion == const $CopyWithPlaceholder()
          ? _value.appVersion
          // ignore: cast_nullable_to_non_nullable
          : appVersion as String?,
    );
  }
}

extension $UpsertPushDeviceRequestCopyWith on UpsertPushDeviceRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUpsertPushDeviceRequest.copyWith(...)` or like so:`instanceOfUpsertPushDeviceRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpsertPushDeviceRequestCWProxy get copyWith =>
      _$UpsertPushDeviceRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpsertPushDeviceRequest _$UpsertPushDeviceRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'UpsertPushDeviceRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['token']);
    final val = UpsertPushDeviceRequest(
      platform: $checkedConvert(
        'platform',
        (v) => $enumDecodeNullable(
          _$UpsertPushDeviceRequestPlatformEnumEnumMap,
          v,
        ),
      ),
      provider: $checkedConvert(
        'provider',
        (v) => $enumDecodeNullable(
          _$UpsertPushDeviceRequestProviderEnumEnumMap,
          v,
        ),
      ),
      token: $checkedConvert('token', (v) => v as String),
      deviceName: $checkedConvert('device_name', (v) => v as String?),
      appVersion: $checkedConvert('app_version', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {'deviceName': 'device_name', 'appVersion': 'app_version'},
);

Map<String, dynamic> _$UpsertPushDeviceRequestToJson(
  UpsertPushDeviceRequest instance,
) => <String, dynamic>{
  'platform': ?_$UpsertPushDeviceRequestPlatformEnumEnumMap[instance.platform],
  'provider': ?_$UpsertPushDeviceRequestProviderEnumEnumMap[instance.provider],
  'token': instance.token,
  'device_name': ?instance.deviceName,
  'app_version': ?instance.appVersion,
};

const _$UpsertPushDeviceRequestPlatformEnumEnumMap = {
  UpsertPushDeviceRequestPlatformEnum.ios: 'ios',
  UpsertPushDeviceRequestPlatformEnum.android: 'android',
  UpsertPushDeviceRequestPlatformEnum.web: 'web',
  UpsertPushDeviceRequestPlatformEnum.unknown: 'unknown',
};

const _$UpsertPushDeviceRequestProviderEnumEnumMap = {
  UpsertPushDeviceRequestProviderEnum.apns: 'apns',
  UpsertPushDeviceRequestProviderEnum.fcm: 'fcm',
  UpsertPushDeviceRequestProviderEnum.log: 'log',
};
