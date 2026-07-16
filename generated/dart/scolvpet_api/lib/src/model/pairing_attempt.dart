//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/pairing_attempt_status.dart';
import 'package:scolvpet_api/src/model/pairing_result.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pairing_attempt.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PairingAttempt {
  /// Returns a new [PairingAttempt] instance.
  PairingAttempt({

    required  this.id,

    required  this.breedingPlanId,

    required  this.sequence,

    required  this.enclosureId,

    required  this.startedAt,

     this.endedAt,

     this.separatedAt,

    required  this.separationDeadline,

    required  this.status,

    required  this.result,

     this.conflictLevel,

     this.sireDestinationEnclosureId,

     this.damDestinationEnclosureId,

     this.notes,

    required  this.version,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'breeding_plan_id',
    required: true,
    includeIfNull: false,
  )


  final String breedingPlanId;



          // minimum: 1
  @JsonKey(
    
    name: r'sequence',
    required: true,
    includeIfNull: false,
  )


  final int sequence;



  @JsonKey(
    
    name: r'enclosure_id',
    required: true,
    includeIfNull: false,
  )


  final String enclosureId;



  @JsonKey(
    
    name: r'started_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime startedAt;



  @JsonKey(
    
    name: r'ended_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? endedAt;



  @JsonKey(
    
    name: r'separated_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? separatedAt;



  @JsonKey(
    
    name: r'separation_deadline',
    required: true,
    includeIfNull: false,
  )


  final DateTime separationDeadline;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final PairingAttemptStatus status;



      /// 配对尝试未结束时为 null，分笼闭环后写入持久结果
  @JsonKey(
    
    name: r'result',
    required: true,
    includeIfNull: true,
  )


  final PairingResult? result;



  @JsonKey(
    
    name: r'conflict_level',
    required: false,
    includeIfNull: false,
  )


  final PairingAttemptConflictLevelEnum? conflictLevel;



  @JsonKey(
    
    name: r'sire_destination_enclosure_id',
    required: false,
    includeIfNull: false,
  )


  final String? sireDestinationEnclosureId;



  @JsonKey(
    
    name: r'dam_destination_enclosure_id',
    required: false,
    includeIfNull: false,
  )


  final String? damDestinationEnclosureId;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is PairingAttempt &&
      other.id == id &&
      other.breedingPlanId == breedingPlanId &&
      other.sequence == sequence &&
      other.enclosureId == enclosureId &&
      other.startedAt == startedAt &&
      other.endedAt == endedAt &&
      other.separatedAt == separatedAt &&
      other.separationDeadline == separationDeadline &&
      other.status == status &&
      other.result == result &&
      other.conflictLevel == conflictLevel &&
      other.sireDestinationEnclosureId == sireDestinationEnclosureId &&
      other.damDestinationEnclosureId == damDestinationEnclosureId &&
      other.notes == notes &&
      other.version == version;

    @override
    int get hashCode =>
        id.hashCode +
        breedingPlanId.hashCode +
        sequence.hashCode +
        enclosureId.hashCode +
        startedAt.hashCode +
        (endedAt == null ? 0 : endedAt.hashCode) +
        (separatedAt == null ? 0 : separatedAt.hashCode) +
        separationDeadline.hashCode +
        status.hashCode +
        (result == null ? 0 : result.hashCode) +
        (conflictLevel == null ? 0 : conflictLevel.hashCode) +
        (sireDestinationEnclosureId == null ? 0 : sireDestinationEnclosureId.hashCode) +
        (damDestinationEnclosureId == null ? 0 : damDestinationEnclosureId.hashCode) +
        (notes == null ? 0 : notes.hashCode) +
        version.hashCode;

  factory PairingAttempt.fromJson(Map<String, dynamic> json) => _$PairingAttemptFromJson(json);

  Map<String, dynamic> toJson() => _$PairingAttemptToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum PairingAttemptConflictLevelEnum {
@JsonValue(r'low')
low(r'low'),
@JsonValue(r'medium')
medium(r'medium'),
@JsonValue(r'high')
high(r'high'),
@JsonValue(r'critical')
critical(r'critical');

const PairingAttemptConflictLevelEnum(this.value);

final String value;

@override
String toString() => value;
}


