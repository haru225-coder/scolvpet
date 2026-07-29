//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_breeder_wechat_session_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateBreederWechatSessionRequest {
  /// Returns a new [CreateBreederWechatSessionRequest] instance.
  CreateBreederWechatSessionRequest({

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
    bool operator ==(Object other) => identical(this, other) || other is CreateBreederWechatSessionRequest &&
      other.jsCode == jsCode;

    @override
    int get hashCode =>
        jsCode.hashCode;

  factory CreateBreederWechatSessionRequest.fromJson(Map<String, dynamic> json) => _$CreateBreederWechatSessionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateBreederWechatSessionRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
