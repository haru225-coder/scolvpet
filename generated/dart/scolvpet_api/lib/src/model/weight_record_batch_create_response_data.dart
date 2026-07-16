//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/weight_record_batch_create_response_data_items_inner.dart';
import 'package:scolvpet_api/src/model/batch_transaction_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weight_record_batch_create_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WeightRecordBatchCreateResponseData {
  /// Returns a new [WeightRecordBatchCreateResponseData] instance.
  WeightRecordBatchCreateResponseData({

    required  this.transactionStatus,

    required  this.succeededCount,

    required  this.failedCount,

    required  this.alertCount,

    required  this.items,
  });

  @JsonKey(
    
    name: r'transaction_status',
    required: true,
    includeIfNull: false,
  )


  final BatchTransactionStatus transactionStatus;



          // minimum: 0
  @JsonKey(
    
    name: r'succeeded_count',
    required: true,
    includeIfNull: false,
  )


  final int succeededCount;



          // minimum: 0
  @JsonKey(
    
    name: r'failed_count',
    required: true,
    includeIfNull: false,
  )


  final int failedCount;



          // minimum: 0
  @JsonKey(
    
    name: r'alert_count',
    required: true,
    includeIfNull: false,
  )


  final int alertCount;



  @JsonKey(
    
    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<WeightRecordBatchCreateResponseDataItemsInner> items;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WeightRecordBatchCreateResponseData &&
      other.transactionStatus == transactionStatus &&
      other.succeededCount == succeededCount &&
      other.failedCount == failedCount &&
      other.alertCount == alertCount &&
      other.items == items;

    @override
    int get hashCode =>
        transactionStatus.hashCode +
        succeededCount.hashCode +
        failedCount.hashCode +
        alertCount.hashCode +
        items.hashCode;

  factory WeightRecordBatchCreateResponseData.fromJson(Map<String, dynamic> json) => _$WeightRecordBatchCreateResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$WeightRecordBatchCreateResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

