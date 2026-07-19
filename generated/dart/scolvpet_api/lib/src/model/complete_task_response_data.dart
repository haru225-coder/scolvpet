//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/care_task.dart';
import 'package:scolvpet_api/src/model/complete_task_response_data_item_results_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'complete_task_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CompleteTaskResponseData {
  /// Returns a new [CompleteTaskResponseData] instance.
  CompleteTaskResponseData({

    required  this.task,

    required  this.itemResults,

    required  this.autoClosed,
  });

  @JsonKey(

    name: r'task',
    required: true,
    includeIfNull: false,
  )


  final CareTask task;



  @JsonKey(

    name: r'item_results',
    required: true,
    includeIfNull: false,
  )


  final List<CompleteTaskResponseDataItemResultsInner> itemResults;



  @JsonKey(

    name: r'auto_closed',
    required: true,
    includeIfNull: false,
  )


  final bool autoClosed;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CompleteTaskResponseData &&
      other.task == task &&
      other.itemResults == itemResults &&
      other.autoClosed == autoClosed;

    @override
    int get hashCode =>
        task.hashCode +
        itemResults.hashCode +
        autoClosed.hashCode;

  factory CompleteTaskResponseData.fromJson(Map<String, dynamic> json) => _$CompleteTaskResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$CompleteTaskResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
