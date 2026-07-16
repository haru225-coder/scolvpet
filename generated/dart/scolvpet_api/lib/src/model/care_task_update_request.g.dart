// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'care_task_update_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CareTaskUpdateRequestCWProxy {
  CareTaskUpdateRequest title(String? title);

  CareTaskUpdateRequest scheduledAt(DateTime? scheduledAt);

  CareTaskUpdateRequest priority(TaskPriority? priority);

  CareTaskUpdateRequest notes(String? notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CareTaskUpdateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CareTaskUpdateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CareTaskUpdateRequest call({
    String? title,
    DateTime? scheduledAt,
    TaskPriority? priority,
    String? notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCareTaskUpdateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCareTaskUpdateRequest.copyWith.fieldName(...)`
class _$CareTaskUpdateRequestCWProxyImpl
    implements _$CareTaskUpdateRequestCWProxy {
  const _$CareTaskUpdateRequestCWProxyImpl(this._value);

  final CareTaskUpdateRequest _value;

  @override
  CareTaskUpdateRequest title(String? title) => this(title: title);

  @override
  CareTaskUpdateRequest scheduledAt(DateTime? scheduledAt) =>
      this(scheduledAt: scheduledAt);

  @override
  CareTaskUpdateRequest priority(TaskPriority? priority) =>
      this(priority: priority);

  @override
  CareTaskUpdateRequest notes(String? notes) => this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CareTaskUpdateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CareTaskUpdateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CareTaskUpdateRequest call({
    Object? title = const $CopyWithPlaceholder(),
    Object? scheduledAt = const $CopyWithPlaceholder(),
    Object? priority = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return CareTaskUpdateRequest(
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      scheduledAt: scheduledAt == const $CopyWithPlaceholder()
          ? _value.scheduledAt
          // ignore: cast_nullable_to_non_nullable
          : scheduledAt as DateTime?,
      priority: priority == const $CopyWithPlaceholder()
          ? _value.priority
          // ignore: cast_nullable_to_non_nullable
          : priority as TaskPriority?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
    );
  }
}

extension $CareTaskUpdateRequestCopyWith on CareTaskUpdateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCareTaskUpdateRequest.copyWith(...)` or like so:`instanceOfCareTaskUpdateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CareTaskUpdateRequestCWProxy get copyWith =>
      _$CareTaskUpdateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CareTaskUpdateRequest _$CareTaskUpdateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CareTaskUpdateRequest', json, ($checkedConvert) {
  final val = CareTaskUpdateRequest(
    title: $checkedConvert('title', (v) => v as String?),
    scheduledAt: $checkedConvert(
      'scheduled_at',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    priority: $checkedConvert(
      'priority',
      (v) => $enumDecodeNullable(_$TaskPriorityEnumMap, v),
    ),
    notes: $checkedConvert('notes', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {'scheduledAt': 'scheduled_at'});

Map<String, dynamic> _$CareTaskUpdateRequestToJson(
  CareTaskUpdateRequest instance,
) => <String, dynamic>{
  'title': ?instance.title,
  'scheduled_at': ?instance.scheduledAt?.toIso8601String(),
  'priority': ?_$TaskPriorityEnumMap[instance.priority],
  'notes': ?instance.notes,
};

const _$TaskPriorityEnumMap = {
  TaskPriority.low: 'low',
  TaskPriority.normal: 'normal',
  TaskPriority.high: 'high',
  TaskPriority.urgent: 'urgent',
  TaskPriority.critical: 'critical',
};
