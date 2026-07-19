//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/hamster_batch_create_response_data_items_inner.dart';
import 'package:scolvpet_api/src/model/batch_transaction_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hamster_batch_create_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HamsterBatchCreateResponseData {
  /// Returns a new [HamsterBatchCreateResponseData] instance.
  HamsterBatchCreateResponseData({

    required  this.transactionStatus,

    required  this.succeededCount,

    required  this.failedCount,

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



  @JsonKey(

    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<HamsterBatchCreateResponseDataItemsInner> items;





    @override
    bool operator ==(Object other) => identical(this, other) || other is HamsterBatchCreateResponseData &&
      other.transactionStatus == transactionStatus &&
      other.succeededCount == succeededCount &&
      other.failedCount == failedCount &&
      other.items == items;

    @override
    int get hashCode =>
        transactionStatus.hashCode +
        succeededCount.hashCode +
        failedCount.hashCode +
        items.hashCode;

  factory HamsterBatchCreateResponseData.fromJson(Map<String, dynamic> json) => _$HamsterBatchCreateResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$HamsterBatchCreateResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
