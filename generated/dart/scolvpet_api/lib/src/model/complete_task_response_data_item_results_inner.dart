//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/batch_item_status.dart';
import 'package:scolvpet_api/src/model/error_object.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'complete_task_response_data_item_results_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CompleteTaskResponseDataItemResultsInner {
  /// Returns a new [CompleteTaskResponseDataItemResultsInner] instance.
  CompleteTaskResponseDataItemResultsInner({

    required  this.subjectId,

    required  this.status,

     this.completionRecordId,

     this.error,
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


  final BatchItemStatus status;



  @JsonKey(
    
    name: r'completion_record_id',
    required: false,
    includeIfNull: false,
  )


  final String? completionRecordId;



  @JsonKey(
    
    name: r'error',
    required: false,
    includeIfNull: false,
  )


  final ErrorObject? error;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CompleteTaskResponseDataItemResultsInner &&
      other.subjectId == subjectId &&
      other.status == status &&
      other.completionRecordId == completionRecordId &&
      other.error == error;

    @override
    int get hashCode =>
        subjectId.hashCode +
        status.hashCode +
        (completionRecordId == null ? 0 : completionRecordId.hashCode) +
        (error == null ? 0 : error.hashCode);

  factory CompleteTaskResponseDataItemResultsInner.fromJson(Map<String, dynamic> json) => _$CompleteTaskResponseDataItemResultsInnerFromJson(json);

  Map<String, dynamic> toJson() => _$CompleteTaskResponseDataItemResultsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

