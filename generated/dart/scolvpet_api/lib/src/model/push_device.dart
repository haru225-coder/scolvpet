//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'push_device.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PushDevice {
  /// Returns a new [PushDevice] instance.
  PushDevice({

    required  this.id,

    required  this.platform,

    required  this.provider,

    required  this.token,

     this.deviceName,

     this.appVersion,

    required  this.enabled,

    required  this.lastSeenAt,

    required  this.version,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'platform',
    required: true,
    includeIfNull: false,
  )


  final PushDevicePlatformEnum platform;



  @JsonKey(
    
    name: r'provider',
    required: true,
    includeIfNull: false,
  )


  final PushDeviceProviderEnum provider;



  @JsonKey(
    
    name: r'token',
    required: true,
    includeIfNull: false,
  )


  final String token;



  @JsonKey(
    
    name: r'device_name',
    required: false,
    includeIfNull: false,
  )


  final String? deviceName;



  @JsonKey(
    
    name: r'app_version',
    required: false,
    includeIfNull: false,
  )


  final String? appVersion;



  @JsonKey(
    
    name: r'enabled',
    required: true,
    includeIfNull: false,
  )


  final bool enabled;



  @JsonKey(
    
    name: r'last_seen_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime lastSeenAt;



          // minimum: 1
  @JsonKey(
    
    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PushDevice &&
      other.id == id &&
      other.platform == platform &&
      other.provider == provider &&
      other.token == token &&
      other.deviceName == deviceName &&
      other.appVersion == appVersion &&
      other.enabled == enabled &&
      other.lastSeenAt == lastSeenAt &&
      other.version == version;

    @override
    int get hashCode =>
        id.hashCode +
        platform.hashCode +
        provider.hashCode +
        token.hashCode +
        (deviceName == null ? 0 : deviceName.hashCode) +
        (appVersion == null ? 0 : appVersion.hashCode) +
        enabled.hashCode +
        lastSeenAt.hashCode +
        version.hashCode;

  factory PushDevice.fromJson(Map<String, dynamic> json) => _$PushDeviceFromJson(json);

  Map<String, dynamic> toJson() => _$PushDeviceToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum PushDevicePlatformEnum {
@JsonValue(r'ios')
ios(r'ios'),
@JsonValue(r'android')
android(r'android'),
@JsonValue(r'web')
web(r'web'),
@JsonValue(r'unknown')
unknown(r'unknown');

const PushDevicePlatformEnum(this.value);

final String value;

@override
String toString() => value;
}



enum PushDeviceProviderEnum {
@JsonValue(r'apns')
apns(r'apns'),
@JsonValue(r'fcm')
fcm(r'fcm'),
@JsonValue(r'log')
log(r'log');

const PushDeviceProviderEnum(this.value);

final String value;

@override
String toString() => value;
}


