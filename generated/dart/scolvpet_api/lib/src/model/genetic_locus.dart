//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'genetic_locus.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GeneticLocus {
  /// Returns a new [GeneticLocus] instance.
  GeneticLocus({

    required  this.code,

    required  this.name,

    required  this.dominantAllele,

    required  this.recessiveAllele,

    required  this.dominantLabel,

    required  this.recessiveLabel,

     this.description,
  });

  @JsonKey(

    name: r'code',
    required: true,
    includeIfNull: false,
  )


  final String code;



  @JsonKey(

    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(

    name: r'dominant_allele',
    required: true,
    includeIfNull: false,
  )


  final String dominantAllele;



  @JsonKey(

    name: r'recessive_allele',
    required: true,
    includeIfNull: false,
  )


  final String recessiveAllele;



  @JsonKey(

    name: r'dominant_label',
    required: true,
    includeIfNull: false,
  )


  final String dominantLabel;



  @JsonKey(

    name: r'recessive_label',
    required: true,
    includeIfNull: false,
  )


  final String recessiveLabel;



  @JsonKey(

    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GeneticLocus &&
      other.code == code &&
      other.name == name &&
      other.dominantAllele == dominantAllele &&
      other.recessiveAllele == recessiveAllele &&
      other.dominantLabel == dominantLabel &&
      other.recessiveLabel == recessiveLabel &&
      other.description == description;

    @override
    int get hashCode =>
        code.hashCode +
        name.hashCode +
        dominantAllele.hashCode +
        recessiveAllele.hashCode +
        dominantLabel.hashCode +
        recessiveLabel.hashCode +
        (description == null ? 0 : description.hashCode);

  factory GeneticLocus.fromJson(Map<String, dynamic> json) => _$GeneticLocusFromJson(json);

  Map<String, dynamic> toJson() => _$GeneticLocusToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
