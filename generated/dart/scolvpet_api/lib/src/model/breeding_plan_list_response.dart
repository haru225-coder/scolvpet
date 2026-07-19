//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/page_info.dart';
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:scolvpet_api/src/model/breeding_plan.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'breeding_plan_list_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BreedingPlanListResponse {
  /// Returns a new [BreedingPlanListResponse] instance.
  BreedingPlanListResponse({

    required  this.data,

    required  this.page,

    required  this.meta,
  });

  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final List<BreedingPlan> data;



  @JsonKey(

    name: r'page',
    required: true,
    includeIfNull: false,
  )


  final PageInfo page;



  @JsonKey(

    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BreedingPlanListResponse &&
      other.data == data &&
      other.page == page &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        page.hashCode +
        meta.hashCode;

  factory BreedingPlanListResponse.fromJson(Map<String, dynamic> json) => _$BreedingPlanListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BreedingPlanListResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
