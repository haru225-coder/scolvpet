// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'care_task.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CareTaskCWProxy {
  CareTask id(String id);

  CareTask taskType(CareTaskTaskTypeEnum taskType);

  CareTask targetType(CareTaskTargetTypeEnum targetType);

  CareTask targetId(String targetId);

  CareTask title(String? title);

  CareTask scheduledAt(DateTime scheduledAt);

  CareTask priority(TaskPriority priority);

  CareTask state(TaskState state);

  CareTask subjectIds(List<String>? subjectIds);

  CareTask completedSubjectIds(List<String>? completedSubjectIds);

  CareTask stageTotal(int stageTotal);

  CareTask stageDone(int stageDone);

  CareTask sourceEventId(String? sourceEventId);

  CareTask notes(String? notes);

  CareTask version(int version);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CareTask(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CareTask(...).copyWith(id: 12, name: "My name")
  /// ````
  CareTask call({
    String id,
    CareTaskTaskTypeEnum taskType,
    CareTaskTargetTypeEnum targetType,
    String targetId,
    String? title,
    DateTime scheduledAt,
    TaskPriority priority,
    TaskState state,
    List<String>? subjectIds,
    List<String>? completedSubjectIds,
    int stageTotal,
    int stageDone,
    String? sourceEventId,
    String? notes,
    int version,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCareTask.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCareTask.copyWith.fieldName(...)`
class _$CareTaskCWProxyImpl implements _$CareTaskCWProxy {
  const _$CareTaskCWProxyImpl(this._value);

  final CareTask _value;

  @override
  CareTask id(String id) => this(id: id);

  @override
  CareTask taskType(CareTaskTaskTypeEnum taskType) => this(taskType: taskType);

  @override
  CareTask targetType(CareTaskTargetTypeEnum targetType) =>
      this(targetType: targetType);

  @override
  CareTask targetId(String targetId) => this(targetId: targetId);

  @override
  CareTask title(String? title) => this(title: title);

  @override
  CareTask scheduledAt(DateTime scheduledAt) => this(scheduledAt: scheduledAt);

  @override
  CareTask priority(TaskPriority priority) => this(priority: priority);

  @override
  CareTask state(TaskState state) => this(state: state);

  @override
  CareTask subjectIds(List<String>? subjectIds) => this(subjectIds: subjectIds);

  @override
  CareTask completedSubjectIds(List<String>? completedSubjectIds) =>
      this(completedSubjectIds: completedSubjectIds);

  @override
  CareTask stageTotal(int stageTotal) => this(stageTotal: stageTotal);

  @override
  CareTask stageDone(int stageDone) => this(stageDone: stageDone);

  @override
  CareTask sourceEventId(String? sourceEventId) =>
      this(sourceEventId: sourceEventId);

  @override
  CareTask notes(String? notes) => this(notes: notes);

  @override
  CareTask version(int version) => this(version: version);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CareTask(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CareTask(...).copyWith(id: 12, name: "My name")
  /// ````
  CareTask call({
    Object? id = const $CopyWithPlaceholder(),
    Object? taskType = const $CopyWithPlaceholder(),
    Object? targetType = const $CopyWithPlaceholder(),
    Object? targetId = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? scheduledAt = const $CopyWithPlaceholder(),
    Object? priority = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
    Object? subjectIds = const $CopyWithPlaceholder(),
    Object? completedSubjectIds = const $CopyWithPlaceholder(),
    Object? stageTotal = const $CopyWithPlaceholder(),
    Object? stageDone = const $CopyWithPlaceholder(),
    Object? sourceEventId = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
  }) {
    return CareTask(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      taskType: taskType == const $CopyWithPlaceholder()
          ? _value.taskType
          // ignore: cast_nullable_to_non_nullable
          : taskType as CareTaskTaskTypeEnum,
      targetType: targetType == const $CopyWithPlaceholder()
          ? _value.targetType
          // ignore: cast_nullable_to_non_nullable
          : targetType as CareTaskTargetTypeEnum,
      targetId: targetId == const $CopyWithPlaceholder()
          ? _value.targetId
          // ignore: cast_nullable_to_non_nullable
          : targetId as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      scheduledAt: scheduledAt == const $CopyWithPlaceholder()
          ? _value.scheduledAt
          // ignore: cast_nullable_to_non_nullable
          : scheduledAt as DateTime,
      priority: priority == const $CopyWithPlaceholder()
          ? _value.priority
          // ignore: cast_nullable_to_non_nullable
          : priority as TaskPriority,
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as TaskState,
      subjectIds: subjectIds == const $CopyWithPlaceholder()
          ? _value.subjectIds
          // ignore: cast_nullable_to_non_nullable
          : subjectIds as List<String>?,
      completedSubjectIds: completedSubjectIds == const $CopyWithPlaceholder()
          ? _value.completedSubjectIds
          // ignore: cast_nullable_to_non_nullable
          : completedSubjectIds as List<String>?,
      stageTotal: stageTotal == const $CopyWithPlaceholder()
          ? _value.stageTotal
          // ignore: cast_nullable_to_non_nullable
          : stageTotal as int,
      stageDone: stageDone == const $CopyWithPlaceholder()
          ? _value.stageDone
          // ignore: cast_nullable_to_non_nullable
          : stageDone as int,
      sourceEventId: sourceEventId == const $CopyWithPlaceholder()
          ? _value.sourceEventId
          // ignore: cast_nullable_to_non_nullable
          : sourceEventId as String?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
    );
  }
}

extension $CareTaskCopyWith on CareTask {
  /// Returns a callable class that can be used as follows: `instanceOfCareTask.copyWith(...)` or like so:`instanceOfCareTask.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CareTaskCWProxy get copyWith => _$CareTaskCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CareTask _$CareTaskFromJson(Map<String, dynamic> json) => $checkedCreate(
  'CareTask',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'task_type',
        'target_type',
        'target_id',
        'scheduled_at',
        'priority',
        'state',
        'stage_total',
        'stage_done',
        'version',
      ],
    );
    final val = CareTask(
      id: $checkedConvert('id', (v) => v as String),
      taskType: $checkedConvert(
        'task_type',
        (v) => $enumDecode(_$CareTaskTaskTypeEnumEnumMap, v),
      ),
      targetType: $checkedConvert(
        'target_type',
        (v) => $enumDecode(_$CareTaskTargetTypeEnumEnumMap, v),
      ),
      targetId: $checkedConvert('target_id', (v) => v as String),
      title: $checkedConvert('title', (v) => v as String?),
      scheduledAt: $checkedConvert(
        'scheduled_at',
        (v) => DateTime.parse(v as String),
      ),
      priority: $checkedConvert(
        'priority',
        (v) => $enumDecode(_$TaskPriorityEnumMap, v),
      ),
      state: $checkedConvert(
        'state',
        (v) => $enumDecode(_$TaskStateEnumMap, v),
      ),
      subjectIds: $checkedConvert(
        'subject_ids',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      completedSubjectIds: $checkedConvert(
        'completed_subject_ids',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      stageTotal: $checkedConvert('stage_total', (v) => (v as num).toInt()),
      stageDone: $checkedConvert('stage_done', (v) => (v as num).toInt()),
      sourceEventId: $checkedConvert('source_event_id', (v) => v as String?),
      notes: $checkedConvert('notes', (v) => v as String?),
      version: $checkedConvert('version', (v) => (v as num).toInt()),
    );
    return val;
  },
  fieldKeyMap: const {
    'taskType': 'task_type',
    'targetType': 'target_type',
    'targetId': 'target_id',
    'scheduledAt': 'scheduled_at',
    'subjectIds': 'subject_ids',
    'completedSubjectIds': 'completed_subject_ids',
    'stageTotal': 'stage_total',
    'stageDone': 'stage_done',
    'sourceEventId': 'source_event_id',
  },
);

Map<String, dynamic> _$CareTaskToJson(CareTask instance) => <String, dynamic>{
  'id': instance.id,
  'task_type': _$CareTaskTaskTypeEnumEnumMap[instance.taskType]!,
  'target_type': _$CareTaskTargetTypeEnumEnumMap[instance.targetType]!,
  'target_id': instance.targetId,
  'title': ?instance.title,
  'scheduled_at': instance.scheduledAt.toIso8601String(),
  'priority': _$TaskPriorityEnumMap[instance.priority]!,
  'state': _$TaskStateEnumMap[instance.state]!,
  'subject_ids': ?instance.subjectIds,
  'completed_subject_ids': ?instance.completedSubjectIds,
  'stage_total': instance.stageTotal,
  'stage_done': instance.stageDone,
  'source_event_id': ?instance.sourceEventId,
  'notes': ?instance.notes,
  'version': instance.version,
};

const _$CareTaskTaskTypeEnumEnumMap = {
  CareTaskTaskTypeEnum.pairPrep: 'pair_prep',
  CareTaskTaskTypeEnum.pairingTimeout: 'pairing_timeout',
  CareTaskTaskTypeEnum.separateNow: 'separate_now',
  CareTaskTaskTypeEnum.gestationWindow: 'gestation_window',
  CareTaskTaskTypeEnum.noBirthReview: 'no_birth_review',
  CareTaskTaskTypeEnum.litterObservation: 'litter_observation',
  CareTaskTaskTypeEnum.pupWeightCheck: 'pup_weight_check',
  CareTaskTaskTypeEnum.pupWeightDrop: 'pup_weight_drop',
  CareTaskTaskTypeEnum.weaning: 'weaning',
  CareTaskTaskTypeEnum.sexSeparation: 'sex_separation',
  CareTaskTaskTypeEnum.sexRecheck: 'sex_recheck',
  CareTaskTaskTypeEnum.profileCreation: 'profile_creation',
  CareTaskTaskTypeEnum.enclosureCleaning: 'enclosure_cleaning',
  CareTaskTaskTypeEnum.medication: 'medication',
  CareTaskTaskTypeEnum.custom: 'custom',
};

const _$CareTaskTargetTypeEnumEnumMap = {
  CareTaskTargetTypeEnum.hamster: 'hamster',
  CareTaskTargetTypeEnum.pupIdentity: 'pup_identity',
  CareTaskTargetTypeEnum.litter: 'litter',
  CareTaskTargetTypeEnum.enclosure: 'enclosure',
  CareTaskTargetTypeEnum.breedingPlan: 'breeding_plan',
  CareTaskTargetTypeEnum.media: 'media',
  CareTaskTargetTypeEnum.custom: 'custom',
};

const _$TaskPriorityEnumMap = {
  TaskPriority.low: 'low',
  TaskPriority.normal: 'normal',
  TaskPriority.high: 'high',
  TaskPriority.urgent: 'urgent',
  TaskPriority.critical: 'critical',
};

const _$TaskStateEnumMap = {
  TaskState.pending: 'pending',
  TaskState.inProgress: 'in_progress',
  TaskState.completed: 'completed',
  TaskState.snoozed: 'snoozed',
  TaskState.cancelled: 'cancelled',
  TaskState.superseded: 'superseded',
};
