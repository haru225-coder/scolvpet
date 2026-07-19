//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:scolvpet_api/src/model/publish_breeding_plan_response_data.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'publish_breeding_plan_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PublishBreedingPlanResponse {
  /// Returns a new [PublishBreedingPlanResponse] instance.
  PublishBreedingPlanResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final PublishBreedingPlanResponseData data;



  @JsonKey(

    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PublishBreedingPlanResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory PublishBreedingPlanResponse.fromJson(Map<String, dynamic> json) => _$PublishBreedingPlanResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PublishBreedingPlanResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
