//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'genetic_profile.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GeneticProfile {
  /// Returns a new [GeneticProfile] instance.
  GeneticProfile({

    required  this.id,

     this.hamsterId,

    required  this.name,

    required  this.phenotype,

    required  this.genotype,

    required  this.confidence,

     this.notes,

    required  this.version,

    required  this.updatedAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'hamster_id',
    required: false,
    includeIfNull: false,
  )


  final String? hamsterId;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'phenotype',
    required: true,
    includeIfNull: false,
  )


  final Map<String, Object> phenotype;



  @JsonKey(
    
    name: r'genotype',
    required: true,
    includeIfNull: false,
  )


  final Map<String, String> genotype;



  @JsonKey(
    
    name: r'confidence',
    required: true,
    includeIfNull: false,
  )


  final GeneticProfileConfidenceEnum confidence;



  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;



          // minimum: 1
  @JsonKey(
    
    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;



  @JsonKey(
    
    name: r'updated_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime updatedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GeneticProfile &&
      other.id == id &&
      other.hamsterId == hamsterId &&
      other.name == name &&
      other.phenotype == phenotype &&
      other.genotype == genotype &&
      other.confidence == confidence &&
      other.notes == notes &&
      other.version == version &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        id.hashCode +
        (hamsterId == null ? 0 : hamsterId.hashCode) +
        name.hashCode +
        phenotype.hashCode +
        genotype.hashCode +
        confidence.hashCode +
        (notes == null ? 0 : notes.hashCode) +
        version.hashCode +
        updatedAt.hashCode;

  factory GeneticProfile.fromJson(Map<String, dynamic> json) => _$GeneticProfileFromJson(json);

  Map<String, dynamic> toJson() => _$GeneticProfileToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum GeneticProfileConfidenceEnum {
@JsonValue(r'observed')
observed(r'observed'),
@JsonValue(r'inferred')
inferred(r'inferred'),
@JsonValue(r'unknown')
unknown(r'unknown');

const GeneticProfileConfidenceEnum(this.value);

final String value;

@override
String toString() => value;
}


