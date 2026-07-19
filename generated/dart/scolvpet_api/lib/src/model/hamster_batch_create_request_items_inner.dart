//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/hamster_create_request.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hamster_batch_create_request_items_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HamsterBatchCreateRequestItemsInner {
  /// Returns a new [HamsterBatchCreateRequestItemsInner] instance.
  HamsterBatchCreateRequestItemsInner({

    required  this.clientItemId,

    required  this.hamster,
  });

  @JsonKey(

    name: r'client_item_id',
    required: true,
    includeIfNull: false,
  )


  final String clientItemId;



  @JsonKey(

    name: r'hamster',
    required: true,
    includeIfNull: false,
  )


  final HamsterCreateRequest hamster;





    @override
    bool operator ==(Object other) => identical(this, other) || other is HamsterBatchCreateRequestItemsInner &&
      other.clientItemId == clientItemId &&
      other.hamster == hamster;

    @override
    int get hashCode =>
        clientItemId.hashCode +
        hamster.hashCode;

  factory HamsterBatchCreateRequestItemsInner.fromJson(Map<String, dynamic> json) => _$HamsterBatchCreateRequestItemsInnerFromJson(json);

  Map<String, dynamic> toJson() => _$HamsterBatchCreateRequestItemsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
