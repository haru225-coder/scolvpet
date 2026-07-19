//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/organization.dart';
import 'package:scolvpet_api/src/model/account.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'session_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SessionResponseData {
  /// Returns a new [SessionResponseData] instance.
  SessionResponseData({

    required  this.tokenType,

    required  this.accessToken,

    required  this.expiresInSeconds,

    required  this.refreshToken,

    required  this.account,

    required  this.currentOrganization,

    required  this.memberRole,

    required  this.capabilities,
  });

  @JsonKey(

    name: r'token_type',
    required: true,
    includeIfNull: false,
  )


  final SessionResponseDataTokenTypeEnum tokenType;



  @JsonKey(

    name: r'access_token',
    required: true,
    includeIfNull: false,
  )


  final String accessToken;



          // minimum: 60
  @JsonKey(

    name: r'expires_in_seconds',
    required: true,
    includeIfNull: false,
  )


  final int expiresInSeconds;



  @JsonKey(

    name: r'refresh_token',
    required: true,
    includeIfNull: false,
  )


  final String refreshToken;



  @JsonKey(

    name: r'account',
    required: true,
    includeIfNull: false,
  )


  final Account account;



  @JsonKey(

    name: r'current_organization',
    required: true,
    includeIfNull: false,
  )


  final Organization currentOrganization;



  @JsonKey(

    name: r'member_role',
    required: true,
    includeIfNull: false,
  )


  final SessionResponseDataMemberRoleEnum memberRole;



  @JsonKey(

    name: r'capabilities',
    required: true,
    includeIfNull: false,
  )


  final List<String> capabilities;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SessionResponseData &&
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
        tokenType.hashCode +
        accessToken.hashCode +
        expiresInSeconds.hashCode +
        refreshToken.hashCode +
        account.hashCode +
        currentOrganization.hashCode +
        memberRole.hashCode +
        capabilities.hashCode;

  factory SessionResponseData.fromJson(Map<String, dynamic> json) => _$SessionResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$SessionResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum SessionResponseDataTokenTypeEnum {
@JsonValue(r'Bearer')
bearer(r'Bearer');

const SessionResponseDataTokenTypeEnum(this.value);

final String value;

@override
String toString() => value;
}



enum SessionResponseDataMemberRoleEnum {
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

const SessionResponseDataMemberRoleEnum(this.value);

final String value;

@override
String toString() => value;
}
