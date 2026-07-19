//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device_info.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DeviceInfo {
  /// Returns a new [DeviceInfo] instance.
  DeviceInfo({

    required  this.platform,

     this.deviceName,

    required  this.appVersion,

     this.pushToken,
  });

  @JsonKey(

    name: r'platform',
    required: true,
    includeIfNull: false,
  )


  final DeviceInfoPlatformEnum platform;



  @JsonKey(

    name: r'device_name',
    required: false,
    includeIfNull: false,
  )


  final String? deviceName;



  @JsonKey(

    name: r'app_version',
    required: true,
    includeIfNull: false,
  )


  final String appVersion;



  @JsonKey(

    name: r'push_token',
    required: false,
    includeIfNull: false,
  )


  final String? pushToken;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DeviceInfo &&
      other.platform == platform &&
      other.deviceName == deviceName &&
      other.appVersion == appVersion &&
      other.pushToken == pushToken;

    @override
    int get hashCode =>
        platform.hashCode +
        (deviceName == null ? 0 : deviceName.hashCode) +
        appVersion.hashCode +
        (pushToken == null ? 0 : pushToken.hashCode);

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => _$DeviceInfoFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceInfoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum DeviceInfoPlatformEnum {
@JsonValue(r'ios')
ios(r'ios'),
@JsonValue(r'android')
android(r'android');

const DeviceInfoPlatformEnum(this.value);

final String value;

@override
String toString() => value;
}
