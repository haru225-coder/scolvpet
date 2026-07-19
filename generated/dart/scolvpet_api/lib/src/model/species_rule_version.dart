//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'species_rule_version.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SpeciesRuleVersion {
  /// Returns a new [SpeciesRuleVersion] instance.
  SpeciesRuleVersion({

    required  this.id,

     this.ownerId,

    required  this.scope,

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

    required  this.version,

    required  this.effectiveAt,

    required  this.frozen,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



      /// 系统模板为 null，舍主副本由认证上下文填充
  @JsonKey(

    name: r'owner_id',
    required: false,
    includeIfNull: false,
  )


  final String? ownerId;



  @JsonKey(

    name: r'scope',
    required: true,
    includeIfNull: false,
  )


  final SpeciesRuleVersionScopeEnum scope;



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



          // minimum: 1
  @JsonKey(

    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;



  @JsonKey(

    name: r'effective_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime effectiveAt;



  @JsonKey(

    name: r'frozen',
    required: true,
    includeIfNull: false,
  )


  final bool frozen;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SpeciesRuleVersion &&
      other.id == id &&
      other.ownerId == ownerId &&
      other.scope == scope &&
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
      other.version == version &&
      other.effectiveAt == effectiveAt &&
      other.frozen == frozen;

    @override
    int get hashCode =>
        id.hashCode +
        (ownerId == null ? 0 : ownerId.hashCode) +
        scope.hashCode +
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
        version.hashCode +
        effectiveAt.hashCode +
        frozen.hashCode;

  factory SpeciesRuleVersion.fromJson(Map<String, dynamic> json) => _$SpeciesRuleVersionFromJson(json);

  Map<String, dynamic> toJson() => _$SpeciesRuleVersionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum SpeciesRuleVersionScopeEnum {
@JsonValue(r'system')
system(r'system'),
@JsonValue(r'owner')
owner(r'owner');

const SpeciesRuleVersionScopeEnum(this.value);

final String value;

@override
String toString() => value;
}
