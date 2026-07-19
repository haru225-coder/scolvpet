//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/async_job.dart';
import 'package:scolvpet_api/src/model/dam_condition.dart';
import 'package:scolvpet_api/src/model/breeding_plan.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'confirm_birth_no_litter_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ConfirmBirthNoLitterData {
  /// Returns a new [ConfirmBirthNoLitterData] instance.
  ConfirmBirthNoLitterData({

    required  this.resultType,

    required  this.breedingPlan,

    required  this.birthEventId,

    required  this.eventType,

    required  this.bornAt,

    required  this.initialOtherCount,

    required  this.outcomeReason,

    required  this.damCondition,

     this.celebrationJob,
  });

  @JsonKey(

    name: r'result_type',
    required: true,
    includeIfNull: false,
  )


  final ConfirmBirthNoLitterDataResultTypeEnum resultType;



  @JsonKey(

    name: r'breeding_plan',
    required: true,
    includeIfNull: false,
  )


  final BreedingPlan breedingPlan;



  @JsonKey(

    name: r'birth_event_id',
    required: true,
    includeIfNull: false,
  )


  final String birthEventId;



  @JsonKey(

    name: r'event_type',
    required: true,
    includeIfNull: false,
  )


  final ConfirmBirthNoLitterDataEventTypeEnum eventType;



  @JsonKey(

    name: r'born_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime bornAt;



          // minimum: 0
  @JsonKey(

    name: r'initial_other_count',
    required: true,
    includeIfNull: false,
  )


  final int initialOtherCount;



  @JsonKey(

    name: r'outcome_reason',
    required: true,
    includeIfNull: false,
  )


  final String outcomeReason;



  @JsonKey(

    name: r'dam_condition',
    required: true,
    includeIfNull: false,
  )


  final DamCondition damCondition;



  @JsonKey(

    name: r'celebration_job',
    required: false,
    includeIfNull: false,
  )


  final AsyncJob? celebrationJob;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ConfirmBirthNoLitterData &&
      other.resultType == resultType &&
      other.breedingPlan == breedingPlan &&
      other.birthEventId == birthEventId &&
      other.eventType == eventType &&
      other.bornAt == bornAt &&
      other.initialOtherCount == initialOtherCount &&
      other.outcomeReason == outcomeReason &&
      other.damCondition == damCondition &&
      other.celebrationJob == celebrationJob;

    @override
    int get hashCode =>
        resultType.hashCode +
        breedingPlan.hashCode +
        birthEventId.hashCode +
        eventType.hashCode +
        bornAt.hashCode +
        initialOtherCount.hashCode +
        outcomeReason.hashCode +
        damCondition.hashCode +
        (celebrationJob == null ? 0 : celebrationJob.hashCode);

  factory ConfirmBirthNoLitterData.fromJson(Map<String, dynamic> json) => _$ConfirmBirthNoLitterDataFromJson(json);

  Map<String, dynamic> toJson() => _$ConfirmBirthNoLitterDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum ConfirmBirthNoLitterDataResultTypeEnum {
@JsonValue(r'no_litter_outcome')
noLitterOutcome(r'no_litter_outcome');

const ConfirmBirthNoLitterDataResultTypeEnum(this.value);

final String value;

@override
String toString() => value;
}



enum ConfirmBirthNoLitterDataEventTypeEnum {
@JsonValue(r'BIRTH_CONFIRMED_NO_LIVE_PUPS')
BIRTH_CONFIRMED_NO_LIVE_PUPS(r'BIRTH_CONFIRMED_NO_LIVE_PUPS');

const ConfirmBirthNoLitterDataEventTypeEnum(this.value);

final String value;

@override
String toString() => value;
}
