//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/device_info.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'phone_code_login_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PhoneCodeLoginRequest {
  /// Returns a new [PhoneCodeLoginRequest] instance.
  PhoneCodeLoginRequest({

    required  this.phone,

    required  this.verificationId,

    required  this.code,

    required  this.device,
  });

  @JsonKey(
    
    name: r'phone',
    required: true,
    includeIfNull: false,
  )


  final String phone;



  @JsonKey(
    
    name: r'verification_id',
    required: true,
    includeIfNull: false,
  )


  final String verificationId;



  @JsonKey(
    
    name: r'code',
    required: true,
    includeIfNull: false,
  )


  final String code;



  @JsonKey(
    
    name: r'device',
    required: true,
    includeIfNull: false,
  )


  final DeviceInfo device;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PhoneCodeLoginRequest &&
      other.phone == phone &&
      other.verificationId == verificationId &&
      other.code == code &&
      other.device == device;

    @override
    int get hashCode =>
        phone.hashCode +
        verificationId.hashCode +
        code.hashCode +
        device.hashCode;

  factory PhoneCodeLoginRequest.fromJson(Map<String, dynamic> json) => _$PhoneCodeLoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PhoneCodeLoginRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

