//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/batch_item_status.dart';
import 'package:scolvpet_api/src/model/weight_record.dart';
import 'package:scolvpet_api/src/model/error_object.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weight_record_batch_create_response_data_items_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WeightRecordBatchCreateResponseDataItemsInner {
  /// Returns a new [WeightRecordBatchCreateResponseDataItemsInner] instance.
  WeightRecordBatchCreateResponseDataItemsInner({

    required  this.clientItemId,

    required  this.status,

     this.resource,

     this.generatedTaskId,

     this.error,
  });

  @JsonKey(

    name: r'client_item_id',
    required: true,
    includeIfNull: false,
  )


  final String clientItemId;



  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final BatchItemStatus status;



  @JsonKey(

    name: r'resource',
    required: false,
    includeIfNull: false,
  )


  final WeightRecord? resource;



  @JsonKey(

    name: r'generated_task_id',
    required: false,
    includeIfNull: false,
  )


  final String? generatedTaskId;



  @JsonKey(

    name: r'error',
    required: false,
    includeIfNull: false,
  )


  final ErrorObject? error;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WeightRecordBatchCreateResponseDataItemsInner &&
      other.clientItemId == clientItemId &&
      other.status == status &&
      other.resource == resource &&
      other.generatedTaskId == generatedTaskId &&
      other.error == error;

    @override
    int get hashCode =>
        clientItemId.hashCode +
        status.hashCode +
        (resource == null ? 0 : resource.hashCode) +
        (generatedTaskId == null ? 0 : generatedTaskId.hashCode) +
        (error == null ? 0 : error.hashCode);

  factory WeightRecordBatchCreateResponseDataItemsInner.fromJson(Map<String, dynamic> json) => _$WeightRecordBatchCreateResponseDataItemsInnerFromJson(json);

  Map<String, dynamic> toJson() => _$WeightRecordBatchCreateResponseDataItemsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
