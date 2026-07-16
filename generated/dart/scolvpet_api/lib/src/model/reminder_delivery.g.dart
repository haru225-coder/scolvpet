// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_delivery.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReminderDeliveryCWProxy {
  ReminderDelivery channel(ReminderDeliveryChannelEnum channel);

  ReminderDelivery status(ReminderDeliveryStatusEnum status);

  ReminderDelivery dedupeKey(String dedupeKey);

  ReminderDelivery attemptedAt(DateTime? attemptedAt);

  ReminderDelivery deliveredAt(DateTime? deliveredAt);

  ReminderDelivery failureCode(String? failureCode);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReminderDelivery(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReminderDelivery(...).copyWith(id: 12, name: "My name")
  /// ````
  ReminderDelivery call({
    ReminderDeliveryChannelEnum channel,
    ReminderDeliveryStatusEnum status,
    String dedupeKey,
    DateTime? attemptedAt,
    DateTime? deliveredAt,
    String? failureCode,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReminderDelivery.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReminderDelivery.copyWith.fieldName(...)`
class _$ReminderDeliveryCWProxyImpl implements _$ReminderDeliveryCWProxy {
  const _$ReminderDeliveryCWProxyImpl(this._value);

  final ReminderDelivery _value;

  @override
  ReminderDelivery channel(ReminderDeliveryChannelEnum channel) =>
      this(channel: channel);

  @override
  ReminderDelivery status(ReminderDeliveryStatusEnum status) =>
      this(status: status);

  @override
  ReminderDelivery dedupeKey(String dedupeKey) => this(dedupeKey: dedupeKey);

  @override
  ReminderDelivery attemptedAt(DateTime? attemptedAt) =>
      this(attemptedAt: attemptedAt);

  @override
  ReminderDelivery deliveredAt(DateTime? deliveredAt) =>
      this(deliveredAt: deliveredAt);

  @override
  ReminderDelivery failureCode(String? failureCode) =>
      this(failureCode: failureCode);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReminderDelivery(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReminderDelivery(...).copyWith(id: 12, name: "My name")
  /// ````
  ReminderDelivery call({
    Object? channel = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? dedupeKey = const $CopyWithPlaceholder(),
    Object? attemptedAt = const $CopyWithPlaceholder(),
    Object? deliveredAt = const $CopyWithPlaceholder(),
    Object? failureCode = const $CopyWithPlaceholder(),
  }) {
    return ReminderDelivery(
      channel: channel == const $CopyWithPlaceholder()
          ? _value.channel
          // ignore: cast_nullable_to_non_nullable
          : channel as ReminderDeliveryChannelEnum,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as ReminderDeliveryStatusEnum,
      dedupeKey: dedupeKey == const $CopyWithPlaceholder()
          ? _value.dedupeKey
          // ignore: cast_nullable_to_non_nullable
          : dedupeKey as String,
      attemptedAt: attemptedAt == const $CopyWithPlaceholder()
          ? _value.attemptedAt
          // ignore: cast_nullable_to_non_nullable
          : attemptedAt as DateTime?,
      deliveredAt: deliveredAt == const $CopyWithPlaceholder()
          ? _value.deliveredAt
          // ignore: cast_nullable_to_non_nullable
          : deliveredAt as DateTime?,
      failureCode: failureCode == const $CopyWithPlaceholder()
          ? _value.failureCode
          // ignore: cast_nullable_to_non_nullable
          : failureCode as String?,
    );
  }
}

extension $ReminderDeliveryCopyWith on ReminderDelivery {
  /// Returns a callable class that can be used as follows: `instanceOfReminderDelivery.copyWith(...)` or like so:`instanceOfReminderDelivery.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReminderDeliveryCWProxy get copyWith => _$ReminderDeliveryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReminderDelivery _$ReminderDeliveryFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ReminderDelivery',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['channel', 'status', 'dedupe_key'],
        );
        final val = ReminderDelivery(
          channel: $checkedConvert(
            'channel',
            (v) => $enumDecode(_$ReminderDeliveryChannelEnumEnumMap, v),
          ),
          status: $checkedConvert(
            'status',
            (v) => $enumDecode(_$ReminderDeliveryStatusEnumEnumMap, v),
          ),
          dedupeKey: $checkedConvert('dedupe_key', (v) => v as String),
          attemptedAt: $checkedConvert(
            'attempted_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          deliveredAt: $checkedConvert(
            'delivered_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          failureCode: $checkedConvert('failure_code', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'dedupeKey': 'dedupe_key',
        'attemptedAt': 'attempted_at',
        'deliveredAt': 'delivered_at',
        'failureCode': 'failure_code',
      },
    );

Map<String, dynamic> _$ReminderDeliveryToJson(ReminderDelivery instance) =>
    <String, dynamic>{
      'channel': _$ReminderDeliveryChannelEnumEnumMap[instance.channel]!,
      'status': _$ReminderDeliveryStatusEnumEnumMap[instance.status]!,
      'dedupe_key': instance.dedupeKey,
      'attempted_at': ?instance.attemptedAt?.toIso8601String(),
      'delivered_at': ?instance.deliveredAt?.toIso8601String(),
      'failure_code': ?instance.failureCode,
    };

const _$ReminderDeliveryChannelEnumEnumMap = {
  ReminderDeliveryChannelEnum.inApp: 'in_app',
  ReminderDeliveryChannelEnum.local: 'local',
  ReminderDeliveryChannelEnum.appPush: 'app_push',
  ReminderDeliveryChannelEnum.wechatService: 'wechat_service',
};

const _$ReminderDeliveryStatusEnumEnumMap = {
  ReminderDeliveryStatusEnum.pending: 'pending',
  ReminderDeliveryStatusEnum.succeeded: 'succeeded',
  ReminderDeliveryStatusEnum.failed: 'failed',
  ReminderDeliveryStatusEnum.read: 'read',
  ReminderDeliveryStatusEnum.disabled: 'disabled',
};
