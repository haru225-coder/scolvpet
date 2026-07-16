//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/complete_task_request_subject_results_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'complete_task_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CompleteTaskRequest {
  /// Returns a new [CompleteTaskRequest] instance.
  CompleteTaskRequest({

    required  this.completedAt,

    required  this.subjectResults,

     this.notes,
  });

  @JsonKey(
    
    name: r'completed_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime completedAt;



  @JsonKey(
    
    name: r'subject_results',
    required: true,
    includeIfNull: false,
  )


  final List<CompleteTaskRequestSubjectResultsInner> subjectResults;



  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CompleteTaskRequest &&
      other.completedAt == completedAt &&
      other.subjectResults == subjectResults &&
      other.notes == notes;

    @override
    int get hashCode =>
        completedAt.hashCode +
        subjectResults.hashCode +
        (notes == null ? 0 : notes.hashCode);

  factory CompleteTaskRequest.fromJson(Map<String, dynamic> json) => _$CompleteTaskRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CompleteTaskRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

