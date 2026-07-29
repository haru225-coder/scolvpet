//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upsert_wechat_subscriptions_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpsertWechatSubscriptionsRequest {
  /// Returns a new [UpsertWechatSubscriptionsRequest] instance.
  UpsertWechatSubscriptionsRequest({

    required  this.templates,

     this.page,
  });

  @JsonKey(

    name: r'templates',
    required: true,
    includeIfNull: false,
  )


  final Map<String, UpsertWechatSubscriptionsRequestTemplatesEnum> templates;



  @JsonKey(

    name: r'page',
    required: false,
    includeIfNull: false,
  )


  final String? page;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpsertWechatSubscriptionsRequest &&
      other.templates == templates &&
      other.page == page;

    @override
    int get hashCode =>
        templates.hashCode +
        (page == null ? 0 : page.hashCode);

  factory UpsertWechatSubscriptionsRequest.fromJson(Map<String, dynamic> json) => _$UpsertWechatSubscriptionsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpsertWechatSubscriptionsRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum UpsertWechatSubscriptionsRequestTemplatesEnum {
@JsonValue(r'accept')
accept(r'accept'),
@JsonValue(r'reject')
reject(r'reject'),
@JsonValue(r'ban')
ban(r'ban'),
@JsonValue(r'unknown')
unknown(r'unknown');

const UpsertWechatSubscriptionsRequestTemplatesEnum(this.value);

final String value;

@override
String toString() => value;
}
