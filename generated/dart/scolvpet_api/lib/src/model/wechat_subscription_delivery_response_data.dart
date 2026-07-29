//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wechat_subscription_delivery_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WechatSubscriptionDeliveryResponseData {
  /// Returns a new [WechatSubscriptionDeliveryResponseData] instance.
  WechatSubscriptionDeliveryResponseData({

    required  this.templateId,

    required  this.providerMessageId,

    required  this.sentAt,
  });

  @JsonKey(

    name: r'template_id',
    required: true,
    includeIfNull: false,
  )


  final String templateId;



  @JsonKey(

    name: r'provider_message_id',
    required: true,
    includeIfNull: false,
  )


  final String providerMessageId;



  @JsonKey(

    name: r'sent_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime sentAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WechatSubscriptionDeliveryResponseData &&
      other.templateId == templateId &&
      other.providerMessageId == providerMessageId &&
      other.sentAt == sentAt;

    @override
    int get hashCode =>
        templateId.hashCode +
        providerMessageId.hashCode +
        sentAt.hashCode;

  factory WechatSubscriptionDeliveryResponseData.fromJson(Map<String, dynamic> json) => _$WechatSubscriptionDeliveryResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$WechatSubscriptionDeliveryResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
