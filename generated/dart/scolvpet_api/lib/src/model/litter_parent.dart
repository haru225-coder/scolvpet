//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'litter_parent.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LitterParent {
  /// Returns a new [LitterParent] instance.
  LitterParent({

    required  this.id,

    required  this.litterId,

    required  this.hamsterId,

    required  this.role,

    required  this.evidenceType,

    required  this.confidence,

    required  this.version,

    required  this.createdAt,
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
    
    name: r'hamster_id',
    required: true,
    includeIfNull: false,
  )


  final String hamsterId;



  @JsonKey(
    
    name: r'role',
    required: true,
    includeIfNull: false,
  )


  final LitterParentRoleEnum role;



  @JsonKey(
    
    name: r'evidence_type',
    required: true,
    includeIfNull: false,
  )


  final LitterParentEvidenceTypeEnum evidenceType;



          // minimum: 0
          // maximum: 1
  @JsonKey(
    
    name: r'confidence',
    required: true,
    includeIfNull: false,
  )


  final num confidence;



          // minimum: 1
  @JsonKey(
    
    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;



  @JsonKey(
    
    name: r'created_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LitterParent &&
      other.id == id &&
      other.litterId == litterId &&
      other.hamsterId == hamsterId &&
      other.role == role &&
      other.evidenceType == evidenceType &&
      other.confidence == confidence &&
      other.version == version &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        litterId.hashCode +
        hamsterId.hashCode +
        role.hashCode +
        evidenceType.hashCode +
        confidence.hashCode +
        version.hashCode +
        createdAt.hashCode;

  factory LitterParent.fromJson(Map<String, dynamic> json) => _$LitterParentFromJson(json);

  Map<String, dynamic> toJson() => _$LitterParentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum LitterParentRoleEnum {
@JsonValue(r'sire')
sire(r'sire'),
@JsonValue(r'dam')
dam(r'dam');

const LitterParentRoleEnum(this.value);

final String value;

@override
String toString() => value;
}



enum LitterParentEvidenceTypeEnum {
@JsonValue(r'breeding_plan')
breedingPlan(r'breeding_plan'),
@JsonValue(r'imported')
imported(r'imported'),
@JsonValue(r'manual')
manual(r'manual'),
@JsonValue(r'verified_document')
verifiedDocument(r'verified_document');

const LitterParentEvidenceTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


