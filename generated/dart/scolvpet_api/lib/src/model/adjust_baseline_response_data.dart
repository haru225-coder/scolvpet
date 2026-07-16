//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/reminder.dart';
import 'package:scolvpet_api/src/model/breeding_plan.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'adjust_baseline_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdjustBaselineResponseData {
  /// Returns a new [AdjustBaselineResponseData] instance.
  AdjustBaselineResponseData({

    required  this.breedingPlan,

    required  this.supersededReminderIds,

    required  this.createdReminders,
  });

  @JsonKey(
    
    name: r'breeding_plan',
    required: true,
    includeIfNull: false,
  )


  final BreedingPlan breedingPlan;



  @JsonKey(
    
    name: r'superseded_reminder_ids',
    required: true,
    includeIfNull: false,
  )


  final List<String> supersededReminderIds;



  @JsonKey(
    
    name: r'created_reminders',
    required: true,
    includeIfNull: false,
  )


  final List<Reminder> createdReminders;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AdjustBaselineResponseData &&
      other.breedingPlan == breedingPlan &&
      other.supersededReminderIds == supersededReminderIds &&
      other.createdReminders == createdReminders;

    @override
    int get hashCode =>
        breedingPlan.hashCode +
        supersededReminderIds.hashCode +
        createdReminders.hashCode;

  factory AdjustBaselineResponseData.fromJson(Map<String, dynamic> json) => _$AdjustBaselineResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$AdjustBaselineResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

