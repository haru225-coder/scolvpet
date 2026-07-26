//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_customer_wechat_session_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateCustomerWechatSessionRequest {
  /// Returns a new [CreateCustomerWechatSessionRequest] instance.
  CreateCustomerWechatSessionRequest({

    required  this.jsCode,
  });

      /// wx.login 返回的临时凭证
  @JsonKey(

    name: r'js_code',
    required: true,
    includeIfNull: false,
  )


  final String jsCode;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateCustomerWechatSessionRequest &&
      other.jsCode == jsCode;

    @override
    int get hashCode =>
        jsCode.hashCode;

  factory CreateCustomerWechatSessionRequest.fromJson(Map<String, dynamic> json) => _$CreateCustomerWechatSessionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateCustomerWechatSessionRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
