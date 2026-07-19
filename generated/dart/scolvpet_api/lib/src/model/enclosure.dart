//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/enclosure_dimensions.dart';
import 'package:scolvpet_api/src/model/enclosure_state.dart';
import 'package:scolvpet_api/src/model/cleanliness_state.dart';
import 'package:scolvpet_api/src/model/enclosure_stay.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'enclosure.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Enclosure {
  /// Returns a new [Enclosure] instance.
  Enclosure({

    required  this.id,

    required  this.ownerId,

    required  this.code,

     this.rackCode,

     this.levelCode,

     this.dimensions,

    required  this.state,

    required  this.cleanlinessState,

     this.capacity = 1,

     this.equipment,

     this.lastCleanedAt,

     this.currentStays,

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

    name: r'code',
    required: true,
    includeIfNull: false,
  )


  final String code;



  @JsonKey(

    name: r'rack_code',
    required: false,
    includeIfNull: false,
  )


  final String? rackCode;



  @JsonKey(

    name: r'level_code',
    required: false,
    includeIfNull: false,
  )


  final String? levelCode;



  @JsonKey(

    name: r'dimensions',
    required: false,
    includeIfNull: false,
  )


  final EnclosureDimensions? dimensions;



  @JsonKey(

    name: r'state',
    required: true,
    includeIfNull: false,
  )


  final EnclosureState state;



  @JsonKey(

    name: r'cleanliness_state',
    required: true,
    includeIfNull: false,
  )


  final CleanlinessState cleanlinessState;



          // minimum: 1
  @JsonKey(
    defaultValue: 1,
    name: r'capacity',
    required: false,
    includeIfNull: false,
  )


  final int? capacity;



  @JsonKey(

    name: r'equipment',
    required: false,
    includeIfNull: false,
  )


  final List<String>? equipment;



  @JsonKey(

    name: r'last_cleaned_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? lastCleanedAt;



  @JsonKey(

    name: r'current_stays',
    required: false,
    includeIfNull: false,
  )


  final List<EnclosureStay>? currentStays;



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
    bool operator ==(Object other) => identical(this, other) || other is Enclosure &&
      other.id == id &&
      other.ownerId == ownerId &&
      other.code == code &&
      other.rackCode == rackCode &&
      other.levelCode == levelCode &&
      other.dimensions == dimensions &&
      other.state == state &&
      other.cleanlinessState == cleanlinessState &&
      other.capacity == capacity &&
      other.equipment == equipment &&
      other.lastCleanedAt == lastCleanedAt &&
      other.currentStays == currentStays &&
      other.version == version &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        id.hashCode +
        ownerId.hashCode +
        code.hashCode +
        (rackCode == null ? 0 : rackCode.hashCode) +
        (levelCode == null ? 0 : levelCode.hashCode) +
        (dimensions == null ? 0 : dimensions.hashCode) +
        state.hashCode +
        cleanlinessState.hashCode +
        capacity.hashCode +
        equipment.hashCode +
        (lastCleanedAt == null ? 0 : lastCleanedAt.hashCode) +
        currentStays.hashCode +
        version.hashCode +
        createdAt.hashCode +
        updatedAt.hashCode;

  factory Enclosure.fromJson(Map<String, dynamic> json) => _$EnclosureFromJson(json);

  Map<String, dynamic> toJson() => _$EnclosureToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
