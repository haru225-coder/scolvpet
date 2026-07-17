//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'organization_member.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OrganizationMember {
  /// Returns a new [OrganizationMember] instance.
  OrganizationMember({

    required  this.id,

    required  this.organizationId,

     this.accountId,

    required  this.phone,

     this.displayName,

    required  this.role,

    required  this.status,

    required  this.invitedAt,

     this.acceptedAt,

     this.revokedAt,

    required  this.version,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'organization_id',
    required: true,
    includeIfNull: false,
  )


  final String organizationId;



  @JsonKey(
    
    name: r'account_id',
    required: false,
    includeIfNull: false,
  )


  final String? accountId;



  @JsonKey(
    
    name: r'phone',
    required: true,
    includeIfNull: false,
  )


  final String phone;



  @JsonKey(
    
    name: r'display_name',
    required: false,
    includeIfNull: false,
  )


  final String? displayName;



  @JsonKey(
    
    name: r'role',
    required: true,
    includeIfNull: false,
  )


  final OrganizationMemberRoleEnum role;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final OrganizationMemberStatusEnum status;



  @JsonKey(
    
    name: r'invited_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime invitedAt;



  @JsonKey(
    
    name: r'accepted_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? acceptedAt;



  @JsonKey(
    
    name: r'revoked_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? revokedAt;



          // minimum: 1
  @JsonKey(
    
    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;





    @override
    bool operator ==(Object other) => identical(this, other) || other is OrganizationMember &&
      other.id == id &&
      other.organizationId == organizationId &&
      other.accountId == accountId &&
      other.phone == phone &&
      other.displayName == displayName &&
      other.role == role &&
      other.status == status &&
      other.invitedAt == invitedAt &&
      other.acceptedAt == acceptedAt &&
      other.revokedAt == revokedAt &&
      other.version == version;

    @override
    int get hashCode =>
        id.hashCode +
        organizationId.hashCode +
        (accountId == null ? 0 : accountId.hashCode) +
        phone.hashCode +
        (displayName == null ? 0 : displayName.hashCode) +
        role.hashCode +
        status.hashCode +
        invitedAt.hashCode +
        (acceptedAt == null ? 0 : acceptedAt.hashCode) +
        (revokedAt == null ? 0 : revokedAt.hashCode) +
        version.hashCode;

  factory OrganizationMember.fromJson(Map<String, dynamic> json) => _$OrganizationMemberFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationMemberToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum OrganizationMemberRoleEnum {
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

const OrganizationMemberRoleEnum(this.value);

final String value;

@override
String toString() => value;
}



enum OrganizationMemberStatusEnum {
@JsonValue(r'invited')
invited(r'invited'),
@JsonValue(r'active')
active(r'active'),
@JsonValue(r'revoked')
revoked(r'revoked');

const OrganizationMemberStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


