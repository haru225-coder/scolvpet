//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'species_rule_version_create_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SpeciesRuleVersionCreateRequest {
  /// Returns a new [SpeciesRuleVersionCreateRequest] instance.
  SpeciesRuleVersionCreateRequest({

     this.sourceTemplateId,

    required  this.speciesCode,

     this.varietyScope,

    required  this.gestationMinDays,

    required  this.gestationMaxDays,

     this.pairingMaxMinutes,

    required  this.weaningTargetDays,

    required  this.sexingTargetDays,

    required  this.separationTargetDays,

     this.postBreedingRestDays,

     this.profileCreationDeadlineDays,

     this.weightReference,

    required  this.sourceNote,

    required  this.effectiveAt,
  });

  @JsonKey(
    
    name: r'source_template_id',
    required: false,
    includeIfNull: false,
  )


  final String? sourceTemplateId;



  @JsonKey(
    
    name: r'species_code',
    required: true,
    includeIfNull: false,
  )


  final String speciesCode;



  @JsonKey(
    
    name: r'variety_scope',
    required: false,
    includeIfNull: false,
  )


  final List<String>? varietyScope;



          // minimum: 1
  @JsonKey(
    
    name: r'gestation_min_days',
    required: true,
    includeIfNull: false,
  )


  final int gestationMinDays;



          // minimum: 1
  @JsonKey(
    
    name: r'gestation_max_days',
    required: true,
    includeIfNull: false,
  )


  final int gestationMaxDays;



          // minimum: 1
  @JsonKey(
    
    name: r'pairing_max_minutes',
    required: false,
    includeIfNull: false,
  )


  final int? pairingMaxMinutes;



          // minimum: 1
  @JsonKey(
    
    name: r'weaning_target_days',
    required: true,
    includeIfNull: false,
  )


  final int weaningTargetDays;



          // minimum: 1
  @JsonKey(
    
    name: r'sexing_target_days',
    required: true,
    includeIfNull: false,
  )


  final int sexingTargetDays;



          // minimum: 1
  @JsonKey(
    
    name: r'separation_target_days',
    required: true,
    includeIfNull: false,
  )


  final int separationTargetDays;



          // minimum: 0
  @JsonKey(
    
    name: r'post_breeding_rest_days',
    required: false,
    includeIfNull: false,
  )


  final int? postBreedingRestDays;



          // minimum: 0
  @JsonKey(
    
    name: r'profile_creation_deadline_days',
    required: false,
    includeIfNull: false,
  )


  final int? profileCreationDeadlineDays;



  @JsonKey(
    
    name: r'weight_reference',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? weightReference;



  @JsonKey(
    
    name: r'source_note',
    required: true,
    includeIfNull: false,
  )


  final String sourceNote;



  @JsonKey(
    
    name: r'effective_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime effectiveAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SpeciesRuleVersionCreateRequest &&
      other.sourceTemplateId == sourceTemplateId &&
      other.speciesCode == speciesCode &&
      other.varietyScope == varietyScope &&
      other.gestationMinDays == gestationMinDays &&
      other.gestationMaxDays == gestationMaxDays &&
      other.pairingMaxMinutes == pairingMaxMinutes &&
      other.weaningTargetDays == weaningTargetDays &&
      other.sexingTargetDays == sexingTargetDays &&
      other.separationTargetDays == separationTargetDays &&
      other.postBreedingRestDays == postBreedingRestDays &&
      other.profileCreationDeadlineDays == profileCreationDeadlineDays &&
      other.weightReference == weightReference &&
      other.sourceNote == sourceNote &&
      other.effectiveAt == effectiveAt;

    @override
    int get hashCode =>
        (sourceTemplateId == null ? 0 : sourceTemplateId.hashCode) +
        speciesCode.hashCode +
        varietyScope.hashCode +
        gestationMinDays.hashCode +
        gestationMaxDays.hashCode +
        (pairingMaxMinutes == null ? 0 : pairingMaxMinutes.hashCode) +
        weaningTargetDays.hashCode +
        sexingTargetDays.hashCode +
        separationTargetDays.hashCode +
        postBreedingRestDays.hashCode +
        profileCreationDeadlineDays.hashCode +
        weightReference.hashCode +
        sourceNote.hashCode +
        effectiveAt.hashCode;

  factory SpeciesRuleVersionCreateRequest.fromJson(Map<String, dynamic> json) => _$SpeciesRuleVersionCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SpeciesRuleVersionCreateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

