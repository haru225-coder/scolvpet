// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement_check_result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EntitlementCheckResultCWProxy {
  EntitlementCheckResult allowed(bool allowed);

  EntitlementCheckResult enforcement(String enforcement);

  EntitlementCheckResult planCode(String planCode);

  EntitlementCheckResult reason(String? reason);

  EntitlementCheckResult feature(String? feature);

  EntitlementCheckResult metric(String? metric);

  EntitlementCheckResult used(num? used);

  EntitlementCheckResult limit(num? limit);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EntitlementCheckResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EntitlementCheckResult(...).copyWith(id: 12, name: "My name")
  /// ````
  EntitlementCheckResult call({
    bool allowed,
    String enforcement,
    String planCode,
    String? reason,
    String? feature,
    String? metric,
    num? used,
    num? limit,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEntitlementCheckResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEntitlementCheckResult.copyWith.fieldName(...)`
class _$EntitlementCheckResultCWProxyImpl
    implements _$EntitlementCheckResultCWProxy {
  const _$EntitlementCheckResultCWProxyImpl(this._value);

  final EntitlementCheckResult _value;

  @override
  EntitlementCheckResult allowed(bool allowed) => this(allowed: allowed);

  @override
  EntitlementCheckResult enforcement(String enforcement) =>
      this(enforcement: enforcement);

  @override
  EntitlementCheckResult planCode(String planCode) => this(planCode: planCode);

  @override
  EntitlementCheckResult reason(String? reason) => this(reason: reason);

  @override
  EntitlementCheckResult feature(String? feature) => this(feature: feature);

  @override
  EntitlementCheckResult metric(String? metric) => this(metric: metric);

  @override
  EntitlementCheckResult used(num? used) => this(used: used);

  @override
  EntitlementCheckResult limit(num? limit) => this(limit: limit);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EntitlementCheckResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EntitlementCheckResult(...).copyWith(id: 12, name: "My name")
  /// ````
  EntitlementCheckResult call({
    Object? allowed = const $CopyWithPlaceholder(),
    Object? enforcement = const $CopyWithPlaceholder(),
    Object? planCode = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? feature = const $CopyWithPlaceholder(),
    Object? metric = const $CopyWithPlaceholder(),
    Object? used = const $CopyWithPlaceholder(),
    Object? limit = const $CopyWithPlaceholder(),
  }) {
    return EntitlementCheckResult(
      allowed: allowed == const $CopyWithPlaceholder()
          ? _value.allowed
          // ignore: cast_nullable_to_non_nullable
          : allowed as bool,
      enforcement: enforcement == const $CopyWithPlaceholder()
          ? _value.enforcement
          // ignore: cast_nullable_to_non_nullable
          : enforcement as String,
      planCode: planCode == const $CopyWithPlaceholder()
          ? _value.planCode
          // ignore: cast_nullable_to_non_nullable
          : planCode as String,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String?,
      feature: feature == const $CopyWithPlaceholder()
          ? _value.feature
          // ignore: cast_nullable_to_non_nullable
          : feature as String?,
      metric: metric == const $CopyWithPlaceholder()
          ? _value.metric
          // ignore: cast_nullable_to_non_nullable
          : metric as String?,
      used: used == const $CopyWithPlaceholder()
          ? _value.used
          // ignore: cast_nullable_to_non_nullable
          : used as num?,
      limit: limit == const $CopyWithPlaceholder()
          ? _value.limit
          // ignore: cast_nullable_to_non_nullable
          : limit as num?,
    );
  }
}

extension $EntitlementCheckResultCopyWith on EntitlementCheckResult {
  /// Returns a callable class that can be used as follows: `instanceOfEntitlementCheckResult.copyWith(...)` or like so:`instanceOfEntitlementCheckResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EntitlementCheckResultCWProxy get copyWith =>
      _$EntitlementCheckResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntitlementCheckResult _$EntitlementCheckResultFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('EntitlementCheckResult', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['allowed', 'enforcement', 'plan_code']);
  final val = EntitlementCheckResult(
    allowed: $checkedConvert('allowed', (v) => v as bool),
    enforcement: $checkedConvert('enforcement', (v) => v as String),
    planCode: $checkedConvert('plan_code', (v) => v as String),
    reason: $checkedConvert('reason', (v) => v as String?),
    feature: $checkedConvert('feature', (v) => v as String?),
    metric: $checkedConvert('metric', (v) => v as String?),
    used: $checkedConvert('used', (v) => v as num?),
    limit: $checkedConvert('limit', (v) => v as num?),
  );
  return val;
}, fieldKeyMap: const {'planCode': 'plan_code'});

Map<String, dynamic> _$EntitlementCheckResultToJson(
  EntitlementCheckResult instance,
) => <String, dynamic>{
  'allowed': instance.allowed,
  'enforcement': instance.enforcement,
  'plan_code': instance.planCode,
  'reason': ?instance.reason,
  'feature': ?instance.feature,
  'metric': ?instance.metric,
  'used': ?instance.used,
  'limit': ?instance.limit,
};
