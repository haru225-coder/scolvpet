//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'litter_parent_create_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LitterParentCreateRequest {
  /// Returns a new [LitterParentCreateRequest] instance.
  LitterParentCreateRequest({

    required  this.hamsterId,

    required  this.role,

    required  this.evidenceType,

    required  this.confidence,

     this.correctionReason,
  });

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


  final LitterParentCreateRequestRoleEnum role;



  @JsonKey(
    
    name: r'evidence_type',
    required: true,
    includeIfNull: false,
  )


  final LitterParentCreateRequestEvidenceTypeEnum evidenceType;



          // minimum: 0
          // maximum: 1
  @JsonKey(
    
    name: r'confidence',
    required: true,
    includeIfNull: false,
  )


  final num confidence;



  @JsonKey(
    
    name: r'correction_reason',
    required: false,
    includeIfNull: false,
  )


  final String? correctionReason;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LitterParentCreateRequest &&
      other.hamsterId == hamsterId &&
      other.role == role &&
      other.evidenceType == evidenceType &&
      other.confidence == confidence &&
      other.correctionReason == correctionReason;

    @override
    int get hashCode =>
        hamsterId.hashCode +
        role.hashCode +
        evidenceType.hashCode +
        confidence.hashCode +
        (correctionReason == null ? 0 : correctionReason.hashCode);

  factory LitterParentCreateRequest.fromJson(Map<String, dynamic> json) => _$LitterParentCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LitterParentCreateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum LitterParentCreateRequestRoleEnum {
@JsonValue(r'sire')
sire(r'sire'),
@JsonValue(r'dam')
dam(r'dam');

const LitterParentCreateRequestRoleEnum(this.value);

final String value;

@override
String toString() => value;
}



enum LitterParentCreateRequestEvidenceTypeEnum {
@JsonValue(r'breeding_plan')
breedingPlan(r'breeding_plan'),
@JsonValue(r'imported')
imported(r'imported'),
@JsonValue(r'manual')
manual(r'manual'),
@JsonValue(r'verified_document')
verifiedDocument(r'verified_document');

const LitterParentCreateRequestEvidenceTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


