//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/sex.dart';
import 'package:scolvpet_api/src/model/pup_outcome_status.dart';
import 'package:scolvpet_api/src/model/pup_profile_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pup_identity.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PupIdentity {
  /// Returns a new [PupIdentity] instance.
  PupIdentity({

    required  this.id,

    required  this.litterId,

    required  this.temporaryCode,

    required  this.sex,

     this.sexConfidence,

     this.phenotypeSummary,

     this.destination,

     this.currentEnclosureId,

     this.hamsterId,

    required  this.outcomeStatus,

    required  this.profileStatus,

    required  this.version,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(

    name: r'litter_id',
    required: true,
    includeIfNull: false,
  )


  final String litterId;



  @JsonKey(

    name: r'temporary_code',
    required: true,
    includeIfNull: false,
  )


  final String temporaryCode;



  @JsonKey(

    name: r'sex',
    required: true,
    includeIfNull: false,
  )


  final Sex sex;



          // minimum: 0
          // maximum: 1
  @JsonKey(

    name: r'sex_confidence',
    required: false,
    includeIfNull: false,
  )


  final num? sexConfidence;



  @JsonKey(

    name: r'phenotype_summary',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? phenotypeSummary;



  @JsonKey(

    name: r'destination',
    required: false,
    includeIfNull: false,
  )


  final PupIdentityDestinationEnum? destination;



  @JsonKey(

    name: r'current_enclosure_id',
    required: false,
    includeIfNull: false,
  )


  final String? currentEnclosureId;



  @JsonKey(

    name: r'hamster_id',
    required: false,
    includeIfNull: false,
  )


  final String? hamsterId;



  @JsonKey(

    name: r'outcome_status',
    required: true,
    includeIfNull: false,
  )


  final PupOutcomeStatus outcomeStatus;



  @JsonKey(

    name: r'profile_status',
    required: true,
    includeIfNull: false,
  )


  final PupProfileStatus profileStatus;



          // minimum: 1
  @JsonKey(

    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PupIdentity &&
      other.id == id &&
      other.litterId == litterId &&
      other.temporaryCode == temporaryCode &&
      other.sex == sex &&
      other.sexConfidence == sexConfidence &&
      other.phenotypeSummary == phenotypeSummary &&
      other.destination == destination &&
      other.currentEnclosureId == currentEnclosureId &&
      other.hamsterId == hamsterId &&
      other.outcomeStatus == outcomeStatus &&
      other.profileStatus == profileStatus &&
      other.version == version;

    @override
    int get hashCode =>
        id.hashCode +
        litterId.hashCode +
        temporaryCode.hashCode +
        sex.hashCode +
        (sexConfidence == null ? 0 : sexConfidence.hashCode) +
        phenotypeSummary.hashCode +
        (destination == null ? 0 : destination.hashCode) +
        (currentEnclosureId == null ? 0 : currentEnclosureId.hashCode) +
        (hamsterId == null ? 0 : hamsterId.hashCode) +
        outcomeStatus.hashCode +
        profileStatus.hashCode +
        version.hashCode;

  factory PupIdentity.fromJson(Map<String, dynamic> json) => _$PupIdentityFromJson(json);

  Map<String, dynamic> toJson() => _$PupIdentityToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum PupIdentityDestinationEnum {
@JsonValue(r'breeding')
breeding(r'breeding'),
@JsonValue(r'reserved')
reserved(r'reserved'),
@JsonValue(r'transfer')
transfer(r'transfer'),
@JsonValue(r'undecided')
undecided(r'undecided');

const PupIdentityDestinationEnum(this.value);

final String value;

@override
String toString() => value;
}
