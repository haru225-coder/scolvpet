// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'litter_count_event.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LitterCountEventCWProxy {
  LitterCountEvent id(String id);

  LitterCountEvent litterId(String litterId);

  LitterCountEvent eventType(LitterCountEventEventTypeEnum eventType);

  LitterCountEvent delta(int delta);

  LitterCountEvent occurredAt(DateTime occurredAt);

  LitterCountEvent reason(String? reason);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LitterCountEvent(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LitterCountEvent(...).copyWith(id: 12, name: "My name")
  /// ````
  LitterCountEvent call({
    String id,
    String litterId,
    LitterCountEventEventTypeEnum eventType,
    int delta,
    DateTime occurredAt,
    String? reason,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLitterCountEvent.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLitterCountEvent.copyWith.fieldName(...)`
class _$LitterCountEventCWProxyImpl implements _$LitterCountEventCWProxy {
  const _$LitterCountEventCWProxyImpl(this._value);

  final LitterCountEvent _value;

  @override
  LitterCountEvent id(String id) => this(id: id);

  @override
  LitterCountEvent litterId(String litterId) => this(litterId: litterId);

  @override
  LitterCountEvent eventType(LitterCountEventEventTypeEnum eventType) =>
      this(eventType: eventType);

  @override
  LitterCountEvent delta(int delta) => this(delta: delta);

  @override
  LitterCountEvent occurredAt(DateTime occurredAt) =>
      this(occurredAt: occurredAt);

  @override
  LitterCountEvent reason(String? reason) => this(reason: reason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LitterCountEvent(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LitterCountEvent(...).copyWith(id: 12, name: "My name")
  /// ````
  LitterCountEvent call({
    Object? id = const $CopyWithPlaceholder(),
    Object? litterId = const $CopyWithPlaceholder(),
    Object? eventType = const $CopyWithPlaceholder(),
    Object? delta = const $CopyWithPlaceholder(),
    Object? occurredAt = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
  }) {
    return LitterCountEvent(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      litterId: litterId == const $CopyWithPlaceholder()
          ? _value.litterId
          // ignore: cast_nullable_to_non_nullable
          : litterId as String,
      eventType: eventType == const $CopyWithPlaceholder()
          ? _value.eventType
          // ignore: cast_nullable_to_non_nullable
          : eventType as LitterCountEventEventTypeEnum,
      delta: delta == const $CopyWithPlaceholder()
          ? _value.delta
          // ignore: cast_nullable_to_non_nullable
          : delta as int,
      occurredAt: occurredAt == const $CopyWithPlaceholder()
          ? _value.occurredAt
          // ignore: cast_nullable_to_non_nullable
          : occurredAt as DateTime,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String?,
    );
  }
}

extension $LitterCountEventCopyWith on LitterCountEvent {
  /// Returns a callable class that can be used as follows: `instanceOfLitterCountEvent.copyWith(...)` or like so:`instanceOfLitterCountEvent.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LitterCountEventCWProxy get copyWith => _$LitterCountEventCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LitterCountEvent _$LitterCountEventFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'LitterCountEvent',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'litter_id',
            'event_type',
            'delta',
            'occurred_at',
          ],
        );
        final val = LitterCountEvent(
          id: $checkedConvert('id', (v) => v as String),
          litterId: $checkedConvert('litter_id', (v) => v as String),
          eventType: $checkedConvert(
            'event_type',
            (v) => $enumDecode(_$LitterCountEventEventTypeEnumEnumMap, v),
          ),
          delta: $checkedConvert('delta', (v) => (v as num).toInt()),
          occurredAt: $checkedConvert(
            'occurred_at',
            (v) => DateTime.parse(v as String),
          ),
          reason: $checkedConvert('reason', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'litterId': 'litter_id',
        'eventType': 'event_type',
        'occurredAt': 'occurred_at',
      },
    );

Map<String, dynamic> _$LitterCountEventToJson(LitterCountEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'litter_id': instance.litterId,
      'event_type': _$LitterCountEventEventTypeEnumEnumMap[instance.eventType]!,
      'delta': instance.delta,
      'occurred_at': instance.occurredAt.toIso8601String(),
      'reason': ?instance.reason,
    };

const _$LitterCountEventEventTypeEnumEnumMap = {
  LitterCountEventEventTypeEnum.initialAlive: 'initial_alive',
  LitterCountEventEventTypeEnum.discovered: 'discovered',
  LitterCountEventEventTypeEnum.death: 'death',
  LitterCountEventEventTypeEnum.transferredOut: 'transferred_out',
  LitterCountEventEventTypeEnum.correction: 'correction',
};
