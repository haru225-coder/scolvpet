//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/severity.dart';
import 'package:scolvpet_api/src/model/observation_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mating_observation.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MatingObservation {
  /// Returns a new [MatingObservation] instance.
  MatingObservation({

    required  this.id,

    required  this.pairingAttemptId,

    required  this.observedAt,

    required  this.type,

     this.durationSeconds,

     this.severity,

     this.confidence,

     this.mediaIds,

     this.notes,

    required  this.createdAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'pairing_attempt_id',
    required: true,
    includeIfNull: false,
  )


  final String pairingAttemptId;



  @JsonKey(
    
    name: r'observed_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime observedAt;



  @JsonKey(
    
    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final ObservationType type;



          // minimum: 0
  @JsonKey(
    
    name: r'duration_seconds',
    required: false,
    includeIfNull: false,
  )


  final int? durationSeconds;



  @JsonKey(
    
    name: r'severity',
    required: false,
    includeIfNull: false,
  )


  final Severity? severity;



          // minimum: 0
          // maximum: 1
  @JsonKey(
    
    name: r'confidence',
    required: false,
    includeIfNull: false,
  )


  final num? confidence;



  @JsonKey(
    
    name: r'media_ids',
    required: false,
    includeIfNull: false,
  )


  final List<String>? mediaIds;



  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;



  @JsonKey(
    
    name: r'created_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MatingObservation &&
      other.id == id &&
      other.pairingAttemptId == pairingAttemptId &&
      other.observedAt == observedAt &&
      other.type == type &&
      other.durationSeconds == durationSeconds &&
      other.severity == severity &&
      other.confidence == confidence &&
      other.mediaIds == mediaIds &&
      other.notes == notes &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        pairingAttemptId.hashCode +
        observedAt.hashCode +
        type.hashCode +
        (durationSeconds == null ? 0 : durationSeconds.hashCode) +
        (severity == null ? 0 : severity.hashCode) +
        (confidence == null ? 0 : confidence.hashCode) +
        mediaIds.hashCode +
        (notes == null ? 0 : notes.hashCode) +
        createdAt.hashCode;

  factory MatingObservation.fromJson(Map<String, dynamic> json) => _$MatingObservationFromJson(json);

  Map<String, dynamic> toJson() => _$MatingObservationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

