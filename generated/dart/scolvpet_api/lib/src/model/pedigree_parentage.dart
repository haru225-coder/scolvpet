//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pedigree_parentage.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PedigreeParentage {
  /// Returns a new [PedigreeParentage] instance.
  PedigreeParentage({

    required  this.id,

    required  this.ownerId,

    required  this.childHamsterId,

    required  this.parentHamsterId,

    required  this.role,

    required  this.evidenceType,

    required  this.confidence,

    required  this.validFrom,

     this.validTo,

     this.notes,

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

    name: r'owner_id',
    required: true,
    includeIfNull: false,
  )


  final String ownerId;



  @JsonKey(

    name: r'child_hamster_id',
    required: true,
    includeIfNull: false,
  )


  final String childHamsterId;



  @JsonKey(

    name: r'parent_hamster_id',
    required: true,
    includeIfNull: false,
  )


  final String parentHamsterId;



  @JsonKey(

    name: r'role',
    required: true,
    includeIfNull: false,
  )


  final PedigreeParentageRoleEnum role;



  @JsonKey(

    name: r'evidence_type',
    required: true,
    includeIfNull: false,
  )


  final PedigreeParentageEvidenceTypeEnum evidenceType;



          // minimum: 0
          // maximum: 1
  @JsonKey(

    name: r'confidence',
    required: true,
    includeIfNull: false,
  )


  final num confidence;



  @JsonKey(

    name: r'valid_from',
    required: true,
    includeIfNull: false,
  )


  final DateTime validFrom;



  @JsonKey(

    name: r'valid_to',
    required: false,
    includeIfNull: false,
  )


  final DateTime? validTo;



  @JsonKey(

    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;



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
    bool operator ==(Object other) => identical(this, other) || other is PedigreeParentage &&
      other.id == id &&
      other.ownerId == ownerId &&
      other.childHamsterId == childHamsterId &&
      other.parentHamsterId == parentHamsterId &&
      other.role == role &&
      other.evidenceType == evidenceType &&
      other.confidence == confidence &&
      other.validFrom == validFrom &&
      other.validTo == validTo &&
      other.notes == notes &&
      other.version == version &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        ownerId.hashCode +
        childHamsterId.hashCode +
        parentHamsterId.hashCode +
        role.hashCode +
        evidenceType.hashCode +
        confidence.hashCode +
        validFrom.hashCode +
        (validTo == null ? 0 : validTo.hashCode) +
        (notes == null ? 0 : notes.hashCode) +
        version.hashCode +
        createdAt.hashCode;

  factory PedigreeParentage.fromJson(Map<String, dynamic> json) => _$PedigreeParentageFromJson(json);

  Map<String, dynamic> toJson() => _$PedigreeParentageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum PedigreeParentageRoleEnum {
@JsonValue(r'sire')
sire(r'sire'),
@JsonValue(r'dam')
dam(r'dam');

const PedigreeParentageRoleEnum(this.value);

final String value;

@override
String toString() => value;
}



enum PedigreeParentageEvidenceTypeEnum {
@JsonValue(r'litter_derived')
litterDerived(r'litter_derived'),
@JsonValue(r'breeding_plan')
breedingPlan(r'breeding_plan'),
@JsonValue(r'imported')
imported(r'imported'),
@JsonValue(r'manual')
manual(r'manual'),
@JsonValue(r'verified_document')
verifiedDocument(r'verified_document');

const PedigreeParentageEvidenceTypeEnum(this.value);

final String value;

@override
String toString() => value;
}
