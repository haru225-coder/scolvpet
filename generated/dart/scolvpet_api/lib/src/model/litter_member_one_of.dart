//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'litter_member_one_of.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LitterMemberOneOf {
  /// Returns a new [LitterMemberOneOf] instance.
  LitterMemberOneOf({

     this.memberType,

     this.hamsterId,
  });

  @JsonKey(

    name: r'member_type',
    required: false,
    includeIfNull: false,
  )


  final Object? memberType;



  @JsonKey(

    name: r'hamster_id',
    required: false,
    includeIfNull: false,
  )


  final Object? hamsterId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LitterMemberOneOf &&
      other.memberType == memberType &&
      other.hamsterId == hamsterId;

    @override
    int get hashCode =>
        (memberType == null ? 0 : memberType.hashCode) +
        hamsterId.hashCode;

  factory LitterMemberOneOf.fromJson(Map<String, dynamic> json) => _$LitterMemberOneOfFromJson(json);

  Map<String, dynamic> toJson() => _$LitterMemberOneOfToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
