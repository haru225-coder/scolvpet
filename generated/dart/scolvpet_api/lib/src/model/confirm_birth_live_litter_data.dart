//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/pup_identity.dart';
import 'package:scolvpet_api/src/model/litter_count_event.dart';
import 'package:scolvpet_api/src/model/async_job.dart';
import 'package:scolvpet_api/src/model/litter.dart';
import 'package:scolvpet_api/src/model/breeding_plan.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'confirm_birth_live_litter_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ConfirmBirthLiveLitterData {
  /// Returns a new [ConfirmBirthLiveLitterData] instance.
  ConfirmBirthLiveLitterData({

    required  this.resultType,

    required  this.breedingPlan,

    required  this.litter,

    required  this.pupIdentityCount,

    required  this.pupIdentities,

    required  this.initialCountEvent,

     this.celebrationJob,
  });

  @JsonKey(
    
    name: r'result_type',
    required: true,
    includeIfNull: false,
  )


  final ConfirmBirthLiveLitterDataResultTypeEnum resultType;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is ConfirmBirthLiveLitterData &&
      other.resultType == resultType &&
      other.breedingPlan == breedingPlan &&
      other.litter == litter &&
      other.pupIdentityCount == pupIdentityCount &&
      other.pupIdentities == pupIdentities &&
      other.initialCountEvent == initialCountEvent &&
      other.celebrationJob == celebrationJob;

    @override
    int get hashCode =>
        resultType.hashCode +
        breedingPlan.hashCode +
        litter.hashCode +
        pupIdentityCount.hashCode +
        pupIdentities.hashCode +
        initialCountEvent.hashCode +
        (celebrationJob == null ? 0 : celebrationJob.hashCode);

  factory ConfirmBirthLiveLitterData.fromJson(Map<String, dynamic> json) => _$ConfirmBirthLiveLitterDataFromJson(json);

  Map<String, dynamic> toJson() => _$ConfirmBirthLiveLitterDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum ConfirmBirthLiveLitterDataResultTypeEnum {
@JsonValue(r'live_litter')
liveLitter(r'live_litter');

const ConfirmBirthLiveLitterDataResultTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


