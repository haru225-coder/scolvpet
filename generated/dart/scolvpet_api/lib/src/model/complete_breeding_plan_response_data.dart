//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/reconciliation.dart';
import 'package:scolvpet_api/src/model/breeding_plan.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'complete_breeding_plan_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CompleteBreedingPlanResponseData {
  /// Returns a new [CompleteBreedingPlanResponseData] instance.
  CompleteBreedingPlanResponseData({

    required  this.breedingPlan,

    required  this.reconciliation,

    required  this.completedAt,
  });

  @JsonKey(
    
    name: r'breeding_plan',
    required: true,
    includeIfNull: false,
  )


  final BreedingPlan breedingPlan;



  @JsonKey(
    
    name: r'reconciliation',
    required: true,
    includeIfNull: false,
  )


  final Reconciliation reconciliation;



  @JsonKey(
    
    name: r'completed_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime completedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CompleteBreedingPlanResponseData &&
      other.breedingPlan == breedingPlan &&
      other.reconciliation == reconciliation &&
      other.completedAt == completedAt;

    @override
    int get hashCode =>
        breedingPlan.hashCode +
        reconciliation.hashCode +
        completedAt.hashCode;

  factory CompleteBreedingPlanResponseData.fromJson(Map<String, dynamic> json) => _$CompleteBreedingPlanResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$CompleteBreedingPlanResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

