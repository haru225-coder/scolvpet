// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'care_task_create_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CareTaskCreateRequestCWProxy {
  CareTaskCreateRequest taskType(String taskType);

  CareTaskCreateRequest targetType(String targetType);

  CareTaskCreateRequest targetId(String targetId);

  CareTaskCreateRequest title(String? title);

  CareTaskCreateRequest scheduledAt(DateTime scheduledAt);

  CareTaskCreateRequest priority(TaskPriority priority);

  CareTaskCreateRequest subjectIds(List<String>? subjectIds);

  CareTaskCreateRequest notes(String? notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CareTaskCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CareTaskCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CareTaskCreateRequest call({
    String taskType,
    String targetType,
    String targetId,
    String? title,
    DateTime scheduledAt,
    TaskPriority priority,
    List<String>? subjectIds,
    String? notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCareTaskCreateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCareTaskCreateRequest.copyWith.fieldName(...)`
class _$CareTaskCreateRequestCWProxyImpl
    implements _$CareTaskCreateRequestCWProxy {
  const _$CareTaskCreateRequestCWProxyImpl(this._value);

  final CareTaskCreateRequest _value;

  @override
  CareTaskCreateRequest taskType(String taskType) => this(taskType: taskType);

  @override
  CareTaskCreateRequest targetType(String targetType) =>
      this(targetType: targetType);

  @override
  CareTaskCreateRequest targetId(String targetId) => this(targetId: targetId);

  @override
  CareTaskCreateRequest title(String? title) => this(title: title);

  @override
  CareTaskCreateRequest scheduledAt(DateTime scheduledAt) =>
      this(scheduledAt: scheduledAt);

  @override
  CareTaskCreateRequest priority(TaskPriority priority) =>
      this(priority: priority);

  @override
  CareTaskCreateRequest subjectIds(List<String>? subjectIds) =>
      this(subjectIds: subjectIds);

  @override
  CareTaskCreateRequest notes(String? notes) => this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CareTaskCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CareTaskCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CareTaskCreateRequest call({
    Object? taskType = const $CopyWithPlaceholder(),
    Object? targetType = const $CopyWithPlaceholder(),
    Object? targetId = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? scheduledAt = const $CopyWithPlaceholder(),
    Object? priority = const $CopyWithPlaceholder(),
    Object? subjectIds = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return CareTaskCreateRequest(
      taskType: taskType == const $CopyWithPlaceholder()
          ? _value.taskType
          // ignore: cast_nullable_to_non_nullable
          : taskType as String,
      targetType: targetType == const $CopyWithPlaceholder()
          ? _value.targetType
          // ignore: cast_nullable_to_non_nullable
          : targetType as String,
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
      subjectIds: subjectIds == const $CopyWithPlaceholder()
          ? _value.subjectIds
          // ignore: cast_nullable_to_non_nullable
          : subjectIds as List<String>?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
    );
  }
}

extension $CareTaskCreateRequestCopyWith on CareTaskCreateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCareTaskCreateRequest.copyWith(...)` or like so:`instanceOfCareTaskCreateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CareTaskCreateRequestCWProxy get copyWith =>
      _$CareTaskCreateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CareTaskCreateRequest _$CareTaskCreateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CareTaskCreateRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'task_type',
        'target_type',
        'target_id',
        'scheduled_at',
        'priority',
      ],
    );
    final val = CareTaskCreateRequest(
      taskType: $checkedConvert('task_type', (v) => v as String),
      targetType: $checkedConvert('target_type', (v) => v as String),
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
      subjectIds: $checkedConvert(
        'subject_ids',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      notes: $checkedConvert('notes', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'taskType': 'task_type',
    'targetType': 'target_type',
    'targetId': 'target_id',
    'scheduledAt': 'scheduled_at',
    'subjectIds': 'subject_ids',
  },
);

Map<String, dynamic> _$CareTaskCreateRequestToJson(
  CareTaskCreateRequest instance,
) => <String, dynamic>{
  'task_type': instance.taskType,
  'target_type': instance.targetType,
  'target_id': instance.targetId,
  'title': ?instance.title,
  'scheduled_at': instance.scheduledAt.toIso8601String(),
  'priority': _$TaskPriorityEnumMap[instance.priority]!,
  'subject_ids': ?instance.subjectIds,
  'notes': ?instance.notes,
};

const _$TaskPriorityEnumMap = {
  TaskPriority.low: 'low',
  TaskPriority.normal: 'normal',
  TaskPriority.high: 'high',
  TaskPriority.urgent: 'urgent',
  TaskPriority.critical: 'critical',
};
