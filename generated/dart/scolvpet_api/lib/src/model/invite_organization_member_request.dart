//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'invite_organization_member_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class InviteOrganizationMemberRequest {
  /// Returns a new [InviteOrganizationMemberRequest] instance.
  InviteOrganizationMemberRequest({

    required  this.phone,

    required  this.role,

     this.displayName,
  });

  @JsonKey(
    
    name: r'phone',
    required: true,
    includeIfNull: false,
  )


  final String phone;



  @JsonKey(
    
    name: r'role',
    required: true,
    includeIfNull: false,
  )


  final InviteOrganizationMemberRequestRoleEnum role;



  @JsonKey(
    
    name: r'display_name',
    required: false,
    includeIfNull: false,
  )


  final String? displayName;





    @override
    bool operator ==(Object other) => identical(this, other) || other is InviteOrganizationMemberRequest &&
      other.phone == phone &&
      other.role == role &&
      other.displayName == displayName;

    @override
    int get hashCode =>
        phone.hashCode +
        role.hashCode +
        (displayName == null ? 0 : displayName.hashCode);

  factory InviteOrganizationMemberRequest.fromJson(Map<String, dynamic> json) => _$InviteOrganizationMemberRequestFromJson(json);

  Map<String, dynamic> toJson() => _$InviteOrganizationMemberRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum InviteOrganizationMemberRequestRoleEnum {
@JsonValue(r'breeder')
breeder(r'breeder'),
@JsonValue(r'caretaker')
caretaker(r'caretaker'),
@JsonValue(r'staff')
staff(r'staff'),
@JsonValue(r'viewer')
viewer(r'viewer');

const InviteOrganizationMemberRequestRoleEnum(this.value);

final String value;

@override
String toString() => value;
}


