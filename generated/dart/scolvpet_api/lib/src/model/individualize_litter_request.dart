//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/individualize_litter_request_items_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'individualize_litter_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class IndividualizeLitterRequest {
  /// Returns a new [IndividualizeLitterRequest] instance.
  IndividualizeLitterRequest({

    required  this.individualizedAt,

    required  this.timezone,

    required  this.eligibleSetToken,

    required  this.items,
  });

  @JsonKey(

    name: r'individualized_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime individualizedAt;



  @JsonKey(

    name: r'timezone',
    required: true,
    includeIfNull: false,
  )


  final String timezone;



      /// 来自最新 individualization-eligibility 响应；仅作并发快照，不替代服务端重算
  @JsonKey(

    name: r'eligible_set_token',
    required: true,
    includeIfNull: false,
  )


  final String eligibleSetToken;



  @JsonKey(

    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<IndividualizeLitterRequestItemsInner> items;





    @override
    bool operator ==(Object other) => identical(this, other) || other is IndividualizeLitterRequest &&
      other.individualizedAt == individualizedAt &&
      other.timezone == timezone &&
      other.eligibleSetToken == eligibleSetToken &&
      other.items == items;

    @override
    int get hashCode =>
        individualizedAt.hashCode +
        timezone.hashCode +
        eligibleSetToken.hashCode +
        items.hashCode;

  factory IndividualizeLitterRequest.fromJson(Map<String, dynamic> json) => _$IndividualizeLitterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$IndividualizeLitterRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
