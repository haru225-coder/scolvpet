//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/wechat_subscription_delivery_response_data.dart';
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wechat_subscription_delivery_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WechatSubscriptionDeliveryResponse {
  /// Returns a new [WechatSubscriptionDeliveryResponse] instance.
  WechatSubscriptionDeliveryResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final WechatSubscriptionDeliveryResponseData data;



  @JsonKey(

    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WechatSubscriptionDeliveryResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory WechatSubscriptionDeliveryResponse.fromJson(Map<String, dynamic> json) => _$WechatSubscriptionDeliveryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WechatSubscriptionDeliveryResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
