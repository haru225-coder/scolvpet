//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_organization_member_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateOrganizationMemberRequest {
  /// Returns a new [UpdateOrganizationMemberRequest] instance.
  UpdateOrganizationMemberRequest({

     this.role,

     this.displayName,
  });

  @JsonKey(
    
    name: r'role',
    required: false,
    includeIfNull: false,
  )


  final UpdateOrganizationMemberRequestRoleEnum? role;



  @JsonKey(
    
    name: r'display_name',
    required: false,
    includeIfNull: false,
  )


  final String? displayName;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdateOrganizationMemberRequest &&
      other.role == role &&
      other.displayName == displayName;

    @override
    int get hashCode =>
        (role == null ? 0 : role.hashCode) +
        (displayName == null ? 0 : displayName.hashCode);

  factory UpdateOrganizationMemberRequest.fromJson(Map<String, dynamic> json) => _$UpdateOrganizationMemberRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateOrganizationMemberRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum UpdateOrganizationMemberRequestRoleEnum {
@JsonValue(r'breeder')
breeder(r'breeder'),
@JsonValue(r'caretaker')
caretaker(r'caretaker'),
@JsonValue(r'staff')
staff(r'staff'),
@JsonValue(r'viewer')
viewer(r'viewer');

const UpdateOrganizationMemberRequestRoleEnum(this.value);

final String value;

@override
String toString() => value;
}


