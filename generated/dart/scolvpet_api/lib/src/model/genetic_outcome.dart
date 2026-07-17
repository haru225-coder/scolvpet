//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'genetic_outcome.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GeneticOutcome {
  /// Returns a new [GeneticOutcome] instance.
  GeneticOutcome({

    required  this.genotypeKey,

    required  this.genotype,

    required  this.phenotypeLabel,

    required  this.phenotype,

    required  this.probability,

    required  this.countWeight,
  });

  @JsonKey(
    
    name: r'genotype_key',
    required: true,
    includeIfNull: false,
  )


  final String genotypeKey;



  @JsonKey(
    
    name: r'genotype',
    required: true,
    includeIfNull: false,
  )


  final Map<String, String> genotype;



  @JsonKey(
    
    name: r'phenotype_label',
    required: true,
    includeIfNull: false,
  )


  final String phenotypeLabel;



  @JsonKey(
    
    name: r'phenotype',
    required: true,
    includeIfNull: false,
  )


  final Map<String, String> phenotype;



          // minimum: 0
          // maximum: 1
  @JsonKey(
    
    name: r'probability',
    required: true,
    includeIfNull: false,
  )


  final double probability;



          // minimum: 1
  @JsonKey(
    
    name: r'count_weight',
    required: true,
    includeIfNull: false,
  )


  final int countWeight;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GeneticOutcome &&
      other.genotypeKey == genotypeKey &&
      other.genotype == genotype &&
      other.phenotypeLabel == phenotypeLabel &&
      other.phenotype == phenotype &&
      other.probability == probability &&
      other.countWeight == countWeight;

    @override
    int get hashCode =>
        genotypeKey.hashCode +
        genotype.hashCode +
        phenotypeLabel.hashCode +
        phenotype.hashCode +
        probability.hashCode +
        countWeight.hashCode;

  factory GeneticOutcome.fromJson(Map<String, dynamic> json) => _$GeneticOutcomeFromJson(json);

  Map<String, dynamic> toJson() => _$GeneticOutcomeToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

