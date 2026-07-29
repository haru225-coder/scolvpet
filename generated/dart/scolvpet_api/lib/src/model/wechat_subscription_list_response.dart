//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/wechat_subscription.dart';
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wechat_subscription_list_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WechatSubscriptionListResponse {
  /// Returns a new [WechatSubscriptionListResponse] instance.
  WechatSubscriptionListResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final List<WechatSubscription> data;



  @JsonKey(

    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WechatSubscriptionListResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory WechatSubscriptionListResponse.fromJson(Map<String, dynamic> json) => _$WechatSubscriptionListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WechatSubscriptionListResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
