// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_info.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DeviceInfoCWProxy {
  DeviceInfo platform(DeviceInfoPlatformEnum platform);

  DeviceInfo deviceName(String? deviceName);

  DeviceInfo appVersion(String appVersion);

  DeviceInfo pushToken(String? pushToken);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeviceInfo(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeviceInfo(...).copyWith(id: 12, name: "My name")
  /// ````
  DeviceInfo call({
    DeviceInfoPlatformEnum platform,
    String? deviceName,
    String appVersion,
    String? pushToken,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDeviceInfo.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDeviceInfo.copyWith.fieldName(...)`
class _$DeviceInfoCWProxyImpl implements _$DeviceInfoCWProxy {
  const _$DeviceInfoCWProxyImpl(this._value);

  final DeviceInfo _value;

  @override
  DeviceInfo platform(DeviceInfoPlatformEnum platform) =>
      this(platform: platform);

  @override
  DeviceInfo deviceName(String? deviceName) => this(deviceName: deviceName);

  @override
  DeviceInfo appVersion(String appVersion) => this(appVersion: appVersion);

  @override
  DeviceInfo pushToken(String? pushToken) => this(pushToken: pushToken);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeviceInfo(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeviceInfo(...).copyWith(id: 12, name: "My name")
  /// ````
  DeviceInfo call({
    Object? platform = const $CopyWithPlaceholder(),
    Object? deviceName = const $CopyWithPlaceholder(),
    Object? appVersion = const $CopyWithPlaceholder(),
    Object? pushToken = const $CopyWithPlaceholder(),
  }) {
    return DeviceInfo(
      platform: platform == const $CopyWithPlaceholder()
          ? _value.platform
          // ignore: cast_nullable_to_non_nullable
          : platform as DeviceInfoPlatformEnum,
      deviceName: deviceName == const $CopyWithPlaceholder()
          ? _value.deviceName
          // ignore: cast_nullable_to_non_nullable
          : deviceName as String?,
      appVersion: appVersion == const $CopyWithPlaceholder()
          ? _value.appVersion
          // ignore: cast_nullable_to_non_nullable
          : appVersion as String,
      pushToken: pushToken == const $CopyWithPlaceholder()
          ? _value.pushToken
          // ignore: cast_nullable_to_non_nullable
          : pushToken as String?,
    );
  }
}

extension $DeviceInfoCopyWith on DeviceInfo {
  /// Returns a callable class that can be used as follows: `instanceOfDeviceInfo.copyWith(...)` or like so:`instanceOfDeviceInfo.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DeviceInfoCWProxy get copyWith => _$DeviceInfoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceInfo _$DeviceInfoFromJson(Map<String, dynamic> json) => $checkedCreate(
  'DeviceInfo',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['platform', 'app_version']);
    final val = DeviceInfo(
      platform: $checkedConvert(
        'platform',
        (v) => $enumDecode(_$DeviceInfoPlatformEnumEnumMap, v),
      ),
      deviceName: $checkedConvert('device_name', (v) => v as String?),
      appVersion: $checkedConvert('app_version', (v) => v as String),
      pushToken: $checkedConvert('push_token', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'deviceName': 'device_name',
    'appVersion': 'app_version',
    'pushToken': 'push_token',
  },
);

Map<String, dynamic> _$DeviceInfoToJson(DeviceInfo instance) =>
    <String, dynamic>{
      'platform': _$DeviceInfoPlatformEnumEnumMap[instance.platform]!,
      'device_name': ?instance.deviceName,
      'app_version': instance.appVersion,
      'push_token': ?instance.pushToken,
    };

const _$DeviceInfoPlatformEnumEnumMap = {
  DeviceInfoPlatformEnum.ios: 'ios',
  DeviceInfoPlatformEnum.android: 'android',
};
