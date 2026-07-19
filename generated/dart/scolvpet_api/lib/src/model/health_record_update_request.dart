//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/severity.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_record_update_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthRecordUpdateRequest {
  /// Returns a new [HealthRecordUpdateRequest] instance.
  HealthRecordUpdateRequest({

     this.structuredChecks,

     this.severity,

     this.medication,

     this.mediaIds,

     this.followUpAt,

     this.notes,
  });

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
    bool operator ==(Object other) => identical(this, other) || other is HealthRecordUpdateRequest &&
      other.structuredChecks == structuredChecks &&
      other.severity == severity &&
      other.medication == medication &&
      other.mediaIds == mediaIds &&
      other.followUpAt == followUpAt &&
      other.notes == notes;

    @override
    int get hashCode =>
        structuredChecks.hashCode +
        (severity == null ? 0 : severity.hashCode) +
        medication.hashCode +
        mediaIds.hashCode +
        (followUpAt == null ? 0 : followUpAt.hashCode) +
        (notes == null ? 0 : notes.hashCode);

  factory HealthRecordUpdateRequest.fromJson(Map<String, dynamic> json) => _$HealthRecordUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$HealthRecordUpdateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
