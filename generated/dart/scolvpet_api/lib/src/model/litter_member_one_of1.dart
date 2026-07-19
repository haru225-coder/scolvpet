//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'litter_member_one_of1.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LitterMemberOneOf1 {
  /// Returns a new [LitterMemberOneOf1] instance.
  LitterMemberOneOf1({

     this.memberType,

     this.pupIdentityId,
  });

  @JsonKey(

    name: r'member_type',
    required: false,
    includeIfNull: false,
  )


  final Object? memberType;



  @JsonKey(

    name: r'pup_identity_id',
    required: false,
    includeIfNull: false,
  )


  final Object? pupIdentityId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LitterMemberOneOf1 &&
      other.memberType == memberType &&
      other.pupIdentityId == pupIdentityId;

    @override
    int get hashCode =>
        (memberType == null ? 0 : memberType.hashCode) +
        pupIdentityId.hashCode;

  factory LitterMemberOneOf1.fromJson(Map<String, dynamic> json) => _$LitterMemberOneOf1FromJson(json);

  Map<String, dynamic> toJson() => _$LitterMemberOneOf1ToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
