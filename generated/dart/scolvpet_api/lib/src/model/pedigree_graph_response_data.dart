//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/litter_member.dart';
import 'package:scolvpet_api/src/model/pedigree_graph_response_data_common_ancestors_inner.dart';
import 'package:scolvpet_api/src/model/pedigree_parentage.dart';
import 'package:scolvpet_api/src/model/hamster.dart';
import 'package:scolvpet_api/src/model/litter_parent.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pedigree_graph_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PedigreeGraphResponseData {
  /// Returns a new [PedigreeGraphResponseData] instance.
  PedigreeGraphResponseData({

    required  this.rootHamsterId,

    required  this.nodes,

    required  this.parentages,

    required  this.litterParents,

    required  this.litterMembers,

    required  this.commonAncestors,
  });

  @JsonKey(
    
    name: r'root_hamster_id',
    required: true,
    includeIfNull: false,
  )


  final String rootHamsterId;



  @JsonKey(
    
    name: r'nodes',
    required: true,
    includeIfNull: false,
  )


  final List<Hamster> nodes;



  @JsonKey(
    
    name: r'parentages',
    required: true,
    includeIfNull: false,
  )


  final List<PedigreeParentage> parentages;



  @JsonKey(
    
    name: r'litter_parents',
    required: true,
    includeIfNull: false,
  )


  final List<LitterParent> litterParents;



  @JsonKey(
    
    name: r'litter_members',
    required: true,
    includeIfNull: false,
  )


  final List<LitterMember> litterMembers;



  @JsonKey(
    
    name: r'common_ancestors',
    required: true,
    includeIfNull: false,
  )


  final List<PedigreeGraphResponseDataCommonAncestorsInner> commonAncestors;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PedigreeGraphResponseData &&
      other.rootHamsterId == rootHamsterId &&
      other.nodes == nodes &&
      other.parentages == parentages &&
      other.litterParents == litterParents &&
      other.litterMembers == litterMembers &&
      other.commonAncestors == commonAncestors;

    @override
    int get hashCode =>
        rootHamsterId.hashCode +
        nodes.hashCode +
        parentages.hashCode +
        litterParents.hashCode +
        litterMembers.hashCode +
        commonAncestors.hashCode;

  factory PedigreeGraphResponseData.fromJson(Map<String, dynamic> json) => _$PedigreeGraphResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$PedigreeGraphResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

