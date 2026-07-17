//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_genetic_profile_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateGeneticProfileRequest {
  /// Returns a new [CreateGeneticProfileRequest] instance.
  CreateGeneticProfileRequest({

     this.hamsterId,

    required  this.name,

     this.phenotype,

     this.genotype,

     this.confidence = CreateGeneticProfileRequestConfidenceEnum.unknown,

     this.notes,
  });

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
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? phenotype;



  @JsonKey(
    
    name: r'genotype',
    required: false,
    includeIfNull: false,
  )


  final Map<String, String>? genotype;



  @JsonKey(
    defaultValue: CreateGeneticProfileRequestConfidenceEnum.unknown,
    name: r'confidence',
    required: false,
    includeIfNull: false,
  )


  final CreateGeneticProfileRequestConfidenceEnum? confidence;



  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateGeneticProfileRequest &&
      other.hamsterId == hamsterId &&
      other.name == name &&
      other.phenotype == phenotype &&
      other.genotype == genotype &&
      other.confidence == confidence &&
      other.notes == notes;

    @override
    int get hashCode =>
        (hamsterId == null ? 0 : hamsterId.hashCode) +
        name.hashCode +
        phenotype.hashCode +
        genotype.hashCode +
        confidence.hashCode +
        (notes == null ? 0 : notes.hashCode);

  factory CreateGeneticProfileRequest.fromJson(Map<String, dynamic> json) => _$CreateGeneticProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateGeneticProfileRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum CreateGeneticProfileRequestConfidenceEnum {
@JsonValue(r'observed')
observed(r'observed'),
@JsonValue(r'inferred')
inferred(r'inferred'),
@JsonValue(r'unknown')
unknown(r'unknown');

const CreateGeneticProfileRequestConfidenceEnum(this.value);

final String value;

@override
String toString() => value;
}


