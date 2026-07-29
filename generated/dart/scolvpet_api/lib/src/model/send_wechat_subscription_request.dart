//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'send_wechat_subscription_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SendWechatSubscriptionRequest {
  /// Returns a new [SendWechatSubscriptionRequest] instance.
  SendWechatSubscriptionRequest({

    required  this.templateId,

     this.page,

    required  this.data,
  });

  @JsonKey(

    name: r'template_id',
    required: true,
    includeIfNull: false,
  )


  final String templateId;



  @JsonKey(

    name: r'page',
    required: false,
    includeIfNull: false,
  )


  final String? page;



  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final Map<String, String> data;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SendWechatSubscriptionRequest &&
      other.templateId == templateId &&
      other.page == page &&
      other.data == data;

    @override
    int get hashCode =>
        templateId.hashCode +
        (page == null ? 0 : page.hashCode) +
        data.hashCode;

  factory SendWechatSubscriptionRequest.fromJson(Map<String, dynamic> json) => _$SendWechatSubscriptionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SendWechatSubscriptionRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
