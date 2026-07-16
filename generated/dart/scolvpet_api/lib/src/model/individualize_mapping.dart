//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/hamster.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'individualize_mapping.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class IndividualizeMapping {
  /// Returns a new [IndividualizeMapping] instance.
  IndividualizeMapping({

    required  this.pupIdentityId,

    required  this.hamster,
  });

  @JsonKey(
    
    name: r'pup_identity_id',
    required: true,
    includeIfNull: false,
  )


  final String pupIdentityId;



  @JsonKey(
    
    name: r'hamster',
    required: true,
    includeIfNull: false,
  )


  final Hamster hamster;





    @override
    bool operator ==(Object other) => identical(this, other) || other is IndividualizeMapping &&
      other.pupIdentityId == pupIdentityId &&
      other.hamster == hamster;

    @override
    int get hashCode =>
        pupIdentityId.hashCode +
        hamster.hashCode;

  factory IndividualizeMapping.fromJson(Map<String, dynamic> json) => _$IndividualizeMappingFromJson(json);

  Map<String, dynamic> toJson() => _$IndividualizeMappingToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

