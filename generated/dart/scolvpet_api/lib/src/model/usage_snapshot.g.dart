// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_snapshot.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UsageSnapshotCWProxy {
  UsageSnapshot id(String id);

  UsageSnapshot periodStart(DateTime periodStart);

  UsageSnapshot periodEnd(DateTime periodEnd);

  UsageSnapshot metrics(List<UsageMetric> metrics);

  UsageSnapshot createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UsageSnapshot(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UsageSnapshot(...).copyWith(id: 12, name: "My name")
  /// ````
  UsageSnapshot call({
    String id,
    DateTime periodStart,
    DateTime periodEnd,
    List<UsageMetric> metrics,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUsageSnapshot.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUsageSnapshot.copyWith.fieldName(...)`
class _$UsageSnapshotCWProxyImpl implements _$UsageSnapshotCWProxy {
  const _$UsageSnapshotCWProxyImpl(this._value);

  final UsageSnapshot _value;

  @override
  UsageSnapshot id(String id) => this(id: id);

  @override
  UsageSnapshot periodStart(DateTime periodStart) =>
      this(periodStart: periodStart);

  @override
  UsageSnapshot periodEnd(DateTime periodEnd) => this(periodEnd: periodEnd);

  @override
  UsageSnapshot metrics(List<UsageMetric> metrics) => this(metrics: metrics);

  @override
  UsageSnapshot createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UsageSnapshot(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UsageSnapshot(...).copyWith(id: 12, name: "My name")
  /// ````
  UsageSnapshot call({
    Object? id = const $CopyWithPlaceholder(),
    Object? periodStart = const $CopyWithPlaceholder(),
    Object? periodEnd = const $CopyWithPlaceholder(),
    Object? metrics = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return UsageSnapshot(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      periodStart: periodStart == const $CopyWithPlaceholder()
          ? _value.periodStart
          // ignore: cast_nullable_to_non_nullable
          : periodStart as DateTime,
      periodEnd: periodEnd == const $CopyWithPlaceholder()
          ? _value.periodEnd
          // ignore: cast_nullable_to_non_nullable
          : periodEnd as DateTime,
      metrics: metrics == const $CopyWithPlaceholder()
          ? _value.metrics
          // ignore: cast_nullable_to_non_nullable
          : metrics as List<UsageMetric>,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $UsageSnapshotCopyWith on UsageSnapshot {
  /// Returns a callable class that can be used as follows: `instanceOfUsageSnapshot.copyWith(...)` or like so:`instanceOfUsageSnapshot.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UsageSnapshotCWProxy get copyWith => _$UsageSnapshotCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsageSnapshot _$UsageSnapshotFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'UsageSnapshot',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'period_start',
            'period_end',
            'metrics',
            'created_at',
          ],
        );
        final val = UsageSnapshot(
          id: $checkedConvert('id', (v) => v as String),
          periodStart: $checkedConvert(
            'period_start',
            (v) => DateTime.parse(v as String),
          ),
          periodEnd: $checkedConvert(
            'period_end',
            (v) => DateTime.parse(v as String),
          ),
          metrics: $checkedConvert(
            'metrics',
            (v) => (v as List<dynamic>)
                .map((e) => UsageMetric.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
          createdAt: $checkedConvert(
            'created_at',
            (v) => DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'periodStart': 'period_start',
        'periodEnd': 'period_end',
        'createdAt': 'created_at',
      },
    );

Map<String, dynamic> _$UsageSnapshotToJson(UsageSnapshot instance) =>
    <String, dynamic>{
      'id': instance.id,
      'period_start': instance.periodStart.toIso8601String(),
      'period_end': instance.periodEnd.toIso8601String(),
      'metrics': instance.metrics.map((e) => e.toJson()).toList(),
      'created_at': instance.createdAt.toIso8601String(),
    };
