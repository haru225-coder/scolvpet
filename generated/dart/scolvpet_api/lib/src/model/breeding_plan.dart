//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/kinship_check.dart';
import 'package:scolvpet_api/src/model/breeding_plan_state.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'breeding_plan.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BreedingPlan {
  /// Returns a new [BreedingPlan] instance.
  BreedingPlan({

    required  this.id,

    required  this.ownerId,

     this.name,

    required  this.sireId,

    required  this.damId,

    required  this.ruleVersionId,

    required  this.state,

     this.plannedPairingAt,

     this.matingBaselineAt,

     this.expectedBirthStart,

     this.expectedBirthEnd,

     this.actualBirthAt,

     this.activePairingAttemptId,

     this.litterId,

     this.objectiveTraits,

     this.kinshipCheck,

     this.notes,

    required  this.version,

    required  this.createdAt,

    required  this.updatedAt,
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

    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(

    name: r'sire_id',
    required: true,
    includeIfNull: false,
  )


  final String sireId;



  @JsonKey(

    name: r'dam_id',
    required: true,
    includeIfNull: false,
  )


  final String damId;



  @JsonKey(

    name: r'rule_version_id',
    required: true,
    includeIfNull: false,
  )


  final String ruleVersionId;



  @JsonKey(

    name: r'state',
    required: true,
    includeIfNull: false,
  )


  final BreedingPlanState state;



  @JsonKey(

    name: r'planned_pairing_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? plannedPairingAt;



  @JsonKey(

    name: r'mating_baseline_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? matingBaselineAt;



  @JsonKey(

    name: r'expected_birth_start',
    required: false,
    includeIfNull: false,
  )


  final DateTime? expectedBirthStart;



  @JsonKey(

    name: r'expected_birth_end',
    required: false,
    includeIfNull: false,
  )


  final DateTime? expectedBirthEnd;



  @JsonKey(

    name: r'actual_birth_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? actualBirthAt;



  @JsonKey(

    name: r'active_pairing_attempt_id',
    required: false,
    includeIfNull: false,
  )


  final String? activePairingAttemptId;



  @JsonKey(

    name: r'litter_id',
    required: false,
    includeIfNull: false,
  )


  final String? litterId;



  @JsonKey(

    name: r'objective_traits',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? objectiveTraits;



  @JsonKey(

    name: r'kinship_check',
    required: false,
    includeIfNull: false,
  )


  final KinshipCheck? kinshipCheck;



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



  @JsonKey(

    name: r'updated_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime updatedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BreedingPlan &&
      other.id == id &&
      other.ownerId == ownerId &&
      other.name == name &&
      other.sireId == sireId &&
      other.damId == damId &&
      other.ruleVersionId == ruleVersionId &&
      other.state == state &&
      other.plannedPairingAt == plannedPairingAt &&
      other.matingBaselineAt == matingBaselineAt &&
      other.expectedBirthStart == expectedBirthStart &&
      other.expectedBirthEnd == expectedBirthEnd &&
      other.actualBirthAt == actualBirthAt &&
      other.activePairingAttemptId == activePairingAttemptId &&
      other.litterId == litterId &&
      other.objectiveTraits == objectiveTraits &&
      other.kinshipCheck == kinshipCheck &&
      other.notes == notes &&
      other.version == version &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        id.hashCode +
        ownerId.hashCode +
        (name == null ? 0 : name.hashCode) +
        sireId.hashCode +
        damId.hashCode +
        ruleVersionId.hashCode +
        state.hashCode +
        (plannedPairingAt == null ? 0 : plannedPairingAt.hashCode) +
        (matingBaselineAt == null ? 0 : matingBaselineAt.hashCode) +
        (expectedBirthStart == null ? 0 : expectedBirthStart.hashCode) +
        (expectedBirthEnd == null ? 0 : expectedBirthEnd.hashCode) +
        (actualBirthAt == null ? 0 : actualBirthAt.hashCode) +
        (activePairingAttemptId == null ? 0 : activePairingAttemptId.hashCode) +
        (litterId == null ? 0 : litterId.hashCode) +
        objectiveTraits.hashCode +
        (kinshipCheck == null ? 0 : kinshipCheck.hashCode) +
        (notes == null ? 0 : notes.hashCode) +
        version.hashCode +
        createdAt.hashCode +
        updatedAt.hashCode;

  factory BreedingPlan.fromJson(Map<String, dynamic> json) => _$BreedingPlanFromJson(json);

  Map<String, dynamic> toJson() => _$BreedingPlanToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
