// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_metric.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UsageMetricCWProxy {
  UsageMetric metric(UsageMetricMetricEnum metric);

  UsageMetric used(num used);

  UsageMetric limit(num? limit);

  UsageMetric unit(UsageMetricUnitEnum unit);

  UsageMetric measuredAt(DateTime measuredAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UsageMetric(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UsageMetric(...).copyWith(id: 12, name: "My name")
  /// ````
  UsageMetric call({
    UsageMetricMetricEnum metric,
    num used,
    num? limit,
    UsageMetricUnitEnum unit,
    DateTime measuredAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUsageMetric.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUsageMetric.copyWith.fieldName(...)`
class _$UsageMetricCWProxyImpl implements _$UsageMetricCWProxy {
  const _$UsageMetricCWProxyImpl(this._value);

  final UsageMetric _value;

  @override
  UsageMetric metric(UsageMetricMetricEnum metric) => this(metric: metric);

  @override
  UsageMetric used(num used) => this(used: used);

  @override
  UsageMetric limit(num? limit) => this(limit: limit);

  @override
  UsageMetric unit(UsageMetricUnitEnum unit) => this(unit: unit);

  @override
  UsageMetric measuredAt(DateTime measuredAt) => this(measuredAt: measuredAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UsageMetric(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UsageMetric(...).copyWith(id: 12, name: "My name")
  /// ````
  UsageMetric call({
    Object? metric = const $CopyWithPlaceholder(),
    Object? used = const $CopyWithPlaceholder(),
    Object? limit = const $CopyWithPlaceholder(),
    Object? unit = const $CopyWithPlaceholder(),
    Object? measuredAt = const $CopyWithPlaceholder(),
  }) {
    return UsageMetric(
      metric: metric == const $CopyWithPlaceholder()
          ? _value.metric
          // ignore: cast_nullable_to_non_nullable
          : metric as UsageMetricMetricEnum,
      used: used == const $CopyWithPlaceholder()
          ? _value.used
          // ignore: cast_nullable_to_non_nullable
          : used as num,
      limit: limit == const $CopyWithPlaceholder()
          ? _value.limit
          // ignore: cast_nullable_to_non_nullable
          : limit as num?,
      unit: unit == const $CopyWithPlaceholder()
          ? _value.unit
          // ignore: cast_nullable_to_non_nullable
          : unit as UsageMetricUnitEnum,
      measuredAt: measuredAt == const $CopyWithPlaceholder()
          ? _value.measuredAt
          // ignore: cast_nullable_to_non_nullable
          : measuredAt as DateTime,
    );
  }
}

extension $UsageMetricCopyWith on UsageMetric {
  /// Returns a callable class that can be used as follows: `instanceOfUsageMetric.copyWith(...)` or like so:`instanceOfUsageMetric.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UsageMetricCWProxy get copyWith => _$UsageMetricCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsageMetric _$UsageMetricFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UsageMetric', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['metric', 'used', 'unit', 'measured_at'],
      );
      final val = UsageMetric(
        metric: $checkedConvert(
          'metric',
          (v) => $enumDecode(_$UsageMetricMetricEnumEnumMap, v),
        ),
        used: $checkedConvert('used', (v) => v as num),
        limit: $checkedConvert('limit', (v) => v as num?),
        unit: $checkedConvert(
          'unit',
          (v) => $enumDecode(_$UsageMetricUnitEnumEnumMap, v),
        ),
        measuredAt: $checkedConvert(
          'measured_at',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    }, fieldKeyMap: const {'measuredAt': 'measured_at'});

Map<String, dynamic> _$UsageMetricToJson(UsageMetric instance) =>
    <String, dynamic>{
      'metric': _$UsageMetricMetricEnumEnumMap[instance.metric]!,
      'used': instance.used,
      'limit': ?instance.limit,
      'unit': _$UsageMetricUnitEnumEnumMap[instance.unit]!,
      'measured_at': instance.measuredAt.toIso8601String(),
    };

const _$UsageMetricMetricEnumEnumMap = {
  UsageMetricMetricEnum.activeHamsters: 'active_hamsters',
  UsageMetricMetricEnum.activeLitters: 'active_litters',
  UsageMetricMetricEnum.enclosures: 'enclosures',
  UsageMetricMetricEnum.mediaBytes: 'media_bytes',
  UsageMetricMetricEnum.videoMinutes: 'video_minutes',
  UsageMetricMetricEnum.backupBytes: 'backup_bytes',
};

const _$UsageMetricUnitEnumEnumMap = {
  UsageMetricUnitEnum.count: 'count',
  UsageMetricUnitEnum.bytes: 'bytes',
  UsageMetricUnitEnum.minutes: 'minutes',
};
