//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/error_object.dart';
import 'package:scolvpet_api/src/model/job_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'export_job.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExportJob {
  /// Returns a new [ExportJob] instance.
  ExportJob({

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

    required  this.datasets,

    required  this.exportFormat,

    required  this.snapshotAt,

     this.fileName,

     this.sizeBytes,

     this.sha256,
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


  final ExportJobJobTypeEnum jobType;



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

    name: r'datasets',
    required: true,
    includeIfNull: false,
  )


  final Set<ExportJobDatasetsEnum> datasets;



  @JsonKey(

    name: r'export_format',
    required: true,
    includeIfNull: false,
  )


  final ExportJobExportFormatEnum exportFormat;



  @JsonKey(

    name: r'snapshot_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime snapshotAt;



  @JsonKey(

    name: r'file_name',
    required: false,
    includeIfNull: false,
  )


  final String? fileName;



          // minimum: 0
  @JsonKey(

    name: r'size_bytes',
    required: false,
    includeIfNull: false,
  )


  final int? sizeBytes;



  @JsonKey(

    name: r'sha256',
    required: false,
    includeIfNull: false,
  )


  final String? sha256;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ExportJob &&
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
      other.datasets == datasets &&
      other.exportFormat == exportFormat &&
      other.snapshotAt == snapshotAt &&
      other.fileName == fileName &&
      other.sizeBytes == sizeBytes &&
      other.sha256 == sha256;

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
        datasets.hashCode +
        exportFormat.hashCode +
        snapshotAt.hashCode +
        (fileName == null ? 0 : fileName.hashCode) +
        (sizeBytes == null ? 0 : sizeBytes.hashCode) +
        (sha256 == null ? 0 : sha256.hashCode);

  factory ExportJob.fromJson(Map<String, dynamic> json) => _$ExportJobFromJson(json);

  Map<String, dynamic> toJson() => _$ExportJobToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum ExportJobJobTypeEnum {
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

const ExportJobJobTypeEnum(this.value);

final String value;

@override
String toString() => value;
}



enum ExportJobDatasetsEnum {
@JsonValue(r'hamsters')
hamsters(r'hamsters'),
@JsonValue(r'enclosures')
enclosures(r'enclosures'),
@JsonValue(r'breeding')
breeding(r'breeding'),
@JsonValue(r'litters')
litters(r'litters'),
@JsonValue(r'weights')
weights(r'weights'),
@JsonValue(r'health')
health(r'health'),
@JsonValue(r'pedigree')
pedigree(r'pedigree');

const ExportJobDatasetsEnum(this.value);

final String value;

@override
String toString() => value;
}



enum ExportJobExportFormatEnum {
@JsonValue(r'csv_zip')
csvZip(r'csv_zip'),
@JsonValue(r'json')
json(r'json');

const ExportJobExportFormatEnum(this.value);

final String value;

@override
String toString() => value;
}
