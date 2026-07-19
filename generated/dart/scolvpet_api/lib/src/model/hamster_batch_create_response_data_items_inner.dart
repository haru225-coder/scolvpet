//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/batch_item_status.dart';
import 'package:scolvpet_api/src/model/hamster.dart';
import 'package:scolvpet_api/src/model/error_object.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hamster_batch_create_response_data_items_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HamsterBatchCreateResponseDataItemsInner {
  /// Returns a new [HamsterBatchCreateResponseDataItemsInner] instance.
  HamsterBatchCreateResponseDataItemsInner({

    required  this.clientItemId,

    required  this.status,

     this.resource,

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


  final Hamster? resource;



  @JsonKey(

    name: r'error',
    required: false,
    includeIfNull: false,
  )


  final ErrorObject? error;





    @override
    bool operator ==(Object other) => identical(this, other) || other is HamsterBatchCreateResponseDataItemsInner &&
      other.clientItemId == clientItemId &&
      other.status == status &&
      other.resource == resource &&
      other.error == error;

    @override
    int get hashCode =>
        clientItemId.hashCode +
        status.hashCode +
        (resource == null ? 0 : resource.hashCode) +
        (error == null ? 0 : error.hashCode);

  factory HamsterBatchCreateResponseDataItemsInner.fromJson(Map<String, dynamic> json) => _$HamsterBatchCreateResponseDataItemsInnerFromJson(json);

  Map<String, dynamic> toJson() => _$HamsterBatchCreateResponseDataItemsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
