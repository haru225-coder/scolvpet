//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/wean_litter_request_items_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wean_litter_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WeanLitterRequest {
  /// Returns a new [WeanLitterRequest] instance.
  WeanLitterRequest({

    required  this.weanedAt,

    required  this.timezone,

    required  this.items,
  });

  @JsonKey(
    
    name: r'weaned_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime weanedAt;



  @JsonKey(
    
    name: r'timezone',
    required: true,
    includeIfNull: false,
  )


  final String timezone;



  @JsonKey(
    
    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<WeanLitterRequestItemsInner> items;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WeanLitterRequest &&
      other.weanedAt == weanedAt &&
      other.timezone == timezone &&
      other.items == items;

    @override
    int get hashCode =>
        weanedAt.hashCode +
        timezone.hashCode +
        items.hashCode;

  factory WeanLitterRequest.fromJson(Map<String, dynamic> json) => _$WeanLitterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WeanLitterRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

