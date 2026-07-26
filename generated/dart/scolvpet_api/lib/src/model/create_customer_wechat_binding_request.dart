//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_customer_wechat_binding_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateCustomerWechatBindingRequest {
  /// Returns a new [CreateCustomerWechatBindingRequest] instance.
  CreateCustomerWechatBindingRequest({

    required  this.wechatTicket,

    required  this.phone,

    required  this.verificationId,

    required  this.code,
  });

      /// wt_ 开头的一次性票据
  @JsonKey(

    name: r'wechat_ticket',
    required: true,
    includeIfNull: false,
  )


  final String wechatTicket;



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
    bool operator ==(Object other) => identical(this, other) || other is CreateCustomerWechatBindingRequest &&
      other.wechatTicket == wechatTicket &&
      other.phone == phone &&
      other.verificationId == verificationId &&
      other.code == code;

    @override
    int get hashCode =>
        wechatTicket.hashCode +
        phone.hashCode +
        verificationId.hashCode +
        code.hashCode;

  factory CreateCustomerWechatBindingRequest.fromJson(Map<String, dynamic> json) => _$CreateCustomerWechatBindingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateCustomerWechatBindingRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
