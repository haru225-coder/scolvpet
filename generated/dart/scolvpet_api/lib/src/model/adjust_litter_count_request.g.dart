// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adjust_litter_count_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdjustLitterCountRequestCWProxy {
  AdjustLitterCountRequest eventType(
    AdjustLitterCountRequestEventTypeEnum eventType,
  );

  AdjustLitterCountRequest delta(int delta);

  AdjustLitterCountRequest occurredAt(DateTime occurredAt);

  AdjustLitterCountRequest reason(String reason);

  AdjustLitterCountRequest newTemporaryCodes(Set<String>? newTemporaryCodes);

  AdjustLitterCountRequest affectedPupIdentityIds(
    Set<String>? affectedPupIdentityIds,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdjustLitterCountRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdjustLitterCountRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AdjustLitterCountRequest call({
    AdjustLitterCountRequestEventTypeEnum eventType,
    int delta,
    DateTime occurredAt,
    String reason,
    Set<String>? newTemporaryCodes,
    Set<String>? affectedPupIdentityIds,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAdjustLitterCountRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAdjustLitterCountRequest.copyWith.fieldName(...)`
class _$AdjustLitterCountRequestCWProxyImpl
    implements _$AdjustLitterCountRequestCWProxy {
  const _$AdjustLitterCountRequestCWProxyImpl(this._value);

  final AdjustLitterCountRequest _value;

  @override
  AdjustLitterCountRequest eventType(
    AdjustLitterCountRequestEventTypeEnum eventType,
  ) => this(eventType: eventType);

  @override
  AdjustLitterCountRequest delta(int delta) => this(delta: delta);

  @override
  AdjustLitterCountRequest occurredAt(DateTime occurredAt) =>
      this(occurredAt: occurredAt);

  @override
  AdjustLitterCountRequest reason(String reason) => this(reason: reason);

  @override
  AdjustLitterCountRequest newTemporaryCodes(Set<String>? newTemporaryCodes) =>
      this(newTemporaryCodes: newTemporaryCodes);

  @override
  AdjustLitterCountRequest affectedPupIdentityIds(
    Set<String>? affectedPupIdentityIds,
  ) => this(affectedPupIdentityIds: affectedPupIdentityIds);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdjustLitterCountRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdjustLitterCountRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AdjustLitterCountRequest call({
    Object? eventType = const $CopyWithPlaceholder(),
    Object? delta = const $CopyWithPlaceholder(),
    Object? occurredAt = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? newTemporaryCodes = const $CopyWithPlaceholder(),
    Object? affectedPupIdentityIds = const $CopyWithPlaceholder(),
  }) {
    return AdjustLitterCountRequest(
      eventType: eventType == const $CopyWithPlaceholder()
          ? _value.eventType
          // ignore: cast_nullable_to_non_nullable
          : eventType as AdjustLitterCountRequestEventTypeEnum,
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
          : reason as String,
      newTemporaryCodes: newTemporaryCodes == const $CopyWithPlaceholder()
          ? _value.newTemporaryCodes
          // ignore: cast_nullable_to_non_nullable
          : newTemporaryCodes as Set<String>?,
      affectedPupIdentityIds:
          affectedPupIdentityIds == const $CopyWithPlaceholder()
          ? _value.affectedPupIdentityIds
          // ignore: cast_nullable_to_non_nullable
          : affectedPupIdentityIds as Set<String>?,
    );
  }
}

extension $AdjustLitterCountRequestCopyWith on AdjustLitterCountRequest {
  /// Returns a callable class that can be used as follows: `instanceOfAdjustLitterCountRequest.copyWith(...)` or like so:`instanceOfAdjustLitterCountRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AdjustLitterCountRequestCWProxy get copyWith =>
      _$AdjustLitterCountRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdjustLitterCountRequest _$AdjustLitterCountRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AdjustLitterCountRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['event_type', 'delta', 'occurred_at', 'reason'],
    );
    final val = AdjustLitterCountRequest(
      eventType: $checkedConvert(
        'event_type',
        (v) => $enumDecode(_$AdjustLitterCountRequestEventTypeEnumEnumMap, v),
      ),
      delta: $checkedConvert('delta', (v) => (v as num).toInt()),
      occurredAt: $checkedConvert(
        'occurred_at',
        (v) => DateTime.parse(v as String),
      ),
      reason: $checkedConvert('reason', (v) => v as String),
      newTemporaryCodes: $checkedConvert(
        'new_temporary_codes',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet(),
      ),
      affectedPupIdentityIds: $checkedConvert(
        'affected_pup_identity_ids',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'eventType': 'event_type',
    'occurredAt': 'occurred_at',
    'newTemporaryCodes': 'new_temporary_codes',
    'affectedPupIdentityIds': 'affected_pup_identity_ids',
  },
);

Map<String, dynamic> _$AdjustLitterCountRequestToJson(
  AdjustLitterCountRequest instance,
) => <String, dynamic>{
  'event_type':
      _$AdjustLitterCountRequestEventTypeEnumEnumMap[instance.eventType]!,
  'delta': instance.delta,
  'occurred_at': instance.occurredAt.toIso8601String(),
  'reason': instance.reason,
  'new_temporary_codes': ?instance.newTemporaryCodes?.toList(),
  'affected_pup_identity_ids': ?instance.affectedPupIdentityIds?.toList(),
};

const _$AdjustLitterCountRequestEventTypeEnumEnumMap = {
  AdjustLitterCountRequestEventTypeEnum.discovered: 'discovered',
  AdjustLitterCountRequestEventTypeEnum.death: 'death',
  AdjustLitterCountRequestEventTypeEnum.transferredOut: 'transferred_out',
  AdjustLitterCountRequestEventTypeEnum.correction: 'correction',
};
