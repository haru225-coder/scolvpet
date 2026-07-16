// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_job.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportJobCWProxy {
  ImportJob id(String id);

  ImportJob jobType(ImportJobJobTypeEnum jobType);

  ImportJob status(JobStatus status);

  ImportJob progressPercent(int progressPercent);

  ImportJob currentStep(String? currentStep);

  ImportJob error(ErrorObject? error);

  ImportJob retryable(bool retryable);

  ImportJob attempt(int? attempt);

  ImportJob result(Map<String, Object>? result);

  ImportJob expiresAt(DateTime? expiresAt);

  ImportJob version(int version);

  ImportJob createdAt(DateTime createdAt);

  ImportJob updatedAt(DateTime updatedAt);

  ImportJob templateType(ImportTemplateType templateType);

  ImportJob phase(ImportJobPhaseEnum phase);

  ImportJob sourceEncoding(String? sourceEncoding);

  ImportJob sourceColumns(List<String> sourceColumns);

  ImportJob mapping(Map<String, String> mapping);

  ImportJob preflightVersion(int? preflightVersion);

  ImportJob totalRows(int totalRows);

  ImportJob validRows(int validRows);

  ImportJob warningRows(int warningRows);

  ImportJob invalidRows(int invalidRows);

  ImportJob importedRows(int importedRows);

  ImportJob historicalLittersToCreate(int historicalLittersToCreate);

  ImportJob relationshipAssertionsToCreate(int relationshipAssertionsToCreate);

  ImportJob blockingIssueCount(int blockingIssueCount);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportJob(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportJob(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportJob call({
    String id,
    ImportJobJobTypeEnum jobType,
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
    ImportTemplateType templateType,
    ImportJobPhaseEnum phase,
    String? sourceEncoding,
    List<String> sourceColumns,
    Map<String, String> mapping,
    int? preflightVersion,
    int totalRows,
    int validRows,
    int warningRows,
    int invalidRows,
    int importedRows,
    int historicalLittersToCreate,
    int relationshipAssertionsToCreate,
    int blockingIssueCount,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportJob.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportJob.copyWith.fieldName(...)`
class _$ImportJobCWProxyImpl implements _$ImportJobCWProxy {
  const _$ImportJobCWProxyImpl(this._value);

  final ImportJob _value;

  @override
  ImportJob id(String id) => this(id: id);

  @override
  ImportJob jobType(ImportJobJobTypeEnum jobType) => this(jobType: jobType);

  @override
  ImportJob status(JobStatus status) => this(status: status);

  @override
  ImportJob progressPercent(int progressPercent) =>
      this(progressPercent: progressPercent);

  @override
  ImportJob currentStep(String? currentStep) => this(currentStep: currentStep);

  @override
  ImportJob error(ErrorObject? error) => this(error: error);

  @override
  ImportJob retryable(bool retryable) => this(retryable: retryable);

  @override
  ImportJob attempt(int? attempt) => this(attempt: attempt);

  @override
  ImportJob result(Map<String, Object>? result) => this(result: result);

  @override
  ImportJob expiresAt(DateTime? expiresAt) => this(expiresAt: expiresAt);

  @override
  ImportJob version(int version) => this(version: version);

  @override
  ImportJob createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  ImportJob updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  ImportJob templateType(ImportTemplateType templateType) =>
      this(templateType: templateType);

  @override
  ImportJob phase(ImportJobPhaseEnum phase) => this(phase: phase);

  @override
  ImportJob sourceEncoding(String? sourceEncoding) =>
      this(sourceEncoding: sourceEncoding);

  @override
  ImportJob sourceColumns(List<String> sourceColumns) =>
      this(sourceColumns: sourceColumns);

  @override
  ImportJob mapping(Map<String, String> mapping) => this(mapping: mapping);

  @override
  ImportJob preflightVersion(int? preflightVersion) =>
      this(preflightVersion: preflightVersion);

  @override
  ImportJob totalRows(int totalRows) => this(totalRows: totalRows);

  @override
  ImportJob validRows(int validRows) => this(validRows: validRows);

  @override
  ImportJob warningRows(int warningRows) => this(warningRows: warningRows);

  @override
  ImportJob invalidRows(int invalidRows) => this(invalidRows: invalidRows);

  @override
  ImportJob importedRows(int importedRows) => this(importedRows: importedRows);

  @override
  ImportJob historicalLittersToCreate(int historicalLittersToCreate) =>
      this(historicalLittersToCreate: historicalLittersToCreate);

  @override
  ImportJob relationshipAssertionsToCreate(
    int relationshipAssertionsToCreate,
  ) => this(relationshipAssertionsToCreate: relationshipAssertionsToCreate);

  @override
  ImportJob blockingIssueCount(int blockingIssueCount) =>
      this(blockingIssueCount: blockingIssueCount);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportJob(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportJob(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportJob call({
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
    Object? templateType = const $CopyWithPlaceholder(),
    Object? phase = const $CopyWithPlaceholder(),
    Object? sourceEncoding = const $CopyWithPlaceholder(),
    Object? sourceColumns = const $CopyWithPlaceholder(),
    Object? mapping = const $CopyWithPlaceholder(),
    Object? preflightVersion = const $CopyWithPlaceholder(),
    Object? totalRows = const $CopyWithPlaceholder(),
    Object? validRows = const $CopyWithPlaceholder(),
    Object? warningRows = const $CopyWithPlaceholder(),
    Object? invalidRows = const $CopyWithPlaceholder(),
    Object? importedRows = const $CopyWithPlaceholder(),
    Object? historicalLittersToCreate = const $CopyWithPlaceholder(),
    Object? relationshipAssertionsToCreate = const $CopyWithPlaceholder(),
    Object? blockingIssueCount = const $CopyWithPlaceholder(),
  }) {
    return ImportJob(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      jobType: jobType == const $CopyWithPlaceholder()
          ? _value.jobType
          // ignore: cast_nullable_to_non_nullable
          : jobType as ImportJobJobTypeEnum,
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
      templateType: templateType == const $CopyWithPlaceholder()
          ? _value.templateType
          // ignore: cast_nullable_to_non_nullable
          : templateType as ImportTemplateType,
      phase: phase == const $CopyWithPlaceholder()
          ? _value.phase
          // ignore: cast_nullable_to_non_nullable
          : phase as ImportJobPhaseEnum,
      sourceEncoding: sourceEncoding == const $CopyWithPlaceholder()
          ? _value.sourceEncoding
          // ignore: cast_nullable_to_non_nullable
          : sourceEncoding as String?,
      sourceColumns: sourceColumns == const $CopyWithPlaceholder()
          ? _value.sourceColumns
          // ignore: cast_nullable_to_non_nullable
          : sourceColumns as List<String>,
      mapping: mapping == const $CopyWithPlaceholder()
          ? _value.mapping
          // ignore: cast_nullable_to_non_nullable
          : mapping as Map<String, String>,
      preflightVersion: preflightVersion == const $CopyWithPlaceholder()
          ? _value.preflightVersion
          // ignore: cast_nullable_to_non_nullable
          : preflightVersion as int?,
      totalRows: totalRows == const $CopyWithPlaceholder()
          ? _value.totalRows
          // ignore: cast_nullable_to_non_nullable
          : totalRows as int,
      validRows: validRows == const $CopyWithPlaceholder()
          ? _value.validRows
          // ignore: cast_nullable_to_non_nullable
          : validRows as int,
      warningRows: warningRows == const $CopyWithPlaceholder()
          ? _value.warningRows
          // ignore: cast_nullable_to_non_nullable
          : warningRows as int,
      invalidRows: invalidRows == const $CopyWithPlaceholder()
          ? _value.invalidRows
          // ignore: cast_nullable_to_non_nullable
          : invalidRows as int,
      importedRows: importedRows == const $CopyWithPlaceholder()
          ? _value.importedRows
          // ignore: cast_nullable_to_non_nullable
          : importedRows as int,
      historicalLittersToCreate:
          historicalLittersToCreate == const $CopyWithPlaceholder()
          ? _value.historicalLittersToCreate
          // ignore: cast_nullable_to_non_nullable
          : historicalLittersToCreate as int,
      relationshipAssertionsToCreate:
          relationshipAssertionsToCreate == const $CopyWithPlaceholder()
          ? _value.relationshipAssertionsToCreate
          // ignore: cast_nullable_to_non_nullable
          : relationshipAssertionsToCreate as int,
      blockingIssueCount: blockingIssueCount == const $CopyWithPlaceholder()
          ? _value.blockingIssueCount
          // ignore: cast_nullable_to_non_nullable
          : blockingIssueCount as int,
    );
  }
}

extension $ImportJobCopyWith on ImportJob {
  /// Returns a callable class that can be used as follows: `instanceOfImportJob.copyWith(...)` or like so:`instanceOfImportJob.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportJobCWProxy get copyWith => _$ImportJobCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportJob _$ImportJobFromJson(Map<String, dynamic> json) => $checkedCreate(
  'ImportJob',
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
        'template_type',
        'phase',
        'source_columns',
        'mapping',
        'total_rows',
        'valid_rows',
        'warning_rows',
        'invalid_rows',
        'imported_rows',
        'historical_litters_to_create',
        'relationship_assertions_to_create',
        'blocking_issue_count',
      ],
    );
    final val = ImportJob(
      id: $checkedConvert('id', (v) => v as String),
      jobType: $checkedConvert(
        'job_type',
        (v) => $enumDecode(_$ImportJobJobTypeEnumEnumMap, v),
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
      templateType: $checkedConvert(
        'template_type',
        (v) => $enumDecode(_$ImportTemplateTypeEnumMap, v),
      ),
      phase: $checkedConvert(
        'phase',
        (v) => $enumDecode(_$ImportJobPhaseEnumEnumMap, v),
      ),
      sourceEncoding: $checkedConvert('source_encoding', (v) => v as String?),
      sourceColumns: $checkedConvert(
        'source_columns',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      mapping: $checkedConvert(
        'mapping',
        (v) => Map<String, String>.from(v as Map),
      ),
      preflightVersion: $checkedConvert(
        'preflight_version',
        (v) => (v as num?)?.toInt(),
      ),
      totalRows: $checkedConvert('total_rows', (v) => (v as num).toInt()),
      validRows: $checkedConvert('valid_rows', (v) => (v as num).toInt()),
      warningRows: $checkedConvert('warning_rows', (v) => (v as num).toInt()),
      invalidRows: $checkedConvert('invalid_rows', (v) => (v as num).toInt()),
      importedRows: $checkedConvert('imported_rows', (v) => (v as num).toInt()),
      historicalLittersToCreate: $checkedConvert(
        'historical_litters_to_create',
        (v) => (v as num).toInt(),
      ),
      relationshipAssertionsToCreate: $checkedConvert(
        'relationship_assertions_to_create',
        (v) => (v as num).toInt(),
      ),
      blockingIssueCount: $checkedConvert(
        'blocking_issue_count',
        (v) => (v as num).toInt(),
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
    'templateType': 'template_type',
    'sourceEncoding': 'source_encoding',
    'sourceColumns': 'source_columns',
    'preflightVersion': 'preflight_version',
    'totalRows': 'total_rows',
    'validRows': 'valid_rows',
    'warningRows': 'warning_rows',
    'invalidRows': 'invalid_rows',
    'importedRows': 'imported_rows',
    'historicalLittersToCreate': 'historical_litters_to_create',
    'relationshipAssertionsToCreate': 'relationship_assertions_to_create',
    'blockingIssueCount': 'blocking_issue_count',
  },
);

Map<String, dynamic> _$ImportJobToJson(ImportJob instance) => <String, dynamic>{
  'id': instance.id,
  'job_type': _$ImportJobJobTypeEnumEnumMap[instance.jobType]!,
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
  'template_type': _$ImportTemplateTypeEnumMap[instance.templateType]!,
  'phase': _$ImportJobPhaseEnumEnumMap[instance.phase]!,
  'source_encoding': ?instance.sourceEncoding,
  'source_columns': instance.sourceColumns,
  'mapping': instance.mapping,
  'preflight_version': ?instance.preflightVersion,
  'total_rows': instance.totalRows,
  'valid_rows': instance.validRows,
  'warning_rows': instance.warningRows,
  'invalid_rows': instance.invalidRows,
  'imported_rows': instance.importedRows,
  'historical_litters_to_create': instance.historicalLittersToCreate,
  'relationship_assertions_to_create': instance.relationshipAssertionsToCreate,
  'blocking_issue_count': instance.blockingIssueCount,
};

const _$ImportJobJobTypeEnumEnumMap = {
  ImportJobJobTypeEnum.import_: 'import',
  ImportJobJobTypeEnum.export_: 'export',
  ImportJobJobTypeEnum.backup: 'backup',
  ImportJobJobTypeEnum.mediaDerivative: 'media_derivative',
  ImportJobJobTypeEnum.videoTranscode: 'video_transcode',
  ImportJobJobTypeEnum.birthCard: 'birth_card',
};

const _$JobStatusEnumMap = {
  JobStatus.queued: 'queued',
  JobStatus.running: 'running',
  JobStatus.succeeded: 'succeeded',
  JobStatus.failed: 'failed',
  JobStatus.cancelled: 'cancelled',
};

const _$ImportTemplateTypeEnumMap = {
  ImportTemplateType.hamster: 'hamster',
  ImportTemplateType.enclosure: 'enclosure',
  ImportTemplateType.weight: 'weight',
};

const _$ImportJobPhaseEnumEnumMap = {
  ImportJobPhaseEnum.detecting: 'detecting',
  ImportJobPhaseEnum.mapping: 'mapping',
  ImportJobPhaseEnum.preflight: 'preflight',
  ImportJobPhaseEnum.readyToCommit: 'ready_to_commit',
  ImportJobPhaseEnum.importing: 'importing',
  ImportJobPhaseEnum.completed: 'completed',
};
