//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reminder_delivery.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReminderDelivery {
  /// Returns a new [ReminderDelivery] instance.
  ReminderDelivery({

    required  this.channel,

    required  this.status,

    required  this.dedupeKey,

     this.attemptedAt,

     this.deliveredAt,

     this.failureCode,
  });

  @JsonKey(

    name: r'channel',
    required: true,
    includeIfNull: false,
  )


  final ReminderDeliveryChannelEnum channel;



  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final ReminderDeliveryStatusEnum status;



  @JsonKey(

    name: r'dedupe_key',
    required: true,
    includeIfNull: false,
  )


  final String dedupeKey;



  @JsonKey(

    name: r'attempted_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? attemptedAt;



  @JsonKey(

    name: r'delivered_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? deliveredAt;



  @JsonKey(

    name: r'failure_code',
    required: false,
    includeIfNull: false,
  )


  final String? failureCode;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ReminderDelivery &&
      other.channel == channel &&
      other.status == status &&
      other.dedupeKey == dedupeKey &&
      other.attemptedAt == attemptedAt &&
      other.deliveredAt == deliveredAt &&
      other.failureCode == failureCode;

    @override
    int get hashCode =>
        channel.hashCode +
        status.hashCode +
        dedupeKey.hashCode +
        (attemptedAt == null ? 0 : attemptedAt.hashCode) +
        (deliveredAt == null ? 0 : deliveredAt.hashCode) +
        (failureCode == null ? 0 : failureCode.hashCode);

  factory ReminderDelivery.fromJson(Map<String, dynamic> json) => _$ReminderDeliveryFromJson(json);

  Map<String, dynamic> toJson() => _$ReminderDeliveryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum ReminderDeliveryChannelEnum {
@JsonValue(r'in_app')
inApp(r'in_app'),
@JsonValue(r'local')
local(r'local'),
@JsonValue(r'app_push')
appPush(r'app_push'),
@JsonValue(r'wechat_service')
wechatService(r'wechat_service');

const ReminderDeliveryChannelEnum(this.value);

final String value;

@override
String toString() => value;
}



enum ReminderDeliveryStatusEnum {
@JsonValue(r'pending')
pending(r'pending'),
@JsonValue(r'succeeded')
succeeded(r'succeeded'),
@JsonValue(r'failed')
failed(r'failed'),
@JsonValue(r'read')
read(r'read'),
@JsonValue(r'disabled')
disabled(r'disabled');

const ReminderDeliveryStatusEnum(this.value);

final String value;

@override
String toString() => value;
}
