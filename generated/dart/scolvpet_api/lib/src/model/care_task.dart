//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/task_state.dart';
import 'package:scolvpet_api/src/model/task_priority.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'care_task.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CareTask {
  /// Returns a new [CareTask] instance.
  CareTask({

    required  this.id,

    required  this.taskType,

    required  this.targetType,

    required  this.targetId,

     this.title,

    required  this.scheduledAt,

    required  this.priority,

    required  this.state,

     this.subjectIds,

     this.completedSubjectIds,

    required  this.stageTotal,

    required  this.stageDone,

     this.sourceEventId,

     this.notes,

    required  this.version,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(

    name: r'task_type',
    required: true,
    includeIfNull: false,
  )


  final CareTaskTaskTypeEnum taskType;



  @JsonKey(

    name: r'target_type',
    required: true,
    includeIfNull: false,
  )


  final CareTaskTargetTypeEnum targetType;



  @JsonKey(

    name: r'target_id',
    required: true,
    includeIfNull: false,
  )


  final String targetId;



  @JsonKey(

    name: r'title',
    required: false,
    includeIfNull: false,
  )


  final String? title;



  @JsonKey(

    name: r'scheduled_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime scheduledAt;



  @JsonKey(

    name: r'priority',
    required: true,
    includeIfNull: false,
  )


  final TaskPriority priority;



  @JsonKey(

    name: r'state',
    required: true,
    includeIfNull: false,
  )


  final TaskState state;



  @JsonKey(

    name: r'subject_ids',
    required: false,
    includeIfNull: false,
  )


  final List<String>? subjectIds;



  @JsonKey(

    name: r'completed_subject_ids',
    required: false,
    includeIfNull: false,
  )


  final List<String>? completedSubjectIds;



          // minimum: 0
  @JsonKey(

    name: r'stage_total',
    required: true,
    includeIfNull: false,
  )


  final int stageTotal;



          // minimum: 0
  @JsonKey(

    name: r'stage_done',
    required: true,
    includeIfNull: false,
  )


  final int stageDone;



  @JsonKey(

    name: r'source_event_id',
    required: false,
    includeIfNull: false,
  )


  final String? sourceEventId;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is CareTask &&
      other.id == id &&
      other.taskType == taskType &&
      other.targetType == targetType &&
      other.targetId == targetId &&
      other.title == title &&
      other.scheduledAt == scheduledAt &&
      other.priority == priority &&
      other.state == state &&
      other.subjectIds == subjectIds &&
      other.completedSubjectIds == completedSubjectIds &&
      other.stageTotal == stageTotal &&
      other.stageDone == stageDone &&
      other.sourceEventId == sourceEventId &&
      other.notes == notes &&
      other.version == version;

    @override
    int get hashCode =>
        id.hashCode +
        taskType.hashCode +
        targetType.hashCode +
        targetId.hashCode +
        (title == null ? 0 : title.hashCode) +
        scheduledAt.hashCode +
        priority.hashCode +
        state.hashCode +
        subjectIds.hashCode +
        completedSubjectIds.hashCode +
        stageTotal.hashCode +
        stageDone.hashCode +
        (sourceEventId == null ? 0 : sourceEventId.hashCode) +
        (notes == null ? 0 : notes.hashCode) +
        version.hashCode;

  factory CareTask.fromJson(Map<String, dynamic> json) => _$CareTaskFromJson(json);

  Map<String, dynamic> toJson() => _$CareTaskToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum CareTaskTaskTypeEnum {
@JsonValue(r'pair_prep')
pairPrep(r'pair_prep'),
@JsonValue(r'pairing_timeout')
pairingTimeout(r'pairing_timeout'),
@JsonValue(r'separate_now')
separateNow(r'separate_now'),
@JsonValue(r'gestation_window')
gestationWindow(r'gestation_window'),
@JsonValue(r'no_birth_review')
noBirthReview(r'no_birth_review'),
@JsonValue(r'litter_observation')
litterObservation(r'litter_observation'),
@JsonValue(r'pup_weight_check')
pupWeightCheck(r'pup_weight_check'),
@JsonValue(r'pup_weight_drop')
pupWeightDrop(r'pup_weight_drop'),
@JsonValue(r'weaning')
weaning(r'weaning'),
@JsonValue(r'sex_separation')
sexSeparation(r'sex_separation'),
@JsonValue(r'sex_recheck')
sexRecheck(r'sex_recheck'),
@JsonValue(r'profile_creation')
profileCreation(r'profile_creation'),
@JsonValue(r'enclosure_cleaning')
enclosureCleaning(r'enclosure_cleaning'),
@JsonValue(r'medication')
medication(r'medication'),
@JsonValue(r'custom')
custom(r'custom');

const CareTaskTaskTypeEnum(this.value);

final String value;

@override
String toString() => value;
}



enum CareTaskTargetTypeEnum {
@JsonValue(r'hamster')
hamster(r'hamster'),
@JsonValue(r'pup_identity')
pupIdentity(r'pup_identity'),
@JsonValue(r'litter')
litter(r'litter'),
@JsonValue(r'enclosure')
enclosure(r'enclosure'),
@JsonValue(r'breeding_plan')
breedingPlan(r'breeding_plan'),
@JsonValue(r'media')
media(r'media'),
@JsonValue(r'custom')
custom(r'custom');

const CareTaskTargetTypeEnum(this.value);

final String value;

@override
String toString() => value;
}
