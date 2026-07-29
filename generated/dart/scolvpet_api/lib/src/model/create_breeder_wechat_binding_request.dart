//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_breeder_wechat_binding_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateBreederWechatBindingRequest {
  /// Returns a new [CreateBreederWechatBindingRequest] instance.
  CreateBreederWechatBindingRequest({

    required  this.wechatTicket,

    required  this.phone,

    required  this.verificationId,

    required  this.code,
  });

      /// bwt_ 开头的一次性绑定票据
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
    bool operator ==(Object other) => identical(this, other) || other is CreateBreederWechatBindingRequest &&
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

  factory CreateBreederWechatBindingRequest.fromJson(Map<String, dynamic> json) => _$CreateBreederWechatBindingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateBreederWechatBindingRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
