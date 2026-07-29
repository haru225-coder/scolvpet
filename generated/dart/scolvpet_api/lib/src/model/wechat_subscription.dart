//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wechat_subscription.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WechatSubscription {
  /// Returns a new [WechatSubscription] instance.
  WechatSubscription({

    required  this.id,

    required  this.templateId,

    required  this.status,

     this.page,

    required  this.grantedAt,

     this.lastSentAt,

    required  this.version,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(

    name: r'template_id',
    required: true,
    includeIfNull: false,
  )


  final String templateId;



  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final WechatSubscriptionStatusEnum status;



  @JsonKey(

    name: r'page',
    required: false,
    includeIfNull: false,
  )


  final String? page;



  @JsonKey(

    name: r'granted_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime grantedAt;



  @JsonKey(

    name: r'last_sent_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? lastSentAt;



          // minimum: 1
  @JsonKey(

    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WechatSubscription &&
      other.id == id &&
      other.templateId == templateId &&
      other.status == status &&
      other.page == page &&
      other.grantedAt == grantedAt &&
      other.lastSentAt == lastSentAt &&
      other.version == version;

    @override
    int get hashCode =>
        id.hashCode +
        templateId.hashCode +
        status.hashCode +
        (page == null ? 0 : page.hashCode) +
        grantedAt.hashCode +
        (lastSentAt == null ? 0 : lastSentAt.hashCode) +
        version.hashCode;

  factory WechatSubscription.fromJson(Map<String, dynamic> json) => _$WechatSubscriptionFromJson(json);

  Map<String, dynamic> toJson() => _$WechatSubscriptionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum WechatSubscriptionStatusEnum {
@JsonValue(r'accept')
accept(r'accept'),
@JsonValue(r'reject')
reject(r'reject'),
@JsonValue(r'ban')
ban(r'ban'),
@JsonValue(r'unknown')
unknown(r'unknown');

const WechatSubscriptionStatusEnum(this.value);

final String value;

@override
String toString() => value;
}
