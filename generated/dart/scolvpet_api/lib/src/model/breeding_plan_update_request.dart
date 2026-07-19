//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'breeding_plan_update_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BreedingPlanUpdateRequest {
  /// Returns a new [BreedingPlanUpdateRequest] instance.
  BreedingPlanUpdateRequest({

     this.name,

     this.sireId,

     this.damId,

     this.ruleVersionId,

     this.plannedPairingAt,

     this.objectiveTraits,

     this.notes,
  });

  @JsonKey(

    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(

    name: r'sire_id',
    required: false,
    includeIfNull: false,
  )


  final String? sireId;



  @JsonKey(

    name: r'dam_id',
    required: false,
    includeIfNull: false,
  )


  final String? damId;



  @JsonKey(

    name: r'rule_version_id',
    required: false,
    includeIfNull: false,
  )


  final String? ruleVersionId;



  @JsonKey(

    name: r'planned_pairing_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? plannedPairingAt;



  @JsonKey(

    name: r'objective_traits',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? objectiveTraits;



  @JsonKey(

    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BreedingPlanUpdateRequest &&
      other.name == name &&
      other.sireId == sireId &&
      other.damId == damId &&
      other.ruleVersionId == ruleVersionId &&
      other.plannedPairingAt == plannedPairingAt &&
      other.objectiveTraits == objectiveTraits &&
      other.notes == notes;

    @override
    int get hashCode =>
        (name == null ? 0 : name.hashCode) +
        sireId.hashCode +
        damId.hashCode +
        ruleVersionId.hashCode +
        (plannedPairingAt == null ? 0 : plannedPairingAt.hashCode) +
        objectiveTraits.hashCode +
        (notes == null ? 0 : notes.hashCode);

  factory BreedingPlanUpdateRequest.fromJson(Map<String, dynamic> json) => _$BreedingPlanUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BreedingPlanUpdateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
