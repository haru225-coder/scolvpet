//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'complete_task_request_subject_results_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CompleteTaskRequestSubjectResultsInner {
  /// Returns a new [CompleteTaskRequestSubjectResultsInner] instance.
  CompleteTaskRequestSubjectResultsInner({

    required  this.subjectId,

    required  this.status,

     this.completionRecordId,

     this.exceptionReason,
  });

  @JsonKey(
    
    name: r'subject_id',
    required: true,
    includeIfNull: false,
  )


  final String subjectId;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final CompleteTaskRequestSubjectResultsInnerStatusEnum status;



  @JsonKey(
    
    name: r'completion_record_id',
    required: false,
    includeIfNull: false,
  )


  final String? completionRecordId;



  @JsonKey(
    
    name: r'exception_reason',
    required: false,
    includeIfNull: false,
  )


  final String? exceptionReason;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CompleteTaskRequestSubjectResultsInner &&
      other.subjectId == subjectId &&
      other.status == status &&
      other.completionRecordId == completionRecordId &&
      other.exceptionReason == exceptionReason;

    @override
    int get hashCode =>
        subjectId.hashCode +
        status.hashCode +
        (completionRecordId == null ? 0 : completionRecordId.hashCode) +
        (exceptionReason == null ? 0 : exceptionReason.hashCode);

  factory CompleteTaskRequestSubjectResultsInner.fromJson(Map<String, dynamic> json) => _$CompleteTaskRequestSubjectResultsInnerFromJson(json);

  Map<String, dynamic> toJson() => _$CompleteTaskRequestSubjectResultsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum CompleteTaskRequestSubjectResultsInnerStatusEnum {
@JsonValue(r'completed')
completed(r'completed'),
@JsonValue(r'excepted')
excepted(r'excepted');

const CompleteTaskRequestSubjectResultsInnerStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


