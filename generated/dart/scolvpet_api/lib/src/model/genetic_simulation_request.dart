//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'genetic_simulation_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GeneticSimulationRequest {
  /// Returns a new [GeneticSimulationRequest] instance.
  GeneticSimulationRequest({

    required  this.sire,

    required  this.dam,
  });

  @JsonKey(
    
    name: r'sire',
    required: true,
    includeIfNull: false,
  )


  final Map<String, String> sire;



  @JsonKey(
    
    name: r'dam',
    required: true,
    includeIfNull: false,
  )


  final Map<String, String> dam;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GeneticSimulationRequest &&
      other.sire == sire &&
      other.dam == dam;

    @override
    int get hashCode =>
        sire.hashCode +
        dam.hashCode;

  factory GeneticSimulationRequest.fromJson(Map<String, dynamic> json) => _$GeneticSimulationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GeneticSimulationRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

