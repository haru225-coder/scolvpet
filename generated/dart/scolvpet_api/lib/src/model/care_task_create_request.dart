//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/task_priority.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'care_task_create_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CareTaskCreateRequest {
  /// Returns a new [CareTaskCreateRequest] instance.
  CareTaskCreateRequest({

    required  this.taskType,

    required  this.targetType,

    required  this.targetId,

     this.title,

    required  this.scheduledAt,

    required  this.priority,

     this.subjectIds,

     this.notes,
  });

  @JsonKey(
    
    name: r'task_type',
    required: true,
    includeIfNull: false,
  )


  final String taskType;



  @JsonKey(
    
    name: r'target_type',
    required: true,
    includeIfNull: false,
  )


  final String targetType;



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
    
    name: r'subject_ids',
    required: false,
    includeIfNull: false,
  )


  final List<String>? subjectIds;



  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CareTaskCreateRequest &&
      other.taskType == taskType &&
      other.targetType == targetType &&
      other.targetId == targetId &&
      other.title == title &&
      other.scheduledAt == scheduledAt &&
      other.priority == priority &&
      other.subjectIds == subjectIds &&
      other.notes == notes;

    @override
    int get hashCode =>
        taskType.hashCode +
        targetType.hashCode +
        targetId.hashCode +
        (title == null ? 0 : title.hashCode) +
        scheduledAt.hashCode +
        priority.hashCode +
        subjectIds.hashCode +
        (notes == null ? 0 : notes.hashCode);

  factory CareTaskCreateRequest.fromJson(Map<String, dynamic> json) => _$CareTaskCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CareTaskCreateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

