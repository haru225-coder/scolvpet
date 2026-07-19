//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/error_object.dart';
import 'package:scolvpet_api/src/model/job_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'backup_job.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BackupJob {
  /// Returns a new [BackupJob] instance.
  BackupJob({

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

    required  this.includesStructuredData,

    required  this.includesMediaManifest,

    required  this.includesChecksums,

     this.sizeBytes,

     this.sha256,

    required  this.integrityStatus,

    required  this.restoreReadiness,

     this.verifiedAt,
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


  final BackupJobJobTypeEnum jobType;



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

    name: r'includes_structured_data',
    required: true,
    includeIfNull: false,
  )


  final BackupJobIncludesStructuredDataEnum includesStructuredData;



  @JsonKey(

    name: r'includes_media_manifest',
    required: true,
    includeIfNull: false,
  )


  final BackupJobIncludesMediaManifestEnum includesMediaManifest;



  @JsonKey(

    name: r'includes_checksums',
    required: true,
    includeIfNull: false,
  )


  final BackupJobIncludesChecksumsEnum includesChecksums;



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



  @JsonKey(

    name: r'integrity_status',
    required: true,
    includeIfNull: false,
  )


  final BackupJobIntegrityStatusEnum integrityStatus;



  @JsonKey(

    name: r'restore_readiness',
    required: true,
    includeIfNull: false,
  )


  final BackupJobRestoreReadinessEnum restoreReadiness;



  @JsonKey(

    name: r'verified_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? verifiedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BackupJob &&
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
      other.includesStructuredData == includesStructuredData &&
      other.includesMediaManifest == includesMediaManifest &&
      other.includesChecksums == includesChecksums &&
      other.sizeBytes == sizeBytes &&
      other.sha256 == sha256 &&
      other.integrityStatus == integrityStatus &&
      other.restoreReadiness == restoreReadiness &&
      other.verifiedAt == verifiedAt;

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
        includesStructuredData.hashCode +
        includesMediaManifest.hashCode +
        includesChecksums.hashCode +
        (sizeBytes == null ? 0 : sizeBytes.hashCode) +
        (sha256 == null ? 0 : sha256.hashCode) +
        integrityStatus.hashCode +
        restoreReadiness.hashCode +
        (verifiedAt == null ? 0 : verifiedAt.hashCode);

  factory BackupJob.fromJson(Map<String, dynamic> json) => _$BackupJobFromJson(json);

  Map<String, dynamic> toJson() => _$BackupJobToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum BackupJobJobTypeEnum {
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

const BackupJobJobTypeEnum(this.value);

final String value;

@override
String toString() => value;
}



enum BackupJobIncludesStructuredDataEnum {
@JsonValue('true')
true_('true');

const BackupJobIncludesStructuredDataEnum(this.value);

final String value;

@override
String toString() => value;
}



enum BackupJobIncludesMediaManifestEnum {
@JsonValue('true')
true_('true');

const BackupJobIncludesMediaManifestEnum(this.value);

final String value;

@override
String toString() => value;
}



enum BackupJobIncludesChecksumsEnum {
@JsonValue('true')
true_('true');

const BackupJobIncludesChecksumsEnum(this.value);

final String value;

@override
String toString() => value;
}



enum BackupJobIntegrityStatusEnum {
@JsonValue(r'pending')
pending(r'pending'),
@JsonValue(r'verified')
verified(r'verified'),
@JsonValue(r'failed')
failed(r'failed');

const BackupJobIntegrityStatusEnum(this.value);

final String value;

@override
String toString() => value;
}



enum BackupJobRestoreReadinessEnum {
@JsonValue(r'not_ready')
notReady(r'not_ready'),
@JsonValue(r'downloadable_restore_basis')
downloadableRestoreBasis(r'downloadable_restore_basis'),
@JsonValue(r'blocked')
blocked(r'blocked');

const BackupJobRestoreReadinessEnum(this.value);

final String value;

@override
String toString() => value;
}
