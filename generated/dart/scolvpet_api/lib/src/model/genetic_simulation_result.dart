//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/genetic_outcome.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'genetic_simulation_result.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GeneticSimulationResult {
  /// Returns a new [GeneticSimulationResult] instance.
  GeneticSimulationResult({

    required  this.sire,

    required  this.dam,

    required  this.outcomes,

    required  this.notes,
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



  @JsonKey(
    
    name: r'outcomes',
    required: true,
    includeIfNull: false,
  )


  final List<GeneticOutcome> outcomes;



  @JsonKey(
    
    name: r'notes',
    required: true,
    includeIfNull: false,
  )


  final String notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GeneticSimulationResult &&
      other.sire == sire &&
      other.dam == dam &&
      other.outcomes == outcomes &&
      other.notes == notes;

    @override
    int get hashCode =>
        sire.hashCode +
        dam.hashCode +
        outcomes.hashCode +
        notes.hashCode;

  factory GeneticSimulationResult.fromJson(Map<String, dynamic> json) => _$GeneticSimulationResultFromJson(json);

  Map<String, dynamic> toJson() => _$GeneticSimulationResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

