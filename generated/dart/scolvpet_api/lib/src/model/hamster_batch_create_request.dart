//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/hamster_batch_create_request_items_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hamster_batch_create_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HamsterBatchCreateRequest {
  /// Returns a new [HamsterBatchCreateRequest] instance.
  HamsterBatchCreateRequest({

    required  this.atomic,

    required  this.items,
  });

      /// true 时任一项失败则全部回滚
  @JsonKey(
    
    name: r'atomic',
    required: true,
    includeIfNull: false,
  )


  final bool atomic;



  @JsonKey(
    
    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<HamsterBatchCreateRequestItemsInner> items;





    @override
    bool operator ==(Object other) => identical(this, other) || other is HamsterBatchCreateRequest &&
      other.atomic == atomic &&
      other.items == items;

    @override
    int get hashCode =>
        atomic.hashCode +
        items.hashCode;

  factory HamsterBatchCreateRequest.fromJson(Map<String, dynamic> json) => _$HamsterBatchCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$HamsterBatchCreateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

