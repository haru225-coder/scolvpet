//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upsert_push_device_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpsertPushDeviceRequest {
  /// Returns a new [UpsertPushDeviceRequest] instance.
  UpsertPushDeviceRequest({

     this.platform,

     this.provider,

    required  this.token,

     this.deviceName,

     this.appVersion,
  });

  @JsonKey(

    name: r'platform',
    required: false,
    includeIfNull: false,
  )


  final UpsertPushDeviceRequestPlatformEnum? platform;



  @JsonKey(

    name: r'provider',
    required: false,
    includeIfNull: false,
  )


  final UpsertPushDeviceRequestProviderEnum? provider;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpsertPushDeviceRequest &&
      other.platform == platform &&
      other.provider == provider &&
      other.token == token &&
      other.deviceName == deviceName &&
      other.appVersion == appVersion;

    @override
    int get hashCode =>
        platform.hashCode +
        provider.hashCode +
        token.hashCode +
        (deviceName == null ? 0 : deviceName.hashCode) +
        (appVersion == null ? 0 : appVersion.hashCode);

  factory UpsertPushDeviceRequest.fromJson(Map<String, dynamic> json) => _$UpsertPushDeviceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpsertPushDeviceRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum UpsertPushDeviceRequestPlatformEnum {
@JsonValue(r'ios')
ios(r'ios'),
@JsonValue(r'android')
android(r'android'),
@JsonValue(r'web')
web(r'web'),
@JsonValue(r'unknown')
unknown(r'unknown');

const UpsertPushDeviceRequestPlatformEnum(this.value);

final String value;

@override
String toString() => value;
}



enum UpsertPushDeviceRequestProviderEnum {
@JsonValue(r'apns')
apns(r'apns'),
@JsonValue(r'fcm')
fcm(r'fcm'),
@JsonValue(r'log')
log(r'log');

const UpsertPushDeviceRequestProviderEnum(this.value);

final String value;

@override
String toString() => value;
}
