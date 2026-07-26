//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'customer_wechat_bind_ticket_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CustomerWechatBindTicketResponseData {
  /// Returns a new [CustomerWechatBindTicketResponseData] instance.
  CustomerWechatBindTicketResponseData({

    required  this.bindRequired,

    required  this.wechatTicket,
  });

  @JsonKey(

    name: r'bind_required',
    required: true,
    includeIfNull: false,
  )


  final bool bindRequired;



      /// wt_ 开头的一次性绑定票据，10 分钟有效，明文仅此一次
  @JsonKey(

    name: r'wechat_ticket',
    required: true,
    includeIfNull: false,
  )


  final String wechatTicket;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CustomerWechatBindTicketResponseData &&
      other.bindRequired == bindRequired &&
      other.wechatTicket == wechatTicket;

    @override
    int get hashCode =>
        bindRequired.hashCode +
        wechatTicket.hashCode;

  factory CustomerWechatBindTicketResponseData.fromJson(Map<String, dynamic> json) => _$CustomerWechatBindTicketResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerWechatBindTicketResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
