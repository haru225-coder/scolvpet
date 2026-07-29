//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/organization.dart';
import 'package:scolvpet_api/src/model/account.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'breeder_wechat_session_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BreederWechatSessionResponseData {
  /// Returns a new [BreederWechatSessionResponseData] instance.
  BreederWechatSessionResponseData({

     this.bindRequired,

     this.wechatTicket,

     this.tokenType,

     this.accessToken,

     this.expiresInSeconds,

     this.refreshToken,

     this.account,

     this.currentOrganization,

     this.memberRole,

     this.capabilities,
  });

  @JsonKey(

    name: r'bind_required',
    required: false,
    includeIfNull: false,
  )


  final BreederWechatSessionResponseDataBindRequiredEnum? bindRequired;



      /// bwt_ 开头的一次性 B 端绑定票据，10 分钟有效，明文仅此一次
  @JsonKey(

    name: r'wechat_ticket',
    required: false,
    includeIfNull: false,
  )


  final String? wechatTicket;



  @JsonKey(

    name: r'token_type',
    required: false,
    includeIfNull: false,
  )


  final BreederWechatSessionResponseDataTokenTypeEnum? tokenType;



  @JsonKey(

    name: r'access_token',
    required: false,
    includeIfNull: false,
  )


  final String? accessToken;



          // minimum: 60
  @JsonKey(

    name: r'expires_in_seconds',
    required: false,
    includeIfNull: false,
  )


  final int? expiresInSeconds;



  @JsonKey(

    name: r'refresh_token',
    required: false,
    includeIfNull: false,
  )


  final String? refreshToken;



  @JsonKey(

    name: r'account',
    required: false,
    includeIfNull: false,
  )


  final Account? account;



  @JsonKey(

    name: r'current_organization',
    required: false,
    includeIfNull: false,
  )


  final Organization? currentOrganization;



  @JsonKey(

    name: r'member_role',
    required: false,
    includeIfNull: false,
  )


  final BreederWechatSessionResponseDataMemberRoleEnum? memberRole;



  @JsonKey(

    name: r'capabilities',
    required: false,
    includeIfNull: false,
  )


  final List<String>? capabilities;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BreederWechatSessionResponseData &&
      other.bindRequired == bindRequired &&
      other.wechatTicket == wechatTicket &&
      other.tokenType == tokenType &&
      other.accessToken == accessToken &&
      other.expiresInSeconds == expiresInSeconds &&
      other.refreshToken == refreshToken &&
      other.account == account &&
      other.currentOrganization == currentOrganization &&
      other.memberRole == memberRole &&
      other.capabilities == capabilities;

    @override
    int get hashCode =>
        bindRequired.hashCode +
        wechatTicket.hashCode +
        tokenType.hashCode +
        accessToken.hashCode +
        expiresInSeconds.hashCode +
        refreshToken.hashCode +
        account.hashCode +
        currentOrganization.hashCode +
        memberRole.hashCode +
        capabilities.hashCode;

  factory BreederWechatSessionResponseData.fromJson(Map<String, dynamic> json) => _$BreederWechatSessionResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$BreederWechatSessionResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum BreederWechatSessionResponseDataBindRequiredEnum {
@JsonValue('true')
true_('true');

const BreederWechatSessionResponseDataBindRequiredEnum(this.value);

final String value;

@override
String toString() => value;
}



enum BreederWechatSessionResponseDataTokenTypeEnum {
@JsonValue(r'Bearer')
bearer(r'Bearer');

const BreederWechatSessionResponseDataTokenTypeEnum(this.value);

final String value;

@override
String toString() => value;
}



enum BreederWechatSessionResponseDataMemberRoleEnum {
@JsonValue(r'owner')
owner(r'owner'),
@JsonValue(r'breeder')
breeder(r'breeder'),
@JsonValue(r'caretaker')
caretaker(r'caretaker'),
@JsonValue(r'staff')
staff(r'staff'),
@JsonValue(r'viewer')
viewer(r'viewer');

const BreederWechatSessionResponseDataMemberRoleEnum(this.value);

final String value;

@override
String toString() => value;
}
