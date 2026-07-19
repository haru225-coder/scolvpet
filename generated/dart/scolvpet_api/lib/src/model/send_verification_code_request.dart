//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'send_verification_code_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SendVerificationCodeRequest {
  /// Returns a new [SendVerificationCodeRequest] instance.
  SendVerificationCodeRequest({

    required  this.phone,

    required  this.purpose,
  });

  @JsonKey(

    name: r'phone',
    required: true,
    includeIfNull: false,
  )


  final String phone;



  @JsonKey(

    name: r'purpose',
    required: true,
    includeIfNull: false,
  )


  final SendVerificationCodeRequestPurposeEnum purpose;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SendVerificationCodeRequest &&
      other.phone == phone &&
      other.purpose == purpose;

    @override
    int get hashCode =>
        phone.hashCode +
        purpose.hashCode;

  factory SendVerificationCodeRequest.fromJson(Map<String, dynamic> json) => _$SendVerificationCodeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SendVerificationCodeRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum SendVerificationCodeRequestPurposeEnum {
@JsonValue(r'login')
login(r'login');

const SendVerificationCodeRequestPurposeEnum(this.value);

final String value;

@override
String toString() => value;
}
