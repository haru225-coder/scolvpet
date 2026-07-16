//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/weight_record_create_request.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weight_record_batch_create_request_items_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WeightRecordBatchCreateRequestItemsInner {
  /// Returns a new [WeightRecordBatchCreateRequestItemsInner] instance.
  WeightRecordBatchCreateRequestItemsInner({

    required  this.clientItemId,

    required  this.record,
  });

  @JsonKey(
    
    name: r'client_item_id',
    required: true,
    includeIfNull: false,
  )


  final String clientItemId;



  @JsonKey(
    
    name: r'record',
    required: true,
    includeIfNull: false,
  )


  final WeightRecordCreateRequest record;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WeightRecordBatchCreateRequestItemsInner &&
      other.clientItemId == clientItemId &&
      other.record == record;

    @override
    int get hashCode =>
        clientItemId.hashCode +
        record.hashCode;

  factory WeightRecordBatchCreateRequestItemsInner.fromJson(Map<String, dynamic> json) => _$WeightRecordBatchCreateRequestItemsInnerFromJson(json);

  Map<String, dynamic> toJson() => _$WeightRecordBatchCreateRequestItemsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

