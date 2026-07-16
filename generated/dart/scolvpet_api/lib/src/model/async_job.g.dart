// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'async_job.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AsyncJobCWProxy {
  AsyncJob id(String id);

  AsyncJob jobType(AsyncJobJobTypeEnum jobType);

  AsyncJob status(JobStatus status);

  AsyncJob progressPercent(int progressPercent);

  AsyncJob currentStep(String? currentStep);

  AsyncJob error(ErrorObject? error);

  AsyncJob retryable(bool retryable);

  AsyncJob attempt(int? attempt);

  AsyncJob result(Map<String, Object>? result);

  AsyncJob expiresAt(DateTime? expiresAt);

  AsyncJob version(int version);

  AsyncJob createdAt(DateTime createdAt);

  AsyncJob updatedAt(DateTime updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AsyncJob(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AsyncJob(...).copyWith(id: 12, name: "My name")
  /// ````
  AsyncJob call({
    String id,
    AsyncJobJobTypeEnum jobType,
    JobStatus status,
    int progressPercent,
    String? currentStep,
    ErrorObject? error,
    bool retryable,
    int? attempt,
    Map<String, Object>? result,
    DateTime? expiresAt,
    int version,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAsyncJob.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAsyncJob.copyWith.fieldName(...)`
class _$AsyncJobCWProxyImpl implements _$AsyncJobCWProxy {
  const _$AsyncJobCWProxyImpl(this._value);

  final AsyncJob _value;

  @override
  AsyncJob id(String id) => this(id: id);

  @override
  AsyncJob jobType(AsyncJobJobTypeEnum jobType) => this(jobType: jobType);

  @override
  AsyncJob status(JobStatus status) => this(status: status);

  @override
  AsyncJob progressPercent(int progressPercent) =>
      this(progressPercent: progressPercent);

  @override
  AsyncJob currentStep(String? currentStep) => this(currentStep: currentStep);

  @override
  AsyncJob error(ErrorObject? error) => this(error: error);

  @override
  AsyncJob retryable(bool retryable) => this(retryable: retryable);

  @override
  AsyncJob attempt(int? attempt) => this(attempt: attempt);

  @override
  AsyncJob result(Map<String, Object>? result) => this(result: result);

  @override
  AsyncJob expiresAt(DateTime? expiresAt) => this(expiresAt: expiresAt);

  @override
  AsyncJob version(int version) => this(version: version);

  @override
  AsyncJob createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  AsyncJob updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AsyncJob(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AsyncJob(...).copyWith(id: 12, name: "My name")
  /// ````
  AsyncJob call({
    Object? id = const $CopyWithPlaceholder(),
    Object? jobType = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? progressPercent = const $CopyWithPlaceholder(),
    Object? currentStep = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
    Object? retryable = const $CopyWithPlaceholder(),
    Object? attempt = const $CopyWithPlaceholder(),
    Object? result = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return AsyncJob(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      jobType: jobType == const $CopyWithPlaceholder()
          ? _value.jobType
          // ignore: cast_nullable_to_non_nullable
          : jobType as AsyncJobJobTypeEnum,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as JobStatus,
      progressPercent: progressPercent == const $CopyWithPlaceholder()
          ? _value.progressPercent
          // ignore: cast_nullable_to_non_nullable
          : progressPercent as int,
      currentStep: currentStep == const $CopyWithPlaceholder()
          ? _value.currentStep
          // ignore: cast_nullable_to_non_nullable
          : currentStep as String?,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as ErrorObject?,
      retryable: retryable == const $CopyWithPlaceholder()
          ? _value.retryable
          // ignore: cast_nullable_to_non_nullable
          : retryable as bool,
      attempt: attempt == const $CopyWithPlaceholder()
          ? _value.attempt
          // ignore: cast_nullable_to_non_nullable
          : attempt as int?,
      result: result == const $CopyWithPlaceholder()
          ? _value.result
          // ignore: cast_nullable_to_non_nullable
          : result as Map<String, Object>?,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime?,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
    );
  }
}

extension $AsyncJobCopyWith on AsyncJob {
  /// Returns a callable class that can be used as follows: `instanceOfAsyncJob.copyWith(...)` or like so:`instanceOfAsyncJob.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AsyncJobCWProxy get copyWith => _$AsyncJobCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AsyncJob _$AsyncJobFromJson(Map<String, dynamic> json) => $checkedCreate(
  'AsyncJob',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'job_type',
        'status',
        'progress_percent',
        'retryable',
        'version',
        'created_at',
        'updated_at',
      ],
    );
    final val = AsyncJob(
      id: $checkedConvert('id', (v) => v as String),
      jobType: $checkedConvert(
        'job_type',
        (v) => $enumDecode(_$AsyncJobJobTypeEnumEnumMap, v),
      ),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$JobStatusEnumMap, v),
      ),
      progressPercent: $checkedConvert(
        'progress_percent',
        (v) => (v as num).toInt(),
      ),
      currentStep: $checkedConvert('current_step', (v) => v as String?),
      error: $checkedConvert(
        'error',
        (v) =>
            v == null ? null : ErrorObject.fromJson(v as Map<String, dynamic>),
      ),
      retryable: $checkedConvert('retryable', (v) => v as bool),
      attempt: $checkedConvert('attempt', (v) => (v as num?)?.toInt() ?? 1),
      result: $checkedConvert(
        'result',
        (v) => (v as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, e as Object),
        ),
      ),
      expiresAt: $checkedConvert(
        'expires_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      version: $checkedConvert('version', (v) => (v as num).toInt()),
      createdAt: $checkedConvert(
        'created_at',
        (v) => DateTime.parse(v as String),
      ),
      updatedAt: $checkedConvert(
        'updated_at',
        (v) => DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'jobType': 'job_type',
    'progressPercent': 'progress_percent',
    'currentStep': 'current_step',
    'expiresAt': 'expires_at',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
  },
);

Map<String, dynamic> _$AsyncJobToJson(AsyncJob instance) => <String, dynamic>{
  'id': instance.id,
  'job_type': _$AsyncJobJobTypeEnumEnumMap[instance.jobType]!,
  'status': _$JobStatusEnumMap[instance.status]!,
  'progress_percent': instance.progressPercent,
  'current_step': ?instance.currentStep,
  'error': ?instance.error?.toJson(),
  'retryable': instance.retryable,
  'attempt': ?instance.attempt,
  'result': ?instance.result,
  'expires_at': ?instance.expiresAt?.toIso8601String(),
  'version': instance.version,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$AsyncJobJobTypeEnumEnumMap = {
  AsyncJobJobTypeEnum.import_: 'import',
  AsyncJobJobTypeEnum.export_: 'export',
  AsyncJobJobTypeEnum.backup: 'backup',
  AsyncJobJobTypeEnum.mediaDerivative: 'media_derivative',
  AsyncJobJobTypeEnum.videoTranscode: 'video_transcode',
  AsyncJobJobTypeEnum.birthCard: 'birth_card',
};

const _$JobStatusEnumMap = {
  JobStatus.queued: 'queued',
  JobStatus.running: 'running',
  JobStatus.succeeded: 'succeeded',
  JobStatus.partiallySucceeded: 'partially_succeeded',
  JobStatus.failed: 'failed',
  JobStatus.cancelled: 'cancelled',
};
