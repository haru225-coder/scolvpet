// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_revocation_response_data_cache_invalidation.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ShareRevocationResponseDataCacheInvalidationCWProxy {
  ShareRevocationResponseDataCacheInvalidation status(
    ShareRevocationResponseDataCacheInvalidationStatusEnum status,
  );

  ShareRevocationResponseDataCacheInvalidation outboxEventId(
    String outboxEventId,
  );

  ShareRevocationResponseDataCacheInvalidation queuedAt(DateTime queuedAt);

  ShareRevocationResponseDataCacheInvalidation maxEdgeTtlSeconds(
    ShareRevocationResponseDataCacheInvalidationMaxEdgeTtlSecondsEnum
    maxEdgeTtlSeconds,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ShareRevocationResponseDataCacheInvalidation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ShareRevocationResponseDataCacheInvalidation(...).copyWith(id: 12, name: "My name")
  /// ````
  ShareRevocationResponseDataCacheInvalidation call({
    ShareRevocationResponseDataCacheInvalidationStatusEnum status,
    String outboxEventId,
    DateTime queuedAt,
    ShareRevocationResponseDataCacheInvalidationMaxEdgeTtlSecondsEnum
    maxEdgeTtlSeconds,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfShareRevocationResponseDataCacheInvalidation.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfShareRevocationResponseDataCacheInvalidation.copyWith.fieldName(...)`
class _$ShareRevocationResponseDataCacheInvalidationCWProxyImpl
    implements _$ShareRevocationResponseDataCacheInvalidationCWProxy {
  const _$ShareRevocationResponseDataCacheInvalidationCWProxyImpl(this._value);

  final ShareRevocationResponseDataCacheInvalidation _value;

  @override
  ShareRevocationResponseDataCacheInvalidation status(
    ShareRevocationResponseDataCacheInvalidationStatusEnum status,
  ) => this(status: status);

  @override
  ShareRevocationResponseDataCacheInvalidation outboxEventId(
    String outboxEventId,
  ) => this(outboxEventId: outboxEventId);

  @override
  ShareRevocationResponseDataCacheInvalidation queuedAt(DateTime queuedAt) =>
      this(queuedAt: queuedAt);

  @override
  ShareRevocationResponseDataCacheInvalidation maxEdgeTtlSeconds(
    ShareRevocationResponseDataCacheInvalidationMaxEdgeTtlSecondsEnum
    maxEdgeTtlSeconds,
  ) => this(maxEdgeTtlSeconds: maxEdgeTtlSeconds);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ShareRevocationResponseDataCacheInvalidation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ShareRevocationResponseDataCacheInvalidation(...).copyWith(id: 12, name: "My name")
  /// ````
  ShareRevocationResponseDataCacheInvalidation call({
    Object? status = const $CopyWithPlaceholder(),
    Object? outboxEventId = const $CopyWithPlaceholder(),
    Object? queuedAt = const $CopyWithPlaceholder(),
    Object? maxEdgeTtlSeconds = const $CopyWithPlaceholder(),
  }) {
    return ShareRevocationResponseDataCacheInvalidation(
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as ShareRevocationResponseDataCacheInvalidationStatusEnum,
      outboxEventId: outboxEventId == const $CopyWithPlaceholder()
          ? _value.outboxEventId
          // ignore: cast_nullable_to_non_nullable
          : outboxEventId as String,
      queuedAt: queuedAt == const $CopyWithPlaceholder()
          ? _value.queuedAt
          // ignore: cast_nullable_to_non_nullable
          : queuedAt as DateTime,
      maxEdgeTtlSeconds: maxEdgeTtlSeconds == const $CopyWithPlaceholder()
          ? _value.maxEdgeTtlSeconds
          // ignore: cast_nullable_to_non_nullable
          : maxEdgeTtlSeconds
                as ShareRevocationResponseDataCacheInvalidationMaxEdgeTtlSecondsEnum,
    );
  }
}

extension $ShareRevocationResponseDataCacheInvalidationCopyWith
    on ShareRevocationResponseDataCacheInvalidation {
  /// Returns a callable class that can be used as follows: `instanceOfShareRevocationResponseDataCacheInvalidation.copyWith(...)` or like so:`instanceOfShareRevocationResponseDataCacheInvalidation.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ShareRevocationResponseDataCacheInvalidationCWProxy get copyWith =>
      _$ShareRevocationResponseDataCacheInvalidationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShareRevocationResponseDataCacheInvalidation
_$ShareRevocationResponseDataCacheInvalidationFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ShareRevocationResponseDataCacheInvalidation',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'status',
        'outbox_event_id',
        'queued_at',
        'max_edge_ttl_seconds',
      ],
    );
    final val = ShareRevocationResponseDataCacheInvalidation(
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(
          _$ShareRevocationResponseDataCacheInvalidationStatusEnumEnumMap,
          v,
        ),
      ),
      outboxEventId: $checkedConvert('outbox_event_id', (v) => v as String),
      queuedAt: $checkedConvert(
        'queued_at',
        (v) => DateTime.parse(v as String),
      ),
      maxEdgeTtlSeconds: $checkedConvert(
        'max_edge_ttl_seconds',
        (v) => $enumDecode(
          _$ShareRevocationResponseDataCacheInvalidationMaxEdgeTtlSecondsEnumEnumMap,
          v,
        ),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'outboxEventId': 'outbox_event_id',
    'queuedAt': 'queued_at',
    'maxEdgeTtlSeconds': 'max_edge_ttl_seconds',
  },
);

Map<String, dynamic> _$ShareRevocationResponseDataCacheInvalidationToJson(
  ShareRevocationResponseDataCacheInvalidation instance,
) => <String, dynamic>{
  'status':
      _$ShareRevocationResponseDataCacheInvalidationStatusEnumEnumMap[instance
          .status]!,
  'outbox_event_id': instance.outboxEventId,
  'queued_at': instance.queuedAt.toIso8601String(),
  'max_edge_ttl_seconds':
      _$ShareRevocationResponseDataCacheInvalidationMaxEdgeTtlSecondsEnumEnumMap[instance
          .maxEdgeTtlSeconds]!,
};

const _$ShareRevocationResponseDataCacheInvalidationStatusEnumEnumMap = {
  ShareRevocationResponseDataCacheInvalidationStatusEnum.queued: 'queued',
};

const _$ShareRevocationResponseDataCacheInvalidationMaxEdgeTtlSecondsEnumEnumMap =
    {
      ShareRevocationResponseDataCacheInvalidationMaxEdgeTtlSecondsEnum
              .number60:
          60,
    };
