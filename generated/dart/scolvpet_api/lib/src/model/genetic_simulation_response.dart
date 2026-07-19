//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/genetic_simulation_result.dart';
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'genetic_simulation_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GeneticSimulationResponse {
  /// Returns a new [GeneticSimulationResponse] instance.
  GeneticSimulationResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final GeneticSimulationResult data;



  @JsonKey(

    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GeneticSimulationResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory GeneticSimulationResponse.fromJson(Map<String, dynamic> json) => _$GeneticSimulationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GeneticSimulationResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
