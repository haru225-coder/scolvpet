//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/complete_breeding_plan_response_data.dart';
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'complete_breeding_plan_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CompleteBreedingPlanResponse {
  /// Returns a new [CompleteBreedingPlanResponse] instance.
  CompleteBreedingPlanResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(
    
    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final CompleteBreedingPlanResponseData data;



  @JsonKey(
    
    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CompleteBreedingPlanResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory CompleteBreedingPlanResponse.fromJson(Map<String, dynamic> json) => _$CompleteBreedingPlanResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CompleteBreedingPlanResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

