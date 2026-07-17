// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_device.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PushDeviceCWProxy {
  PushDevice id(String id);

  PushDevice platform(PushDevicePlatformEnum platform);

  PushDevice provider(PushDeviceProviderEnum provider);

  PushDevice token(String token);

  PushDevice deviceName(String? deviceName);

  PushDevice appVersion(String? appVersion);

  PushDevice enabled(bool enabled);

  PushDevice lastSeenAt(DateTime lastSeenAt);

  PushDevice version(int version);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PushDevice(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PushDevice(...).copyWith(id: 12, name: "My name")
  /// ````
  PushDevice call({
    String id,
    PushDevicePlatformEnum platform,
    PushDeviceProviderEnum provider,
    String token,
    String? deviceName,
    String? appVersion,
    bool enabled,
    DateTime lastSeenAt,
    int version,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPushDevice.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPushDevice.copyWith.fieldName(...)`
class _$PushDeviceCWProxyImpl implements _$PushDeviceCWProxy {
  const _$PushDeviceCWProxyImpl(this._value);

  final PushDevice _value;

  @override
  PushDevice id(String id) => this(id: id);

  @override
  PushDevice platform(PushDevicePlatformEnum platform) =>
      this(platform: platform);

  @override
  PushDevice provider(PushDeviceProviderEnum provider) =>
      this(provider: provider);

  @override
  PushDevice token(String token) => this(token: token);

  @override
  PushDevice deviceName(String? deviceName) => this(deviceName: deviceName);

  @override
  PushDevice appVersion(String? appVersion) => this(appVersion: appVersion);

  @override
  PushDevice enabled(bool enabled) => this(enabled: enabled);

  @override
  PushDevice lastSeenAt(DateTime lastSeenAt) => this(lastSeenAt: lastSeenAt);

  @override
  PushDevice version(int version) => this(version: version);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PushDevice(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PushDevice(...).copyWith(id: 12, name: "My name")
  /// ````
  PushDevice call({
    Object? id = const $CopyWithPlaceholder(),
    Object? platform = const $CopyWithPlaceholder(),
    Object? provider = const $CopyWithPlaceholder(),
    Object? token = const $CopyWithPlaceholder(),
    Object? deviceName = const $CopyWithPlaceholder(),
    Object? appVersion = const $CopyWithPlaceholder(),
    Object? enabled = const $CopyWithPlaceholder(),
    Object? lastSeenAt = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
  }) {
    return PushDevice(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      platform: platform == const $CopyWithPlaceholder()
          ? _value.platform
          // ignore: cast_nullable_to_non_nullable
          : platform as PushDevicePlatformEnum,
      provider: provider == const $CopyWithPlaceholder()
          ? _value.provider
          // ignore: cast_nullable_to_non_nullable
          : provider as PushDeviceProviderEnum,
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
      enabled: enabled == const $CopyWithPlaceholder()
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as bool,
      lastSeenAt: lastSeenAt == const $CopyWithPlaceholder()
          ? _value.lastSeenAt
          // ignore: cast_nullable_to_non_nullable
          : lastSeenAt as DateTime,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
    );
  }
}

extension $PushDeviceCopyWith on PushDevice {
  /// Returns a callable class that can be used as follows: `instanceOfPushDevice.copyWith(...)` or like so:`instanceOfPushDevice.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PushDeviceCWProxy get copyWith => _$PushDeviceCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushDevice _$PushDeviceFromJson(Map<String, dynamic> json) => $checkedCreate(
  'PushDevice',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'platform',
        'provider',
        'token',
        'enabled',
        'last_seen_at',
        'version',
      ],
    );
    final val = PushDevice(
      id: $checkedConvert('id', (v) => v as String),
      platform: $checkedConvert(
        'platform',
        (v) => $enumDecode(_$PushDevicePlatformEnumEnumMap, v),
      ),
      provider: $checkedConvert(
        'provider',
        (v) => $enumDecode(_$PushDeviceProviderEnumEnumMap, v),
      ),
      token: $checkedConvert('token', (v) => v as String),
      deviceName: $checkedConvert('device_name', (v) => v as String?),
      appVersion: $checkedConvert('app_version', (v) => v as String?),
      enabled: $checkedConvert('enabled', (v) => v as bool),
      lastSeenAt: $checkedConvert(
        'last_seen_at',
        (v) => DateTime.parse(v as String),
      ),
      version: $checkedConvert('version', (v) => (v as num).toInt()),
    );
    return val;
  },
  fieldKeyMap: const {
    'deviceName': 'device_name',
    'appVersion': 'app_version',
    'lastSeenAt': 'last_seen_at',
  },
);

Map<String, dynamic> _$PushDeviceToJson(PushDevice instance) =>
    <String, dynamic>{
      'id': instance.id,
      'platform': _$PushDevicePlatformEnumEnumMap[instance.platform]!,
      'provider': _$PushDeviceProviderEnumEnumMap[instance.provider]!,
      'token': instance.token,
      'device_name': ?instance.deviceName,
      'app_version': ?instance.appVersion,
      'enabled': instance.enabled,
      'last_seen_at': instance.lastSeenAt.toIso8601String(),
      'version': instance.version,
    };

const _$PushDevicePlatformEnumEnumMap = {
  PushDevicePlatformEnum.ios: 'ios',
  PushDevicePlatformEnum.android: 'android',
  PushDevicePlatformEnum.web: 'web',
  PushDevicePlatformEnum.unknown: 'unknown',
};

const _$PushDeviceProviderEnumEnumMap = {
  PushDeviceProviderEnum.apns: 'apns',
  PushDeviceProviderEnum.fcm: 'fcm',
  PushDeviceProviderEnum.log: 'log',
};
