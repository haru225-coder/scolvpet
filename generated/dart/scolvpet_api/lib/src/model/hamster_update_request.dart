//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/hamster_breeding_status.dart';
import 'package:scolvpet_api/src/model/sex.dart';
import 'package:scolvpet_api/src/model/hamster_lifecycle_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hamster_update_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HamsterUpdateRequest {
  /// Returns a new [HamsterUpdateRequest] instance.
  HamsterUpdateRequest({

     this.internalCode,

     this.name,

     this.varietyCode,

     this.sex,

     this.sexConfidence,

     this.birthDate,

     this.lifecycleStatus,

     this.breedingStatus,

     this.coverMediaId,

     this.notes,
  });

  @JsonKey(
    
    name: r'internal_code',
    required: false,
    includeIfNull: false,
  )


  final String? internalCode;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'variety_code',
    required: false,
    includeIfNull: false,
  )


  final String? varietyCode;



  @JsonKey(
    
    name: r'sex',
    required: false,
    includeIfNull: false,
  )


  final Sex? sex;



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
    
    name: r'lifecycle_status',
    required: false,
    includeIfNull: false,
  )


  final HamsterLifecycleStatus? lifecycleStatus;



  @JsonKey(
    
    name: r'breeding_status',
    required: false,
    includeIfNull: false,
  )


  final HamsterBreedingStatus? breedingStatus;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is HamsterUpdateRequest &&
      other.internalCode == internalCode &&
      other.name == name &&
      other.varietyCode == varietyCode &&
      other.sex == sex &&
      other.sexConfidence == sexConfidence &&
      other.birthDate == birthDate &&
      other.lifecycleStatus == lifecycleStatus &&
      other.breedingStatus == breedingStatus &&
      other.coverMediaId == coverMediaId &&
      other.notes == notes;

    @override
    int get hashCode =>
        internalCode.hashCode +
        (name == null ? 0 : name.hashCode) +
        (varietyCode == null ? 0 : varietyCode.hashCode) +
        sex.hashCode +
        (sexConfidence == null ? 0 : sexConfidence.hashCode) +
        (birthDate == null ? 0 : birthDate.hashCode) +
        lifecycleStatus.hashCode +
        breedingStatus.hashCode +
        (coverMediaId == null ? 0 : coverMediaId.hashCode) +
        (notes == null ? 0 : notes.hashCode);

  factory HamsterUpdateRequest.fromJson(Map<String, dynamic> json) => _$HamsterUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$HamsterUpdateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

