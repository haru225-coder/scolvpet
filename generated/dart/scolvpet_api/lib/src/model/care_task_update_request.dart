//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/task_priority.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'care_task_update_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CareTaskUpdateRequest {
  /// Returns a new [CareTaskUpdateRequest] instance.
  CareTaskUpdateRequest({

     this.title,

     this.scheduledAt,

     this.priority,

     this.notes,
  });

  @JsonKey(

    name: r'title',
    required: false,
    includeIfNull: false,
  )


  final String? title;



  @JsonKey(

    name: r'scheduled_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? scheduledAt;



  @JsonKey(

    name: r'priority',
    required: false,
    includeIfNull: false,
  )


  final TaskPriority? priority;



  @JsonKey(

    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CareTaskUpdateRequest &&
      other.title == title &&
      other.scheduledAt == scheduledAt &&
      other.priority == priority &&
      other.notes == notes;

    @override
    int get hashCode =>
        (title == null ? 0 : title.hashCode) +
        scheduledAt.hashCode +
        priority.hashCode +
        (notes == null ? 0 : notes.hashCode);

  factory CareTaskUpdateRequest.fromJson(Map<String, dynamic> json) => _$CareTaskUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CareTaskUpdateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
