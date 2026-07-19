//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/severity.dart';
import 'package:scolvpet_api/src/model/observation_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'record_observation_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RecordObservationRequest {
  /// Returns a new [RecordObservationRequest] instance.
  RecordObservationRequest({

    required  this.observedAt,

    required  this.type,

     this.durationSeconds,

     this.severity,

     this.confidence,

     this.mediaIds,

     this.notes,
  });

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


  final Set<String>? mediaIds;



  @JsonKey(

    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RecordObservationRequest &&
      other.observedAt == observedAt &&
      other.type == type &&
      other.durationSeconds == durationSeconds &&
      other.severity == severity &&
      other.confidence == confidence &&
      other.mediaIds == mediaIds &&
      other.notes == notes;

    @override
    int get hashCode =>
        observedAt.hashCode +
        type.hashCode +
        (durationSeconds == null ? 0 : durationSeconds.hashCode) +
        (severity == null ? 0 : severity.hashCode) +
        (confidence == null ? 0 : confidence.hashCode) +
        mediaIds.hashCode +
        (notes == null ? 0 : notes.hashCode);

  factory RecordObservationRequest.fromJson(Map<String, dynamic> json) => _$RecordObservationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RecordObservationRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
