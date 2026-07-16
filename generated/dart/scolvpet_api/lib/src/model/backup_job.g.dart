// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_job.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BackupJobCWProxy {
  BackupJob id(String id);

  BackupJob jobType(BackupJobJobTypeEnum jobType);

  BackupJob status(JobStatus status);

  BackupJob progressPercent(int progressPercent);

  BackupJob currentStep(String? currentStep);

  BackupJob error(ErrorObject? error);

  BackupJob retryable(bool retryable);

  BackupJob attempt(int? attempt);

  BackupJob result(Map<String, Object>? result);

  BackupJob expiresAt(DateTime? expiresAt);

  BackupJob version(int version);

  BackupJob createdAt(DateTime createdAt);

  BackupJob updatedAt(DateTime updatedAt);

  BackupJob includesStructuredData(
    BackupJobIncludesStructuredDataEnum includesStructuredData,
  );

  BackupJob includesMediaManifest(
    BackupJobIncludesMediaManifestEnum includesMediaManifest,
  );

  BackupJob includesChecksums(BackupJobIncludesChecksumsEnum includesChecksums);

  BackupJob sizeBytes(int? sizeBytes);

  BackupJob sha256(String? sha256);

  BackupJob integrityStatus(BackupJobIntegrityStatusEnum integrityStatus);

  BackupJob restoreReadiness(BackupJobRestoreReadinessEnum restoreReadiness);

  BackupJob verifiedAt(DateTime? verifiedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BackupJob(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BackupJob(...).copyWith(id: 12, name: "My name")
  /// ````
  BackupJob call({
    String id,
    BackupJobJobTypeEnum jobType,
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
    BackupJobIncludesStructuredDataEnum includesStructuredData,
    BackupJobIncludesMediaManifestEnum includesMediaManifest,
    BackupJobIncludesChecksumsEnum includesChecksums,
    int? sizeBytes,
    String? sha256,
    BackupJobIntegrityStatusEnum integrityStatus,
    BackupJobRestoreReadinessEnum restoreReadiness,
    DateTime? verifiedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBackupJob.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBackupJob.copyWith.fieldName(...)`
class _$BackupJobCWProxyImpl implements _$BackupJobCWProxy {
  const _$BackupJobCWProxyImpl(this._value);

  final BackupJob _value;

  @override
  BackupJob id(String id) => this(id: id);

  @override
  BackupJob jobType(BackupJobJobTypeEnum jobType) => this(jobType: jobType);

  @override
  BackupJob status(JobStatus status) => this(status: status);

  @override
  BackupJob progressPercent(int progressPercent) =>
      this(progressPercent: progressPercent);

  @override
  BackupJob currentStep(String? currentStep) => this(currentStep: currentStep);

  @override
  BackupJob error(ErrorObject? error) => this(error: error);

  @override
  BackupJob retryable(bool retryable) => this(retryable: retryable);

  @override
  BackupJob attempt(int? attempt) => this(attempt: attempt);

  @override
  BackupJob result(Map<String, Object>? result) => this(result: result);

  @override
  BackupJob expiresAt(DateTime? expiresAt) => this(expiresAt: expiresAt);

  @override
  BackupJob version(int version) => this(version: version);

  @override
  BackupJob createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  BackupJob updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  BackupJob includesStructuredData(
    BackupJobIncludesStructuredDataEnum includesStructuredData,
  ) => this(includesStructuredData: includesStructuredData);

  @override
  BackupJob includesMediaManifest(
    BackupJobIncludesMediaManifestEnum includesMediaManifest,
  ) => this(includesMediaManifest: includesMediaManifest);

  @override
  BackupJob includesChecksums(
    BackupJobIncludesChecksumsEnum includesChecksums,
  ) => this(includesChecksums: includesChecksums);

  @override
  BackupJob sizeBytes(int? sizeBytes) => this(sizeBytes: sizeBytes);

  @override
  BackupJob sha256(String? sha256) => this(sha256: sha256);

  @override
  BackupJob integrityStatus(BackupJobIntegrityStatusEnum integrityStatus) =>
      this(integrityStatus: integrityStatus);

  @override
  BackupJob restoreReadiness(BackupJobRestoreReadinessEnum restoreReadiness) =>
      this(restoreReadiness: restoreReadiness);

  @override
  BackupJob verifiedAt(DateTime? verifiedAt) => this(verifiedAt: verifiedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BackupJob(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BackupJob(...).copyWith(id: 12, name: "My name")
  /// ````
  BackupJob call({
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
    Object? includesStructuredData = const $CopyWithPlaceholder(),
    Object? includesMediaManifest = const $CopyWithPlaceholder(),
    Object? includesChecksums = const $CopyWithPlaceholder(),
    Object? sizeBytes = const $CopyWithPlaceholder(),
    Object? sha256 = const $CopyWithPlaceholder(),
    Object? integrityStatus = const $CopyWithPlaceholder(),
    Object? restoreReadiness = const $CopyWithPlaceholder(),
    Object? verifiedAt = const $CopyWithPlaceholder(),
  }) {
    return BackupJob(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      jobType: jobType == const $CopyWithPlaceholder()
          ? _value.jobType
          // ignore: cast_nullable_to_non_nullable
          : jobType as BackupJobJobTypeEnum,
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
      includesStructuredData:
          includesStructuredData == const $CopyWithPlaceholder()
          ? _value.includesStructuredData
          // ignore: cast_nullable_to_non_nullable
          : includesStructuredData as BackupJobIncludesStructuredDataEnum,
      includesMediaManifest:
          includesMediaManifest == const $CopyWithPlaceholder()
          ? _value.includesMediaManifest
          // ignore: cast_nullable_to_non_nullable
          : includesMediaManifest as BackupJobIncludesMediaManifestEnum,
      includesChecksums: includesChecksums == const $CopyWithPlaceholder()
          ? _value.includesChecksums
          // ignore: cast_nullable_to_non_nullable
          : includesChecksums as BackupJobIncludesChecksumsEnum,
      sizeBytes: sizeBytes == const $CopyWithPlaceholder()
          ? _value.sizeBytes
          // ignore: cast_nullable_to_non_nullable
          : sizeBytes as int?,
      sha256: sha256 == const $CopyWithPlaceholder()
          ? _value.sha256
          // ignore: cast_nullable_to_non_nullable
          : sha256 as String?,
      integrityStatus: integrityStatus == const $CopyWithPlaceholder()
          ? _value.integrityStatus
          // ignore: cast_nullable_to_non_nullable
          : integrityStatus as BackupJobIntegrityStatusEnum,
      restoreReadiness: restoreReadiness == const $CopyWithPlaceholder()
          ? _value.restoreReadiness
          // ignore: cast_nullable_to_non_nullable
          : restoreReadiness as BackupJobRestoreReadinessEnum,
      verifiedAt: verifiedAt == const $CopyWithPlaceholder()
          ? _value.verifiedAt
          // ignore: cast_nullable_to_non_nullable
          : verifiedAt as DateTime?,
    );
  }
}

extension $BackupJobCopyWith on BackupJob {
  /// Returns a callable class that can be used as follows: `instanceOfBackupJob.copyWith(...)` or like so:`instanceOfBackupJob.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BackupJobCWProxy get copyWith => _$BackupJobCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BackupJob _$BackupJobFromJson(Map<String, dynamic> json) => $checkedCreate(
  'BackupJob',
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
        'includes_structured_data',
        'includes_media_manifest',
        'includes_checksums',
        'integrity_status',
        'restore_readiness',
      ],
    );
    final val = BackupJob(
      id: $checkedConvert('id', (v) => v as String),
      jobType: $checkedConvert(
        'job_type',
        (v) => $enumDecode(_$BackupJobJobTypeEnumEnumMap, v),
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
      includesStructuredData: $checkedConvert(
        'includes_structured_data',
        (v) => $enumDecode(_$BackupJobIncludesStructuredDataEnumEnumMap, v),
      ),
      includesMediaManifest: $checkedConvert(
        'includes_media_manifest',
        (v) => $enumDecode(_$BackupJobIncludesMediaManifestEnumEnumMap, v),
      ),
      includesChecksums: $checkedConvert(
        'includes_checksums',
        (v) => $enumDecode(_$BackupJobIncludesChecksumsEnumEnumMap, v),
      ),
      sizeBytes: $checkedConvert('size_bytes', (v) => (v as num?)?.toInt()),
      sha256: $checkedConvert('sha256', (v) => v as String?),
      integrityStatus: $checkedConvert(
        'integrity_status',
        (v) => $enumDecode(_$BackupJobIntegrityStatusEnumEnumMap, v),
      ),
      restoreReadiness: $checkedConvert(
        'restore_readiness',
        (v) => $enumDecode(_$BackupJobRestoreReadinessEnumEnumMap, v),
      ),
      verifiedAt: $checkedConvert(
        'verified_at',
        (v) => v == null ? null : DateTime.parse(v as String),
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
    'includesStructuredData': 'includes_structured_data',
    'includesMediaManifest': 'includes_media_manifest',
    'includesChecksums': 'includes_checksums',
    'sizeBytes': 'size_bytes',
    'integrityStatus': 'integrity_status',
    'restoreReadiness': 'restore_readiness',
    'verifiedAt': 'verified_at',
  },
);

Map<String, dynamic> _$BackupJobToJson(BackupJob instance) => <String, dynamic>{
  'id': instance.id,
  'job_type': _$BackupJobJobTypeEnumEnumMap[instance.jobType]!,
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
  'includes_structured_data':
      _$BackupJobIncludesStructuredDataEnumEnumMap[instance
          .includesStructuredData]!,
  'includes_media_manifest':
      _$BackupJobIncludesMediaManifestEnumEnumMap[instance
          .includesMediaManifest]!,
  'includes_checksums':
      _$BackupJobIncludesChecksumsEnumEnumMap[instance.includesChecksums]!,
  'size_bytes': ?instance.sizeBytes,
  'sha256': ?instance.sha256,
  'integrity_status':
      _$BackupJobIntegrityStatusEnumEnumMap[instance.integrityStatus]!,
  'restore_readiness':
      _$BackupJobRestoreReadinessEnumEnumMap[instance.restoreReadiness]!,
  'verified_at': ?instance.verifiedAt?.toIso8601String(),
};

const _$BackupJobJobTypeEnumEnumMap = {
  BackupJobJobTypeEnum.import_: 'import',
  BackupJobJobTypeEnum.export_: 'export',
  BackupJobJobTypeEnum.backup: 'backup',
  BackupJobJobTypeEnum.mediaDerivative: 'media_derivative',
  BackupJobJobTypeEnum.videoTranscode: 'video_transcode',
  BackupJobJobTypeEnum.birthCard: 'birth_card',
};

const _$JobStatusEnumMap = {
  JobStatus.queued: 'queued',
  JobStatus.running: 'running',
  JobStatus.succeeded: 'succeeded',
  JobStatus.partiallySucceeded: 'partially_succeeded',
  JobStatus.failed: 'failed',
  JobStatus.cancelled: 'cancelled',
};

const _$BackupJobIncludesStructuredDataEnumEnumMap = {
  BackupJobIncludesStructuredDataEnum.true_: 'true',
};

const _$BackupJobIncludesMediaManifestEnumEnumMap = {
  BackupJobIncludesMediaManifestEnum.true_: 'true',
};

const _$BackupJobIncludesChecksumsEnumEnumMap = {
  BackupJobIncludesChecksumsEnum.true_: 'true',
};

const _$BackupJobIntegrityStatusEnumEnumMap = {
  BackupJobIntegrityStatusEnum.pending: 'pending',
  BackupJobIntegrityStatusEnum.verified: 'verified',
  BackupJobIntegrityStatusEnum.failed: 'failed',
};

const _$BackupJobRestoreReadinessEnumEnumMap = {
  BackupJobRestoreReadinessEnum.notReady: 'not_ready',
  BackupJobRestoreReadinessEnum.downloadableRestoreBasis:
      'downloadable_restore_basis',
  BackupJobRestoreReadinessEnum.blocked: 'blocked',
};
