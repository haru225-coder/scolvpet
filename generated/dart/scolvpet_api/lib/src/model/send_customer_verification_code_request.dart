//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'send_customer_verification_code_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SendCustomerVerificationCodeRequest {
  /// Returns a new [SendCustomerVerificationCodeRequest] instance.
  SendCustomerVerificationCodeRequest({

    required  this.phone,

     this.purpose = SendCustomerVerificationCodeRequestPurposeEnum.login,
  });

  @JsonKey(

    name: r'phone',
    required: true,
    includeIfNull: false,
  )


  final String phone;



  @JsonKey(
    defaultValue: SendCustomerVerificationCodeRequestPurposeEnum.login,
    name: r'purpose',
    required: false,
    includeIfNull: false,
  )


  final SendCustomerVerificationCodeRequestPurposeEnum? purpose;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SendCustomerVerificationCodeRequest &&
      other.phone == phone &&
      other.purpose == purpose;

    @override
    int get hashCode =>
        phone.hashCode +
        purpose.hashCode;

  factory SendCustomerVerificationCodeRequest.fromJson(Map<String, dynamic> json) => _$SendCustomerVerificationCodeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SendCustomerVerificationCodeRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum SendCustomerVerificationCodeRequestPurposeEnum {
@JsonValue(r'login')
login(r'login');

const SendCustomerVerificationCodeRequestPurposeEnum(this.value);

final String value;

@override
String toString() => value;
}
