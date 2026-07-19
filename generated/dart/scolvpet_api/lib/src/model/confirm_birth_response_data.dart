//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/pup_identity.dart';
import 'package:scolvpet_api/src/model/litter_count_event.dart';
import 'package:scolvpet_api/src/model/async_job.dart';
import 'package:scolvpet_api/src/model/dam_condition.dart';
import 'package:scolvpet_api/src/model/litter.dart';
import 'package:scolvpet_api/src/model/breeding_plan.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'confirm_birth_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ConfirmBirthResponseData {
  /// Returns a new [ConfirmBirthResponseData] instance.
  ConfirmBirthResponseData({

    required  this.resultType,

    required  this.breedingPlan,

    required  this.litter,

    required  this.pupIdentityCount,

    required  this.pupIdentities,

    required  this.initialCountEvent,

     this.celebrationJob,

    required  this.birthEventId,

    required  this.eventType,

    required  this.bornAt,

    required  this.initialOtherCount,

    required  this.outcomeReason,

    required  this.damCondition,
  });

  @JsonKey(

    name: r'result_type',
    required: true,
    includeIfNull: false,
  )


  final ConfirmBirthResponseDataResultTypeEnum resultType;



  @JsonKey(

    name: r'breeding_plan',
    required: true,
    includeIfNull: false,
  )


  final BreedingPlan breedingPlan;



  @JsonKey(

    name: r'litter',
    required: true,
    includeIfNull: false,
  )


  final Litter litter;



          // minimum: 1
  @JsonKey(

    name: r'pup_identity_count',
    required: true,
    includeIfNull: false,
  )


  final int pupIdentityCount;



      /// 数量严格等于 pup_identity_count 和请求 initial_alive_count
  @JsonKey(

    name: r'pup_identities',
    required: true,
    includeIfNull: false,
  )


  final List<PupIdentity> pupIdentities;



  @JsonKey(

    name: r'initial_count_event',
    required: true,
    includeIfNull: false,
  )


  final LitterCountEvent initialCountEvent;



  @JsonKey(

    name: r'celebration_job',
    required: false,
    includeIfNull: false,
  )


  final AsyncJob? celebrationJob;



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


  final ConfirmBirthResponseDataEventTypeEnum eventType;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is ConfirmBirthResponseData &&
      other.resultType == resultType &&
      other.breedingPlan == breedingPlan &&
      other.litter == litter &&
      other.pupIdentityCount == pupIdentityCount &&
      other.pupIdentities == pupIdentities &&
      other.initialCountEvent == initialCountEvent &&
      other.celebrationJob == celebrationJob &&
      other.birthEventId == birthEventId &&
      other.eventType == eventType &&
      other.bornAt == bornAt &&
      other.initialOtherCount == initialOtherCount &&
      other.outcomeReason == outcomeReason &&
      other.damCondition == damCondition;

    @override
    int get hashCode =>
        resultType.hashCode +
        breedingPlan.hashCode +
        litter.hashCode +
        pupIdentityCount.hashCode +
        pupIdentities.hashCode +
        initialCountEvent.hashCode +
        celebrationJob.hashCode +
        birthEventId.hashCode +
        eventType.hashCode +
        bornAt.hashCode +
        initialOtherCount.hashCode +
        outcomeReason.hashCode +
        damCondition.hashCode;

  factory ConfirmBirthResponseData.fromJson(Map<String, dynamic> json) => _$ConfirmBirthResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$ConfirmBirthResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum ConfirmBirthResponseDataResultTypeEnum {
@JsonValue(r'no_litter_outcome')
noLitterOutcome(r'no_litter_outcome');

const ConfirmBirthResponseDataResultTypeEnum(this.value);

final String value;

@override
String toString() => value;
}



enum ConfirmBirthResponseDataEventTypeEnum {
@JsonValue(r'BIRTH_CONFIRMED_NO_LIVE_PUPS')
BIRTH_CONFIRMED_NO_LIVE_PUPS(r'BIRTH_CONFIRMED_NO_LIVE_PUPS');

const ConfirmBirthResponseDataEventTypeEnum(this.value);

final String value;

@override
String toString() => value;
}
