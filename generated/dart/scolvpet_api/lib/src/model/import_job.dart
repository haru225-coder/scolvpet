//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/import_template_type.dart';
import 'package:scolvpet_api/src/model/error_object.dart';
import 'package:scolvpet_api/src/model/job_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'import_job.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ImportJob {
  /// Returns a new [ImportJob] instance.
  ImportJob({

    required  this.id,

    required  this.jobType,

    required  this.status,

    required  this.progressPercent,

     this.currentStep,

     this.error,

    required  this.retryable,

     this.attempt = 1,

     this.result,

     this.expiresAt,

    required  this.version,

    required  this.createdAt,

    required  this.updatedAt,

    required  this.templateType,

    required  this.phase,

     this.sourceEncoding,

    required  this.sourceColumns,

    required  this.mapping,

     this.preflightVersion,

    required  this.totalRows,

    required  this.validRows,

    required  this.warningRows,

    required  this.invalidRows,

    required  this.importedRows,

    required  this.historicalLittersToCreate,

    required  this.relationshipAssertionsToCreate,

    required  this.blockingIssueCount,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(

    name: r'job_type',
    required: true,
    includeIfNull: false,
  )


  final ImportJobJobTypeEnum jobType;



  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final JobStatus status;



          // minimum: 0
          // maximum: 100
  @JsonKey(

    name: r'progress_percent',
    required: true,
    includeIfNull: false,
  )


  final int progressPercent;



  @JsonKey(

    name: r'current_step',
    required: false,
    includeIfNull: false,
  )


  final String? currentStep;



  @JsonKey(

    name: r'error',
    required: false,
    includeIfNull: false,
  )


  final ErrorObject? error;



  @JsonKey(

    name: r'retryable',
    required: true,
    includeIfNull: false,
  )


  final bool retryable;



          // minimum: 1
  @JsonKey(
    defaultValue: 1,
    name: r'attempt',
    required: false,
    includeIfNull: false,
  )


  final int? attempt;



  @JsonKey(

    name: r'result',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? result;



  @JsonKey(

    name: r'expires_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? expiresAt;



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



  @JsonKey(

    name: r'template_type',
    required: true,
    includeIfNull: false,
  )


  final ImportTemplateType templateType;



  @JsonKey(

    name: r'phase',
    required: true,
    includeIfNull: false,
  )


  final ImportJobPhaseEnum phase;



  @JsonKey(

    name: r'source_encoding',
    required: false,
    includeIfNull: false,
  )


  final String? sourceEncoding;



  @JsonKey(

    name: r'source_columns',
    required: true,
    includeIfNull: false,
  )


  final List<String> sourceColumns;



  @JsonKey(

    name: r'mapping',
    required: true,
    includeIfNull: false,
  )


  final Map<String, String> mapping;



          // minimum: 1
  @JsonKey(

    name: r'preflight_version',
    required: false,
    includeIfNull: false,
  )


  final int? preflightVersion;



          // minimum: 0
  @JsonKey(

    name: r'total_rows',
    required: true,
    includeIfNull: false,
  )


  final int totalRows;



          // minimum: 0
  @JsonKey(

    name: r'valid_rows',
    required: true,
    includeIfNull: false,
  )


  final int validRows;



          // minimum: 0
  @JsonKey(

    name: r'warning_rows',
    required: true,
    includeIfNull: false,
  )


  final int warningRows;



          // minimum: 0
  @JsonKey(

    name: r'invalid_rows',
    required: true,
    includeIfNull: false,
  )


  final int invalidRows;



          // minimum: 0
  @JsonKey(

    name: r'imported_rows',
    required: true,
    includeIfNull: false,
  )


  final int importedRows;



          // minimum: 0
  @JsonKey(

    name: r'historical_litters_to_create',
    required: true,
    includeIfNull: false,
  )


  final int historicalLittersToCreate;



          // minimum: 0
  @JsonKey(

    name: r'relationship_assertions_to_create',
    required: true,
    includeIfNull: false,
  )


  final int relationshipAssertionsToCreate;



          // minimum: 0
  @JsonKey(

    name: r'blocking_issue_count',
    required: true,
    includeIfNull: false,
  )


  final int blockingIssueCount;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ImportJob &&
      other.id == id &&
      other.jobType == jobType &&
      other.status == status &&
      other.progressPercent == progressPercent &&
      other.currentStep == currentStep &&
      other.error == error &&
      other.retryable == retryable &&
      other.attempt == attempt &&
      other.result == result &&
      other.expiresAt == expiresAt &&
      other.version == version &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.templateType == templateType &&
      other.phase == phase &&
      other.sourceEncoding == sourceEncoding &&
      other.sourceColumns == sourceColumns &&
      other.mapping == mapping &&
      other.preflightVersion == preflightVersion &&
      other.totalRows == totalRows &&
      other.validRows == validRows &&
      other.warningRows == warningRows &&
      other.invalidRows == invalidRows &&
      other.importedRows == importedRows &&
      other.historicalLittersToCreate == historicalLittersToCreate &&
      other.relationshipAssertionsToCreate == relationshipAssertionsToCreate &&
      other.blockingIssueCount == blockingIssueCount;

    @override
    int get hashCode =>
        id.hashCode +
        jobType.hashCode +
        status.hashCode +
        progressPercent.hashCode +
        currentStep.hashCode +
        error.hashCode +
        retryable.hashCode +
        attempt.hashCode +
        result.hashCode +
        expiresAt.hashCode +
        version.hashCode +
        createdAt.hashCode +
        updatedAt.hashCode +
        templateType.hashCode +
        phase.hashCode +
        (sourceEncoding == null ? 0 : sourceEncoding.hashCode) +
        sourceColumns.hashCode +
        mapping.hashCode +
        (preflightVersion == null ? 0 : preflightVersion.hashCode) +
        totalRows.hashCode +
        validRows.hashCode +
        warningRows.hashCode +
        invalidRows.hashCode +
        importedRows.hashCode +
        historicalLittersToCreate.hashCode +
        relationshipAssertionsToCreate.hashCode +
        blockingIssueCount.hashCode;

  factory ImportJob.fromJson(Map<String, dynamic> json) => _$ImportJobFromJson(json);

  Map<String, dynamic> toJson() => _$ImportJobToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum ImportJobJobTypeEnum {
@JsonValue(r'import')
import_(r'import'),
@JsonValue(r'export')
export_(r'export'),
@JsonValue(r'backup')
backup(r'backup'),
@JsonValue(r'media_derivative')
mediaDerivative(r'media_derivative'),
@JsonValue(r'video_transcode')
videoTranscode(r'video_transcode'),
@JsonValue(r'birth_card')
birthCard(r'birth_card');

const ImportJobJobTypeEnum(this.value);

final String value;

@override
String toString() => value;
}



enum ImportJobPhaseEnum {
@JsonValue(r'detecting')
detecting(r'detecting'),
@JsonValue(r'mapping')
mapping(r'mapping'),
@JsonValue(r'preflight')
preflight(r'preflight'),
@JsonValue(r'ready_to_commit')
readyToCommit(r'ready_to_commit'),
@JsonValue(r'importing')
importing(r'importing'),
@JsonValue(r'completed')
completed(r'completed');

const ImportJobPhaseEnum(this.value);

final String value;

@override
String toString() => value;
}
