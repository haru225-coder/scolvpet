//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/customer_wechat_bind_ticket_response_data.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'customer_wechat_bind_ticket_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CustomerWechatBindTicketResponse {
  /// Returns a new [CustomerWechatBindTicketResponse] instance.
  CustomerWechatBindTicketResponse({

     this.data,

     this.meta,
  });

  @JsonKey(

    name: r'data',
    required: false,
    includeIfNull: false,
  )


  final CustomerWechatBindTicketResponseData? data;



  @JsonKey(

    name: r'meta',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CustomerWechatBindTicketResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory CustomerWechatBindTicketResponse.fromJson(Map<String, dynamic> json) => _$CustomerWechatBindTicketResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerWechatBindTicketResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
