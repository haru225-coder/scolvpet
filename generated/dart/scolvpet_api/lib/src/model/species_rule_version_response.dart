//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:scolvpet_api/src/model/species_rule_version.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'species_rule_version_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SpeciesRuleVersionResponse {
  /// Returns a new [SpeciesRuleVersionResponse] instance.
  SpeciesRuleVersionResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final SpeciesRuleVersion data;



  @JsonKey(

    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SpeciesRuleVersionResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory SpeciesRuleVersionResponse.fromJson(Map<String, dynamic> json) => _$SpeciesRuleVersionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SpeciesRuleVersionResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
