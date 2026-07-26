//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pedigree_parentage_end_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PedigreeParentageEndRequest {
  /// Returns a new [PedigreeParentageEndRequest] instance.
  PedigreeParentageEndRequest({

    required  this.childHamsterId,

    required  this.role,

    required  this.correctionReason,
  });

  @JsonKey(

    name: r'child_hamster_id',
    required: true,
    includeIfNull: false,
  )


  final String childHamsterId;



  @JsonKey(

    name: r'role',
    required: true,
    includeIfNull: false,
  )


  final PedigreeParentageEndRequestRoleEnum role;



  @JsonKey(

    name: r'correction_reason',
    required: true,
    includeIfNull: false,
  )


  final String correctionReason;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PedigreeParentageEndRequest &&
      other.childHamsterId == childHamsterId &&
      other.role == role &&
      other.correctionReason == correctionReason;

    @override
    int get hashCode =>
        childHamsterId.hashCode +
        role.hashCode +
        correctionReason.hashCode;

  factory PedigreeParentageEndRequest.fromJson(Map<String, dynamic> json) => _$PedigreeParentageEndRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PedigreeParentageEndRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum PedigreeParentageEndRequestRoleEnum {
@JsonValue(r'sire')
sire(r'sire'),
@JsonValue(r'dam')
dam(r'dam');

const PedigreeParentageEndRequestRoleEnum(this.value);

final String value;

@override
String toString() => value;
}
