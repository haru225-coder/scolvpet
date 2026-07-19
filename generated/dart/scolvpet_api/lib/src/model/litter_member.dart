//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'litter_member.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LitterMember {
  /// Returns a new [LitterMember] instance.
  LitterMember({

    required  this.id,

    required  this.litterId,

    required  this.memberType,

     this.pupIdentityId,

     this.hamsterId,

    required  this.role,

    required  this.joinedAt,

     this.leftAt,

    required  this.version,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(

    name: r'litter_id',
    required: true,
    includeIfNull: false,
  )


  final String litterId;



  @JsonKey(

    name: r'member_type',
    required: true,
    includeIfNull: false,
  )


  final LitterMemberMemberTypeEnum memberType;



  @JsonKey(

    name: r'pup_identity_id',
    required: false,
    includeIfNull: false,
  )


  final String? pupIdentityId;



  @JsonKey(

    name: r'hamster_id',
    required: false,
    includeIfNull: false,
  )


  final String? hamsterId;



  @JsonKey(

    name: r'role',
    required: true,
    includeIfNull: false,
  )


  final LitterMemberRoleEnum role;



  @JsonKey(

    name: r'joined_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime joinedAt;



  @JsonKey(

    name: r'left_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? leftAt;



          // minimum: 1
  @JsonKey(

    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LitterMember &&
      other.id == id &&
      other.litterId == litterId &&
      other.memberType == memberType &&
      other.pupIdentityId == pupIdentityId &&
      other.hamsterId == hamsterId &&
      other.role == role &&
      other.joinedAt == joinedAt &&
      other.leftAt == leftAt &&
      other.version == version;

    @override
    int get hashCode =>
        id.hashCode +
        litterId.hashCode +
        memberType.hashCode +
        (pupIdentityId == null ? 0 : pupIdentityId.hashCode) +
        (hamsterId == null ? 0 : hamsterId.hashCode) +
        role.hashCode +
        joinedAt.hashCode +
        (leftAt == null ? 0 : leftAt.hashCode) +
        version.hashCode;

  factory LitterMember.fromJson(Map<String, dynamic> json) => _$LitterMemberFromJson(json);

  Map<String, dynamic> toJson() => _$LitterMemberToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum LitterMemberMemberTypeEnum {
@JsonValue(r'pup_identity')
pupIdentity(r'pup_identity'),
@JsonValue(r'hamster')
hamster(r'hamster');

const LitterMemberMemberTypeEnum(this.value);

final String value;

@override
String toString() => value;
}



enum LitterMemberRoleEnum {
@JsonValue(r'offspring')
offspring(r'offspring');

const LitterMemberRoleEnum(this.value);

final String value;

@override
String toString() => value;
}
