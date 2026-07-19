//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/health_record_type.dart';
import 'package:scolvpet_api/src/model/severity.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_record_create_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthRecordCreateRequest {
  /// Returns a new [HealthRecordCreateRequest] instance.
  HealthRecordCreateRequest({

     this.hamsterId,

     this.litterId,

    required  this.type,

    required  this.observedAt,

     this.structuredChecks,

     this.severity,

     this.medication,

     this.mediaIds,

     this.followUpAt,

     this.notes,
  });

  @JsonKey(

    name: r'hamster_id',
    required: false,
    includeIfNull: false,
  )


  final String? hamsterId;



  @JsonKey(

    name: r'litter_id',
    required: false,
    includeIfNull: false,
  )


  final String? litterId;



  @JsonKey(

    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final HealthRecordType type;



  @JsonKey(

    name: r'observed_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime observedAt;



  @JsonKey(

    name: r'structured_checks',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? structuredChecks;



  @JsonKey(

    name: r'severity',
    required: false,
    includeIfNull: false,
  )


  final Severity? severity;



  @JsonKey(

    name: r'medication',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? medication;



  @JsonKey(

    name: r'media_ids',
    required: false,
    includeIfNull: false,
  )


  final List<String>? mediaIds;



  @JsonKey(

    name: r'follow_up_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? followUpAt;



  @JsonKey(

    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is HealthRecordCreateRequest &&
      other.hamsterId == hamsterId &&
      other.litterId == litterId &&
      other.type == type &&
      other.observedAt == observedAt &&
      other.structuredChecks == structuredChecks &&
      other.severity == severity &&
      other.medication == medication &&
      other.mediaIds == mediaIds &&
      other.followUpAt == followUpAt &&
      other.notes == notes;

    @override
    int get hashCode =>
        (hamsterId == null ? 0 : hamsterId.hashCode) +
        (litterId == null ? 0 : litterId.hashCode) +
        type.hashCode +
        observedAt.hashCode +
        structuredChecks.hashCode +
        (severity == null ? 0 : severity.hashCode) +
        medication.hashCode +
        mediaIds.hashCode +
        (followUpAt == null ? 0 : followUpAt.hashCode) +
        (notes == null ? 0 : notes.hashCode);

  factory HealthRecordCreateRequest.fromJson(Map<String, dynamic> json) => _$HealthRecordCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$HealthRecordCreateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
