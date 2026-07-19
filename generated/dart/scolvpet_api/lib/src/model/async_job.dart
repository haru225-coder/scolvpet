//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/error_object.dart';
import 'package:scolvpet_api/src/model/job_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'async_job.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AsyncJob {
  /// Returns a new [AsyncJob] instance.
  AsyncJob({

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


  final AsyncJobJobTypeEnum jobType;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is AsyncJob &&
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
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        id.hashCode +
        jobType.hashCode +
        status.hashCode +
        progressPercent.hashCode +
        (currentStep == null ? 0 : currentStep.hashCode) +
        (error == null ? 0 : error.hashCode) +
        retryable.hashCode +
        attempt.hashCode +
        result.hashCode +
        (expiresAt == null ? 0 : expiresAt.hashCode) +
        version.hashCode +
        createdAt.hashCode +
        updatedAt.hashCode;

  factory AsyncJob.fromJson(Map<String, dynamic> json) => _$AsyncJobFromJson(json);

  Map<String, dynamic> toJson() => _$AsyncJobToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum AsyncJobJobTypeEnum {
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

const AsyncJobJobTypeEnum(this.value);

final String value;

@override
String toString() => value;
}
