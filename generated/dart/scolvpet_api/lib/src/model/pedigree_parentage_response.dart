//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/pedigree_parentage.dart';
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pedigree_parentage_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PedigreeParentageResponse {
  /// Returns a new [PedigreeParentageResponse] instance.
  PedigreeParentageResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(
    
    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final PedigreeParentage data;



  @JsonKey(
    
    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PedigreeParentageResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory PedigreeParentageResponse.fromJson(Map<String, dynamic> json) => _$PedigreeParentageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PedigreeParentageResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

