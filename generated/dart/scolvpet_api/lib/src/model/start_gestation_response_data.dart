//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/reminder.dart';
import 'package:scolvpet_api/src/model/breeding_plan.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'start_gestation_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StartGestationResponseData {
  /// Returns a new [StartGestationResponseData] instance.
  StartGestationResponseData({

    required  this.breedingPlan,

    required  this.createdReminders,
  });

  @JsonKey(

    name: r'breeding_plan',
    required: true,
    includeIfNull: false,
  )


  final BreedingPlan breedingPlan;



  @JsonKey(

    name: r'created_reminders',
    required: true,
    includeIfNull: false,
  )


  final List<Reminder> createdReminders;





    @override
    bool operator ==(Object other) => identical(this, other) || other is StartGestationResponseData &&
      other.breedingPlan == breedingPlan &&
      other.createdReminders == createdReminders;

    @override
    int get hashCode =>
        breedingPlan.hashCode +
        createdReminders.hashCode;

  factory StartGestationResponseData.fromJson(Map<String, dynamic> json) => _$StartGestationResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$StartGestationResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
