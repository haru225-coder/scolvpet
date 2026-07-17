// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement_check_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EntitlementCheckRequestCWProxy {
  EntitlementCheckRequest feature(String? feature);

  EntitlementCheckRequest metric(String? metric);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EntitlementCheckRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EntitlementCheckRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  EntitlementCheckRequest call({String? feature, String? metric});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEntitlementCheckRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEntitlementCheckRequest.copyWith.fieldName(...)`
class _$EntitlementCheckRequestCWProxyImpl
    implements _$EntitlementCheckRequestCWProxy {
  const _$EntitlementCheckRequestCWProxyImpl(this._value);

  final EntitlementCheckRequest _value;

  @override
  EntitlementCheckRequest feature(String? feature) => this(feature: feature);

  @override
  EntitlementCheckRequest metric(String? metric) => this(metric: metric);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EntitlementCheckRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EntitlementCheckRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  EntitlementCheckRequest call({
    Object? feature = const $CopyWithPlaceholder(),
    Object? metric = const $CopyWithPlaceholder(),
  }) {
    return EntitlementCheckRequest(
      feature: feature == const $CopyWithPlaceholder()
          ? _value.feature
          // ignore: cast_nullable_to_non_nullable
          : feature as String?,
      metric: metric == const $CopyWithPlaceholder()
          ? _value.metric
          // ignore: cast_nullable_to_non_nullable
          : metric as String?,
    );
  }
}

extension $EntitlementCheckRequestCopyWith on EntitlementCheckRequest {
  /// Returns a callable class that can be used as follows: `instanceOfEntitlementCheckRequest.copyWith(...)` or like so:`instanceOfEntitlementCheckRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EntitlementCheckRequestCWProxy get copyWith =>
      _$EntitlementCheckRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntitlementCheckRequest _$EntitlementCheckRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('EntitlementCheckRequest', json, ($checkedConvert) {
  final val = EntitlementCheckRequest(
    feature: $checkedConvert('feature', (v) => v as String?),
    metric: $checkedConvert('metric', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$EntitlementCheckRequestToJson(
  EntitlementCheckRequest instance,
) => <String, dynamic>{
  'feature': ?instance.feature,
  'metric': ?instance.metric,
};
