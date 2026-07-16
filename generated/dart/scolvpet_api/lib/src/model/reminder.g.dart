// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReminderCWProxy {
  Reminder id(String id);

  Reminder ruleCode(String ruleCode);

  Reminder ruleVersion(String? ruleVersion);

  Reminder baseEventId(String? baseEventId);

  Reminder targetType(String? targetType);

  Reminder targetId(String? targetId);

  Reminder scheduledAt(DateTime scheduledAt);

  Reminder state(ReminderState state);

  Reminder supersededBy(String? supersededBy);

  Reminder channelStatuses(List<ReminderDelivery> channelStatuses);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Reminder(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Reminder(...).copyWith(id: 12, name: "My name")
  /// ````
  Reminder call({
    String id,
    String ruleCode,
    String? ruleVersion,
    String? baseEventId,
    String? targetType,
    String? targetId,
    DateTime scheduledAt,
    ReminderState state,
    String? supersededBy,
    List<ReminderDelivery> channelStatuses,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReminder.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReminder.copyWith.fieldName(...)`
class _$ReminderCWProxyImpl implements _$ReminderCWProxy {
  const _$ReminderCWProxyImpl(this._value);

  final Reminder _value;

  @override
  Reminder id(String id) => this(id: id);

  @override
  Reminder ruleCode(String ruleCode) => this(ruleCode: ruleCode);

  @override
  Reminder ruleVersion(String? ruleVersion) => this(ruleVersion: ruleVersion);

  @override
  Reminder baseEventId(String? baseEventId) => this(baseEventId: baseEventId);

  @override
  Reminder targetType(String? targetType) => this(targetType: targetType);

  @override
  Reminder targetId(String? targetId) => this(targetId: targetId);

  @override
  Reminder scheduledAt(DateTime scheduledAt) => this(scheduledAt: scheduledAt);

  @override
  Reminder state(ReminderState state) => this(state: state);

  @override
  Reminder supersededBy(String? supersededBy) =>
      this(supersededBy: supersededBy);

  @override
  Reminder channelStatuses(List<ReminderDelivery> channelStatuses) =>
      this(channelStatuses: channelStatuses);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Reminder(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Reminder(...).copyWith(id: 12, name: "My name")
  /// ````
  Reminder call({
    Object? id = const $CopyWithPlaceholder(),
    Object? ruleCode = const $CopyWithPlaceholder(),
    Object? ruleVersion = const $CopyWithPlaceholder(),
    Object? baseEventId = const $CopyWithPlaceholder(),
    Object? targetType = const $CopyWithPlaceholder(),
    Object? targetId = const $CopyWithPlaceholder(),
    Object? scheduledAt = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
    Object? supersededBy = const $CopyWithPlaceholder(),
    Object? channelStatuses = const $CopyWithPlaceholder(),
  }) {
    return Reminder(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      ruleCode: ruleCode == const $CopyWithPlaceholder()
          ? _value.ruleCode
          // ignore: cast_nullable_to_non_nullable
          : ruleCode as String,
      ruleVersion: ruleVersion == const $CopyWithPlaceholder()
          ? _value.ruleVersion
          // ignore: cast_nullable_to_non_nullable
          : ruleVersion as String?,
      baseEventId: baseEventId == const $CopyWithPlaceholder()
          ? _value.baseEventId
          // ignore: cast_nullable_to_non_nullable
          : baseEventId as String?,
      targetType: targetType == const $CopyWithPlaceholder()
          ? _value.targetType
          // ignore: cast_nullable_to_non_nullable
          : targetType as String?,
      targetId: targetId == const $CopyWithPlaceholder()
          ? _value.targetId
          // ignore: cast_nullable_to_non_nullable
          : targetId as String?,
      scheduledAt: scheduledAt == const $CopyWithPlaceholder()
          ? _value.scheduledAt
          // ignore: cast_nullable_to_non_nullable
          : scheduledAt as DateTime,
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as ReminderState,
      supersededBy: supersededBy == const $CopyWithPlaceholder()
          ? _value.supersededBy
          // ignore: cast_nullable_to_non_nullable
          : supersededBy as String?,
      channelStatuses: channelStatuses == const $CopyWithPlaceholder()
          ? _value.channelStatuses
          // ignore: cast_nullable_to_non_nullable
          : channelStatuses as List<ReminderDelivery>,
    );
  }
}

extension $ReminderCopyWith on Reminder {
  /// Returns a callable class that can be used as follows: `instanceOfReminder.copyWith(...)` or like so:`instanceOfReminder.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReminderCWProxy get copyWith => _$ReminderCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reminder _$ReminderFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Reminder',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'rule_code',
        'scheduled_at',
        'state',
        'channel_statuses',
      ],
    );
    final val = Reminder(
      id: $checkedConvert('id', (v) => v as String),
      ruleCode: $checkedConvert('rule_code', (v) => v as String),
      ruleVersion: $checkedConvert('rule_version', (v) => v as String?),
      baseEventId: $checkedConvert('base_event_id', (v) => v as String?),
      targetType: $checkedConvert('target_type', (v) => v as String?),
      targetId: $checkedConvert('target_id', (v) => v as String?),
      scheduledAt: $checkedConvert(
        'scheduled_at',
        (v) => DateTime.parse(v as String),
      ),
      state: $checkedConvert(
        'state',
        (v) => $enumDecode(_$ReminderStateEnumMap, v),
      ),
      supersededBy: $checkedConvert('superseded_by', (v) => v as String?),
      channelStatuses: $checkedConvert(
        'channel_statuses',
        (v) => (v as List<dynamic>)
            .map((e) => ReminderDelivery.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'ruleCode': 'rule_code',
    'ruleVersion': 'rule_version',
    'baseEventId': 'base_event_id',
    'targetType': 'target_type',
    'targetId': 'target_id',
    'scheduledAt': 'scheduled_at',
    'supersededBy': 'superseded_by',
    'channelStatuses': 'channel_statuses',
  },
);

Map<String, dynamic> _$ReminderToJson(Reminder instance) => <String, dynamic>{
  'id': instance.id,
  'rule_code': instance.ruleCode,
  'rule_version': ?instance.ruleVersion,
  'base_event_id': ?instance.baseEventId,
  'target_type': ?instance.targetType,
  'target_id': ?instance.targetId,
  'scheduled_at': instance.scheduledAt.toIso8601String(),
  'state': _$ReminderStateEnumMap[instance.state]!,
  'superseded_by': ?instance.supersededBy,
  'channel_statuses': instance.channelStatuses.map((e) => e.toJson()).toList(),
};

const _$ReminderStateEnumMap = {
  ReminderState.pending: 'pending',
  ReminderState.sent: 'sent',
  ReminderState.read: 'read',
  ReminderState.failed: 'failed',
  ReminderState.superseded: 'superseded',
  ReminderState.cancelled: 'cancelled',
};
