//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/page_info.dart';
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:scolvpet_api/src/model/species_rule_version.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'species_rule_version_list_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SpeciesRuleVersionListResponse {
  /// Returns a new [SpeciesRuleVersionListResponse] instance.
  SpeciesRuleVersionListResponse({

    required  this.data,

    required  this.page,

    required  this.meta,
  });

  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final List<SpeciesRuleVersion> data;



  @JsonKey(

    name: r'page',
    required: true,
    includeIfNull: false,
  )


  final PageInfo page;



  @JsonKey(

    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SpeciesRuleVersionListResponse &&
      other.data == data &&
      other.page == page &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        page.hashCode +
        meta.hashCode;

  factory SpeciesRuleVersionListResponse.fromJson(Map<String, dynamic> json) => _$SpeciesRuleVersionListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SpeciesRuleVersionListResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
