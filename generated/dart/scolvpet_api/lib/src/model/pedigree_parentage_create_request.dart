//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pedigree_parentage_create_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PedigreeParentageCreateRequest {
  /// Returns a new [PedigreeParentageCreateRequest] instance.
  PedigreeParentageCreateRequest({

    required  this.childHamsterId,

    required  this.parentHamsterId,

    required  this.role,

    required  this.evidenceType,

    required  this.confidence,

    required  this.validFrom,

     this.notes,
  });

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


  final PedigreeParentageCreateRequestRoleEnum role;



  @JsonKey(
    
    name: r'evidence_type',
    required: true,
    includeIfNull: false,
  )


  final PedigreeParentageCreateRequestEvidenceTypeEnum evidenceType;



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
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PedigreeParentageCreateRequest &&
      other.childHamsterId == childHamsterId &&
      other.parentHamsterId == parentHamsterId &&
      other.role == role &&
      other.evidenceType == evidenceType &&
      other.confidence == confidence &&
      other.validFrom == validFrom &&
      other.notes == notes;

    @override
    int get hashCode =>
        childHamsterId.hashCode +
        parentHamsterId.hashCode +
        role.hashCode +
        evidenceType.hashCode +
        confidence.hashCode +
        validFrom.hashCode +
        (notes == null ? 0 : notes.hashCode);

  factory PedigreeParentageCreateRequest.fromJson(Map<String, dynamic> json) => _$PedigreeParentageCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PedigreeParentageCreateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum PedigreeParentageCreateRequestRoleEnum {
@JsonValue(r'sire')
sire(r'sire'),
@JsonValue(r'dam')
dam(r'dam');

const PedigreeParentageCreateRequestRoleEnum(this.value);

final String value;

@override
String toString() => value;
}



enum PedigreeParentageCreateRequestEvidenceTypeEnum {
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

const PedigreeParentageCreateRequestEvidenceTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


