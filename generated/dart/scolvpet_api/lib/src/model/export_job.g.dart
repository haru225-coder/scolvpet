// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_job.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExportJobCWProxy {
  ExportJob id(String id);

  ExportJob jobType(ExportJobJobTypeEnum jobType);

  ExportJob status(JobStatus status);

  ExportJob progressPercent(int progressPercent);

  ExportJob currentStep(String? currentStep);

  ExportJob error(ErrorObject? error);

  ExportJob retryable(bool retryable);

  ExportJob attempt(int? attempt);

  ExportJob result(Map<String, Object>? result);

  ExportJob expiresAt(DateTime? expiresAt);

  ExportJob version(int version);

  ExportJob createdAt(DateTime createdAt);

  ExportJob updatedAt(DateTime updatedAt);

  ExportJob datasets(Set<ExportJobDatasetsEnum> datasets);

  ExportJob exportFormat(ExportJobExportFormatEnum exportFormat);

  ExportJob snapshotAt(DateTime snapshotAt);

  ExportJob fileName(String? fileName);

  ExportJob sizeBytes(int? sizeBytes);

  ExportJob sha256(String? sha256);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExportJob(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExportJob(...).copyWith(id: 12, name: "My name")
  /// ````
  ExportJob call({
    String id,
    ExportJobJobTypeEnum jobType,
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
    Set<ExportJobDatasetsEnum> datasets,
    ExportJobExportFormatEnum exportFormat,
    DateTime snapshotAt,
    String? fileName,
    int? sizeBytes,
    String? sha256,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExportJob.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExportJob.copyWith.fieldName(...)`
class _$ExportJobCWProxyImpl implements _$ExportJobCWProxy {
  const _$ExportJobCWProxyImpl(this._value);

  final ExportJob _value;

  @override
  ExportJob id(String id) => this(id: id);

  @override
  ExportJob jobType(ExportJobJobTypeEnum jobType) => this(jobType: jobType);

  @override
  ExportJob status(JobStatus status) => this(status: status);

  @override
  ExportJob progressPercent(int progressPercent) =>
      this(progressPercent: progressPercent);

  @override
  ExportJob currentStep(String? currentStep) => this(currentStep: currentStep);

  @override
  ExportJob error(ErrorObject? error) => this(error: error);

  @override
  ExportJob retryable(bool retryable) => this(retryable: retryable);

  @override
  ExportJob attempt(int? attempt) => this(attempt: attempt);

  @override
  ExportJob result(Map<String, Object>? result) => this(result: result);

  @override
  ExportJob expiresAt(DateTime? expiresAt) => this(expiresAt: expiresAt);

  @override
  ExportJob version(int version) => this(version: version);

  @override
  ExportJob createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  ExportJob updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  ExportJob datasets(Set<ExportJobDatasetsEnum> datasets) =>
      this(datasets: datasets);

  @override
  ExportJob exportFormat(ExportJobExportFormatEnum exportFormat) =>
      this(exportFormat: exportFormat);

  @override
  ExportJob snapshotAt(DateTime snapshotAt) => this(snapshotAt: snapshotAt);

  @override
  ExportJob fileName(String? fileName) => this(fileName: fileName);

  @override
  ExportJob sizeBytes(int? sizeBytes) => this(sizeBytes: sizeBytes);

  @override
  ExportJob sha256(String? sha256) => this(sha256: sha256);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExportJob(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExportJob(...).copyWith(id: 12, name: "My name")
  /// ````
  ExportJob call({
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
    Object? datasets = const $CopyWithPlaceholder(),
    Object? exportFormat = const $CopyWithPlaceholder(),
    Object? snapshotAt = const $CopyWithPlaceholder(),
    Object? fileName = const $CopyWithPlaceholder(),
    Object? sizeBytes = const $CopyWithPlaceholder(),
    Object? sha256 = const $CopyWithPlaceholder(),
  }) {
    return ExportJob(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      jobType: jobType == const $CopyWithPlaceholder()
          ? _value.jobType
          // ignore: cast_nullable_to_non_nullable
          : jobType as ExportJobJobTypeEnum,
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
      datasets: datasets == const $CopyWithPlaceholder()
          ? _value.datasets
          // ignore: cast_nullable_to_non_nullable
          : datasets as Set<ExportJobDatasetsEnum>,
      exportFormat: exportFormat == const $CopyWithPlaceholder()
          ? _value.exportFormat
          // ignore: cast_nullable_to_non_nullable
          : exportFormat as ExportJobExportFormatEnum,
      snapshotAt: snapshotAt == const $CopyWithPlaceholder()
          ? _value.snapshotAt
          // ignore: cast_nullable_to_non_nullable
          : snapshotAt as DateTime,
      fileName: fileName == const $CopyWithPlaceholder()
          ? _value.fileName
          // ignore: cast_nullable_to_non_nullable
          : fileName as String?,
      sizeBytes: sizeBytes == const $CopyWithPlaceholder()
          ? _value.sizeBytes
          // ignore: cast_nullable_to_non_nullable
          : sizeBytes as int?,
      sha256: sha256 == const $CopyWithPlaceholder()
          ? _value.sha256
          // ignore: cast_nullable_to_non_nullable
          : sha256 as String?,
    );
  }
}

extension $ExportJobCopyWith on ExportJob {
  /// Returns a callable class that can be used as follows: `instanceOfExportJob.copyWith(...)` or like so:`instanceOfExportJob.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExportJobCWProxy get copyWith => _$ExportJobCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExportJob _$ExportJobFromJson(Map<String, dynamic> json) => $checkedCreate(
  'ExportJob',
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
        'datasets',
        'export_format',
        'snapshot_at',
      ],
    );
    final val = ExportJob(
      id: $checkedConvert('id', (v) => v as String),
      jobType: $checkedConvert(
        'job_type',
        (v) => $enumDecode(_$ExportJobJobTypeEnumEnumMap, v),
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
      datasets: $checkedConvert(
        'datasets',
        (v) => (v as List<dynamic>)
            .map((e) => $enumDecode(_$ExportJobDatasetsEnumEnumMap, e))
            .toSet(),
      ),
      exportFormat: $checkedConvert(
        'export_format',
        (v) => $enumDecode(_$ExportJobExportFormatEnumEnumMap, v),
      ),
      snapshotAt: $checkedConvert(
        'snapshot_at',
        (v) => DateTime.parse(v as String),
      ),
      fileName: $checkedConvert('file_name', (v) => v as String?),
      sizeBytes: $checkedConvert('size_bytes', (v) => (v as num?)?.toInt()),
      sha256: $checkedConvert('sha256', (v) => v as String?),
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
    'exportFormat': 'export_format',
    'snapshotAt': 'snapshot_at',
    'fileName': 'file_name',
    'sizeBytes': 'size_bytes',
  },
);

Map<String, dynamic> _$ExportJobToJson(ExportJob instance) => <String, dynamic>{
  'id': instance.id,
  'job_type': _$ExportJobJobTypeEnumEnumMap[instance.jobType]!,
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
  'datasets': instance.datasets
      .map((e) => _$ExportJobDatasetsEnumEnumMap[e]!)
      .toList(),
  'export_format': _$ExportJobExportFormatEnumEnumMap[instance.exportFormat]!,
  'snapshot_at': instance.snapshotAt.toIso8601String(),
  'file_name': ?instance.fileName,
  'size_bytes': ?instance.sizeBytes,
  'sha256': ?instance.sha256,
};

const _$ExportJobJobTypeEnumEnumMap = {
  ExportJobJobTypeEnum.import_: 'import',
  ExportJobJobTypeEnum.export_: 'export',
  ExportJobJobTypeEnum.backup: 'backup',
  ExportJobJobTypeEnum.mediaDerivative: 'media_derivative',
  ExportJobJobTypeEnum.videoTranscode: 'video_transcode',
  ExportJobJobTypeEnum.birthCard: 'birth_card',
};

const _$JobStatusEnumMap = {
  JobStatus.queued: 'queued',
  JobStatus.running: 'running',
  JobStatus.succeeded: 'succeeded',
  JobStatus.partiallySucceeded: 'partially_succeeded',
  JobStatus.failed: 'failed',
  JobStatus.cancelled: 'cancelled',
};

const _$ExportJobDatasetsEnumEnumMap = {
  ExportJobDatasetsEnum.hamsters: 'hamsters',
  ExportJobDatasetsEnum.enclosures: 'enclosures',
  ExportJobDatasetsEnum.breeding: 'breeding',
  ExportJobDatasetsEnum.litters: 'litters',
  ExportJobDatasetsEnum.weights: 'weights',
  ExportJobDatasetsEnum.health: 'health',
  ExportJobDatasetsEnum.pedigree: 'pedigree',
};

const _$ExportJobExportFormatEnumEnumMap = {
  ExportJobExportFormatEnum.csvZip: 'csv_zip',
  ExportJobExportFormatEnum.json: 'json',
};
