//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/care_task.dart';
import 'package:scolvpet_api/src/model/breeding_plan.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'publish_breeding_plan_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PublishBreedingPlanResponseData {
  /// Returns a new [PublishBreedingPlanResponseData] instance.
  PublishBreedingPlanResponseData({

    required  this.breedingPlan,

    required  this.createdTasks,
  });

  @JsonKey(
    
    name: r'breeding_plan',
    required: true,
    includeIfNull: false,
  )


  final BreedingPlan breedingPlan;



  @JsonKey(
    
    name: r'created_tasks',
    required: true,
    includeIfNull: false,
  )


  final List<CareTask> createdTasks;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PublishBreedingPlanResponseData &&
      other.breedingPlan == breedingPlan &&
      other.createdTasks == createdTasks;

    @override
    int get hashCode =>
        breedingPlan.hashCode +
        createdTasks.hashCode;

  factory PublishBreedingPlanResponseData.fromJson(Map<String, dynamic> json) => _$PublishBreedingPlanResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$PublishBreedingPlanResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

