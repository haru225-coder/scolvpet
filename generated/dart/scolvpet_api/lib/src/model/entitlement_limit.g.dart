// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement_limit.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EntitlementLimitCWProxy {
  EntitlementLimit code(String code);

  EntitlementLimit metric(String metric);

  EntitlementLimit title(String title);

  EntitlementLimit limit(num? limit);

  EntitlementLimit used(num used);

  EntitlementLimit remaining(num? remaining);

  EntitlementLimit over(bool over);

  EntitlementLimit unit(String unit);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EntitlementLimit(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EntitlementLimit(...).copyWith(id: 12, name: "My name")
  /// ````
  EntitlementLimit call({
    String code,
    String metric,
    String title,
    num? limit,
    num used,
    num? remaining,
    bool over,
    String unit,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEntitlementLimit.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEntitlementLimit.copyWith.fieldName(...)`
class _$EntitlementLimitCWProxyImpl implements _$EntitlementLimitCWProxy {
  const _$EntitlementLimitCWProxyImpl(this._value);

  final EntitlementLimit _value;

  @override
  EntitlementLimit code(String code) => this(code: code);

  @override
  EntitlementLimit metric(String metric) => this(metric: metric);

  @override
  EntitlementLimit title(String title) => this(title: title);

  @override
  EntitlementLimit limit(num? limit) => this(limit: limit);

  @override
  EntitlementLimit used(num used) => this(used: used);

  @override
  EntitlementLimit remaining(num? remaining) => this(remaining: remaining);

  @override
  EntitlementLimit over(bool over) => this(over: over);

  @override
  EntitlementLimit unit(String unit) => this(unit: unit);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EntitlementLimit(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EntitlementLimit(...).copyWith(id: 12, name: "My name")
  /// ````
  EntitlementLimit call({
    Object? code = const $CopyWithPlaceholder(),
    Object? metric = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? limit = const $CopyWithPlaceholder(),
    Object? used = const $CopyWithPlaceholder(),
    Object? remaining = const $CopyWithPlaceholder(),
    Object? over = const $CopyWithPlaceholder(),
    Object? unit = const $CopyWithPlaceholder(),
  }) {
    return EntitlementLimit(
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      metric: metric == const $CopyWithPlaceholder()
          ? _value.metric
          // ignore: cast_nullable_to_non_nullable
          : metric as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      limit: limit == const $CopyWithPlaceholder()
          ? _value.limit
          // ignore: cast_nullable_to_non_nullable
          : limit as num?,
      used: used == const $CopyWithPlaceholder()
          ? _value.used
          // ignore: cast_nullable_to_non_nullable
          : used as num,
      remaining: remaining == const $CopyWithPlaceholder()
          ? _value.remaining
          // ignore: cast_nullable_to_non_nullable
          : remaining as num?,
      over: over == const $CopyWithPlaceholder()
          ? _value.over
          // ignore: cast_nullable_to_non_nullable
          : over as bool,
      unit: unit == const $CopyWithPlaceholder()
          ? _value.unit
          // ignore: cast_nullable_to_non_nullable
          : unit as String,
    );
  }
}

extension $EntitlementLimitCopyWith on EntitlementLimit {
  /// Returns a callable class that can be used as follows: `instanceOfEntitlementLimit.copyWith(...)` or like so:`instanceOfEntitlementLimit.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EntitlementLimitCWProxy get copyWith => _$EntitlementLimitCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntitlementLimit _$EntitlementLimitFromJson(Map<String, dynamic> json) =>
    $checkedCreate('EntitlementLimit', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['code', 'metric', 'title', 'used', 'over', 'unit'],
      );
      final val = EntitlementLimit(
        code: $checkedConvert('code', (v) => v as String),
        metric: $checkedConvert('metric', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        limit: $checkedConvert('limit', (v) => v as num?),
        used: $checkedConvert('used', (v) => v as num),
        remaining: $checkedConvert('remaining', (v) => v as num?),
        over: $checkedConvert('over', (v) => v as bool),
        unit: $checkedConvert('unit', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$EntitlementLimitToJson(EntitlementLimit instance) =>
    <String, dynamic>{
      'code': instance.code,
      'metric': instance.metric,
      'title': instance.title,
      'limit': ?instance.limit,
      'used': instance.used,
      'remaining': ?instance.remaining,
      'over': instance.over,
      'unit': instance.unit,
    };
