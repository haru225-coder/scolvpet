//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_customer_wechat_phone_binding_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateCustomerWechatPhoneBindingRequest {
  /// Returns a new [CreateCustomerWechatPhoneBindingRequest] instance.
  CreateCustomerWechatPhoneBindingRequest({

    required  this.wechatTicket,

    required  this.phoneCode,
  });

      /// wt_ 开头的一次性票据，10 分钟有效
  @JsonKey(

    name: r'wechat_ticket',
    required: true,
    includeIfNull: false,
  )


  final String wechatTicket;



      /// 微信 getPhoneNumber 返回的一次性凭证
  @JsonKey(

    name: r'phone_code',
    required: true,
    includeIfNull: false,
  )


  final String phoneCode;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateCustomerWechatPhoneBindingRequest &&
      other.wechatTicket == wechatTicket &&
      other.phoneCode == phoneCode;

    @override
    int get hashCode =>
        wechatTicket.hashCode +
        phoneCode.hashCode;

  factory CreateCustomerWechatPhoneBindingRequest.fromJson(Map<String, dynamic> json) => _$CreateCustomerWechatPhoneBindingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateCustomerWechatPhoneBindingRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
