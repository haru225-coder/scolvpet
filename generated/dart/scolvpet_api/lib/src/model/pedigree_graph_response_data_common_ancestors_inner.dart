//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pedigree_graph_response_data_common_ancestors_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PedigreeGraphResponseDataCommonAncestorsInner {
  /// Returns a new [PedigreeGraphResponseDataCommonAncestorsInner] instance.
  PedigreeGraphResponseDataCommonAncestorsInner({

    required  this.hamsterId,

    required  this.paths,

    required  this.minimumGeneration,
  });

  @JsonKey(
    
    name: r'hamster_id',
    required: true,
    includeIfNull: false,
  )


  final String hamsterId;



          // minimum: 1
  @JsonKey(
    
    name: r'paths',
    required: true,
    includeIfNull: false,
  )


  final int paths;



          // minimum: 1
  @JsonKey(
    
    name: r'minimum_generation',
    required: true,
    includeIfNull: false,
  )


  final int minimumGeneration;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PedigreeGraphResponseDataCommonAncestorsInner &&
      other.hamsterId == hamsterId &&
      other.paths == paths &&
      other.minimumGeneration == minimumGeneration;

    @override
    int get hashCode =>
        hamsterId.hashCode +
        paths.hashCode +
        minimumGeneration.hashCode;

  factory PedigreeGraphResponseDataCommonAncestorsInner.fromJson(Map<String, dynamic> json) => _$PedigreeGraphResponseDataCommonAncestorsInnerFromJson(json);

  Map<String, dynamic> toJson() => _$PedigreeGraphResponseDataCommonAncestorsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

