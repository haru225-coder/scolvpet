//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/weight_record_batch_create_request_items_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weight_record_batch_create_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WeightRecordBatchCreateRequest {
  /// Returns a new [WeightRecordBatchCreateRequest] instance.
  WeightRecordBatchCreateRequest({

    required  this.taskId,

    required  this.items,
  });

  @JsonKey(

    name: r'task_id',
    required: true,
    includeIfNull: true,
  )


  final String? taskId;



  @JsonKey(

    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<WeightRecordBatchCreateRequestItemsInner> items;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WeightRecordBatchCreateRequest &&
      other.taskId == taskId &&
      other.items == items;

    @override
    int get hashCode =>
        (taskId == null ? 0 : taskId.hashCode) +
        items.hashCode;

  factory WeightRecordBatchCreateRequest.fromJson(Map<String, dynamic> json) => _$WeightRecordBatchCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WeightRecordBatchCreateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
