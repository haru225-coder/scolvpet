//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_customer_session_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateCustomerSessionRequest {
  /// Returns a new [CreateCustomerSessionRequest] instance.
  CreateCustomerSessionRequest({

    required  this.phone,

    required  this.verificationId,

    required  this.code,
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





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateCustomerSessionRequest &&
      other.phone == phone &&
      other.verificationId == verificationId &&
      other.code == code;

    @override
    int get hashCode =>
        phone.hashCode +
        verificationId.hashCode +
        code.hashCode;

  factory CreateCustomerSessionRequest.fromJson(Map<String, dynamic> json) => _$CreateCustomerSessionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateCustomerSessionRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
