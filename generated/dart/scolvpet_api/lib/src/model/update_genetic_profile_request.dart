//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_genetic_profile_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateGeneticProfileRequest {
  /// Returns a new [UpdateGeneticProfileRequest] instance.
  UpdateGeneticProfileRequest({

     this.name,

     this.notes,

     this.confidence,

     this.phenotype,

     this.genotype,

    required  this.version,

     this.hamsterId,
  });

  @JsonKey(

    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



      /// 备注；可传空串清空
  @JsonKey(

    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;



  @JsonKey(

    name: r'confidence',
    required: false,
    includeIfNull: false,
  )


  final UpdateGeneticProfileRequestConfidenceEnum? confidence;



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



      /// 当前档案 version，不匹配则 422
          // minimum: 1
  @JsonKey(

    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;



      /// 绑定个体 uuid；空字符串解除绑定；省略则不变
  @JsonKey(

    name: r'hamster_id',
    required: false,
    includeIfNull: false,
  )


  final String? hamsterId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdateGeneticProfileRequest &&
      other.name == name &&
      other.notes == notes &&
      other.confidence == confidence &&
      other.phenotype == phenotype &&
      other.genotype == genotype &&
      other.version == version &&
      other.hamsterId == hamsterId;

    @override
    int get hashCode =>
        name.hashCode +
        notes.hashCode +
        confidence.hashCode +
        phenotype.hashCode +
        genotype.hashCode +
        version.hashCode +
        hamsterId.hashCode;

  factory UpdateGeneticProfileRequest.fromJson(Map<String, dynamic> json) => _$UpdateGeneticProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateGeneticProfileRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum UpdateGeneticProfileRequestConfidenceEnum {
@JsonValue(r'observed')
observed(r'observed'),
@JsonValue(r'inferred')
inferred(r'inferred'),
@JsonValue(r'unknown')
unknown(r'unknown');

const UpdateGeneticProfileRequestConfidenceEnum(this.value);

final String value;

@override
String toString() => value;
}
