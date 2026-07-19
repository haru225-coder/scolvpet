//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/hamster_source_type.dart';
import 'package:scolvpet_api/src/model/hamster_breeding_status.dart';
import 'package:scolvpet_api/src/model/sex.dart';
import 'package:scolvpet_api/src/model/hamster_lifecycle_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hamster.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Hamster {
  /// Returns a new [Hamster] instance.
  Hamster({

    required  this.id,

    required  this.ownerId,

    required  this.internalCode,

     this.name,

    required  this.speciesRuleVersionId,

     this.varietyCode,

    required  this.sex,

     this.sexConfidence,

     this.birthDate,

     this.litterId,

    required  this.sourceType,

    required  this.lifecycleStatus,

    required  this.breedingStatus,

     this.currentEnclosureId,

     this.coverMediaId,

     this.notes,

    required  this.version,

    required  this.createdAt,

    required  this.updatedAt,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(

    name: r'owner_id',
    required: true,
    includeIfNull: false,
  )


  final String ownerId;



  @JsonKey(

    name: r'internal_code',
    required: true,
    includeIfNull: false,
  )


  final String internalCode;



  @JsonKey(

    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(

    name: r'species_rule_version_id',
    required: true,
    includeIfNull: false,
  )


  final String speciesRuleVersionId;



  @JsonKey(

    name: r'variety_code',
    required: false,
    includeIfNull: false,
  )


  final String? varietyCode;



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

    name: r'birth_date',
    required: false,
    includeIfNull: false,
  )


  final DateTime? birthDate;



  @JsonKey(

    name: r'litter_id',
    required: false,
    includeIfNull: false,
  )


  final String? litterId;



  @JsonKey(

    name: r'source_type',
    required: true,
    includeIfNull: false,
  )


  final HamsterSourceType sourceType;



  @JsonKey(

    name: r'lifecycle_status',
    required: true,
    includeIfNull: false,
  )


  final HamsterLifecycleStatus lifecycleStatus;



  @JsonKey(

    name: r'breeding_status',
    required: true,
    includeIfNull: false,
  )


  final HamsterBreedingStatus breedingStatus;



  @JsonKey(

    name: r'current_enclosure_id',
    required: false,
    includeIfNull: false,
  )


  final String? currentEnclosureId;



  @JsonKey(

    name: r'cover_media_id',
    required: false,
    includeIfNull: false,
  )


  final String? coverMediaId;



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

    name: r'created_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;



  @JsonKey(

    name: r'updated_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime updatedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Hamster &&
      other.id == id &&
      other.ownerId == ownerId &&
      other.internalCode == internalCode &&
      other.name == name &&
      other.speciesRuleVersionId == speciesRuleVersionId &&
      other.varietyCode == varietyCode &&
      other.sex == sex &&
      other.sexConfidence == sexConfidence &&
      other.birthDate == birthDate &&
      other.litterId == litterId &&
      other.sourceType == sourceType &&
      other.lifecycleStatus == lifecycleStatus &&
      other.breedingStatus == breedingStatus &&
      other.currentEnclosureId == currentEnclosureId &&
      other.coverMediaId == coverMediaId &&
      other.notes == notes &&
      other.version == version &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        id.hashCode +
        ownerId.hashCode +
        internalCode.hashCode +
        (name == null ? 0 : name.hashCode) +
        speciesRuleVersionId.hashCode +
        (varietyCode == null ? 0 : varietyCode.hashCode) +
        sex.hashCode +
        (sexConfidence == null ? 0 : sexConfidence.hashCode) +
        (birthDate == null ? 0 : birthDate.hashCode) +
        (litterId == null ? 0 : litterId.hashCode) +
        sourceType.hashCode +
        lifecycleStatus.hashCode +
        breedingStatus.hashCode +
        (currentEnclosureId == null ? 0 : currentEnclosureId.hashCode) +
        (coverMediaId == null ? 0 : coverMediaId.hashCode) +
        (notes == null ? 0 : notes.hashCode) +
        version.hashCode +
        createdAt.hashCode +
        updatedAt.hashCode;

  factory Hamster.fromJson(Map<String, dynamic> json) => _$HamsterFromJson(json);

  Map<String, dynamic> toJson() => _$HamsterToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
