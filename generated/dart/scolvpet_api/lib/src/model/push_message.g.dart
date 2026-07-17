// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_message.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PushMessageCWProxy {
  PushMessage id(String id);

  PushMessage title(String title);

  PushMessage body(String body);

  PushMessage data(Map<String, Object> data);

  PushMessage status(PushMessageStatusEnum status);

  PushMessage targetDeviceId(String? targetDeviceId);

  PushMessage provider(String provider);

  PushMessage providerMessageId(String? providerMessageId);

  PushMessage attemptCount(int attemptCount);

  PushMessage lastError(String? lastError);

  PushMessage sentAt(DateTime? sentAt);

  PushMessage version(int version);

  PushMessage createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PushMessage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PushMessage(...).copyWith(id: 12, name: "My name")
  /// ````
  PushMessage call({
    String id,
    String title,
    String body,
    Map<String, Object> data,
    PushMessageStatusEnum status,
    String? targetDeviceId,
    String provider,
    String? providerMessageId,
    int attemptCount,
    String? lastError,
    DateTime? sentAt,
    int version,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPushMessage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPushMessage.copyWith.fieldName(...)`
class _$PushMessageCWProxyImpl implements _$PushMessageCWProxy {
  const _$PushMessageCWProxyImpl(this._value);

  final PushMessage _value;

  @override
  PushMessage id(String id) => this(id: id);

  @override
  PushMessage title(String title) => this(title: title);

  @override
  PushMessage body(String body) => this(body: body);

  @override
  PushMessage data(Map<String, Object> data) => this(data: data);

  @override
  PushMessage status(PushMessageStatusEnum status) => this(status: status);

  @override
  PushMessage targetDeviceId(String? targetDeviceId) =>
      this(targetDeviceId: targetDeviceId);

  @override
  PushMessage provider(String provider) => this(provider: provider);

  @override
  PushMessage providerMessageId(String? providerMessageId) =>
      this(providerMessageId: providerMessageId);

  @override
  PushMessage attemptCount(int attemptCount) =>
      this(attemptCount: attemptCount);

  @override
  PushMessage lastError(String? lastError) => this(lastError: lastError);

  @override
  PushMessage sentAt(DateTime? sentAt) => this(sentAt: sentAt);

  @override
  PushMessage version(int version) => this(version: version);

  @override
  PushMessage createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PushMessage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PushMessage(...).copyWith(id: 12, name: "My name")
  /// ````
  PushMessage call({
    Object? id = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? body = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? targetDeviceId = const $CopyWithPlaceholder(),
    Object? provider = const $CopyWithPlaceholder(),
    Object? providerMessageId = const $CopyWithPlaceholder(),
    Object? attemptCount = const $CopyWithPlaceholder(),
    Object? lastError = const $CopyWithPlaceholder(),
    Object? sentAt = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return PushMessage(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String,
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as Map<String, Object>,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as PushMessageStatusEnum,
      targetDeviceId: targetDeviceId == const $CopyWithPlaceholder()
          ? _value.targetDeviceId
          // ignore: cast_nullable_to_non_nullable
          : targetDeviceId as String?,
      provider: provider == const $CopyWithPlaceholder()
          ? _value.provider
          // ignore: cast_nullable_to_non_nullable
          : provider as String,
      providerMessageId: providerMessageId == const $CopyWithPlaceholder()
          ? _value.providerMessageId
          // ignore: cast_nullable_to_non_nullable
          : providerMessageId as String?,
      attemptCount: attemptCount == const $CopyWithPlaceholder()
          ? _value.attemptCount
          // ignore: cast_nullable_to_non_nullable
          : attemptCount as int,
      lastError: lastError == const $CopyWithPlaceholder()
          ? _value.lastError
          // ignore: cast_nullable_to_non_nullable
          : lastError as String?,
      sentAt: sentAt == const $CopyWithPlaceholder()
          ? _value.sentAt
          // ignore: cast_nullable_to_non_nullable
          : sentAt as DateTime?,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $PushMessageCopyWith on PushMessage {
  /// Returns a callable class that can be used as follows: `instanceOfPushMessage.copyWith(...)` or like so:`instanceOfPushMessage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PushMessageCWProxy get copyWith => _$PushMessageCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushMessage _$PushMessageFromJson(Map<String, dynamic> json) => $checkedCreate(
  'PushMessage',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'title',
        'body',
        'data',
        'status',
        'provider',
        'attempt_count',
        'version',
        'created_at',
      ],
    );
    final val = PushMessage(
      id: $checkedConvert('id', (v) => v as String),
      title: $checkedConvert('title', (v) => v as String),
      body: $checkedConvert('body', (v) => v as String),
      data: $checkedConvert(
        'data',
        (v) =>
            (v as Map<String, dynamic>).map((k, e) => MapEntry(k, e as Object)),
      ),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$PushMessageStatusEnumEnumMap, v),
      ),
      targetDeviceId: $checkedConvert('target_device_id', (v) => v as String?),
      provider: $checkedConvert('provider', (v) => v as String),
      providerMessageId: $checkedConvert(
        'provider_message_id',
        (v) => v as String?,
      ),
      attemptCount: $checkedConvert('attempt_count', (v) => (v as num).toInt()),
      lastError: $checkedConvert('last_error', (v) => v as String?),
      sentAt: $checkedConvert(
        'sent_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      version: $checkedConvert('version', (v) => (v as num).toInt()),
      createdAt: $checkedConvert(
        'created_at',
        (v) => DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'targetDeviceId': 'target_device_id',
    'providerMessageId': 'provider_message_id',
    'attemptCount': 'attempt_count',
    'lastError': 'last_error',
    'sentAt': 'sent_at',
    'createdAt': 'created_at',
  },
);

Map<String, dynamic> _$PushMessageToJson(PushMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'data': instance.data,
      'status': _$PushMessageStatusEnumEnumMap[instance.status]!,
      'target_device_id': ?instance.targetDeviceId,
      'provider': instance.provider,
      'provider_message_id': ?instance.providerMessageId,
      'attempt_count': instance.attemptCount,
      'last_error': ?instance.lastError,
      'sent_at': ?instance.sentAt?.toIso8601String(),
      'version': instance.version,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$PushMessageStatusEnumEnumMap = {
  PushMessageStatusEnum.queued: 'queued',
  PushMessageStatusEnum.sending: 'sending',
  PushMessageStatusEnum.sent: 'sent',
  PushMessageStatusEnum.failed: 'failed',
};
