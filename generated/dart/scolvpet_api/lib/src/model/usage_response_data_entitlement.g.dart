// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_response_data_entitlement.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UsageResponseDataEntitlementCWProxy {
  UsageResponseDataEntitlement planCode(String planCode);

  UsageResponseDataEntitlement enforcement(
    UsageResponseDataEntitlementEnforcementEnum enforcement,
  );

  UsageResponseDataEntitlement effectiveAt(DateTime effectiveAt);

  UsageResponseDataEntitlement expiresAt(DateTime? expiresAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UsageResponseDataEntitlement(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UsageResponseDataEntitlement(...).copyWith(id: 12, name: "My name")
  /// ````
  UsageResponseDataEntitlement call({
    String planCode,
    UsageResponseDataEntitlementEnforcementEnum enforcement,
    DateTime effectiveAt,
    DateTime? expiresAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUsageResponseDataEntitlement.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUsageResponseDataEntitlement.copyWith.fieldName(...)`
class _$UsageResponseDataEntitlementCWProxyImpl
    implements _$UsageResponseDataEntitlementCWProxy {
  const _$UsageResponseDataEntitlementCWProxyImpl(this._value);

  final UsageResponseDataEntitlement _value;

  @override
  UsageResponseDataEntitlement planCode(String planCode) =>
      this(planCode: planCode);

  @override
  UsageResponseDataEntitlement enforcement(
    UsageResponseDataEntitlementEnforcementEnum enforcement,
  ) => this(enforcement: enforcement);

  @override
  UsageResponseDataEntitlement effectiveAt(DateTime effectiveAt) =>
      this(effectiveAt: effectiveAt);

  @override
  UsageResponseDataEntitlement expiresAt(DateTime? expiresAt) =>
      this(expiresAt: expiresAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UsageResponseDataEntitlement(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UsageResponseDataEntitlement(...).copyWith(id: 12, name: "My name")
  /// ````
  UsageResponseDataEntitlement call({
    Object? planCode = const $CopyWithPlaceholder(),
    Object? enforcement = const $CopyWithPlaceholder(),
    Object? effectiveAt = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
  }) {
    return UsageResponseDataEntitlement(
      planCode: planCode == const $CopyWithPlaceholder()
          ? _value.planCode
          // ignore: cast_nullable_to_non_nullable
          : planCode as String,
      enforcement: enforcement == const $CopyWithPlaceholder()
          ? _value.enforcement
          // ignore: cast_nullable_to_non_nullable
          : enforcement as UsageResponseDataEntitlementEnforcementEnum,
      effectiveAt: effectiveAt == const $CopyWithPlaceholder()
          ? _value.effectiveAt
          // ignore: cast_nullable_to_non_nullable
          : effectiveAt as DateTime,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime?,
    );
  }
}

extension $UsageResponseDataEntitlementCopyWith
    on UsageResponseDataEntitlement {
  /// Returns a callable class that can be used as follows: `instanceOfUsageResponseDataEntitlement.copyWith(...)` or like so:`instanceOfUsageResponseDataEntitlement.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UsageResponseDataEntitlementCWProxy get copyWith =>
      _$UsageResponseDataEntitlementCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsageResponseDataEntitlement _$UsageResponseDataEntitlementFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'UsageResponseDataEntitlement',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['plan_code', 'enforcement', 'effective_at'],
    );
    final val = UsageResponseDataEntitlement(
      planCode: $checkedConvert('plan_code', (v) => v as String),
      enforcement: $checkedConvert(
        'enforcement',
        (v) => $enumDecode(
          _$UsageResponseDataEntitlementEnforcementEnumEnumMap,
          v,
        ),
      ),
      effectiveAt: $checkedConvert(
        'effective_at',
        (v) => DateTime.parse(v as String),
      ),
      expiresAt: $checkedConvert(
        'expires_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'planCode': 'plan_code',
    'effectiveAt': 'effective_at',
    'expiresAt': 'expires_at',
  },
);

Map<String, dynamic> _$UsageResponseDataEntitlementToJson(
  UsageResponseDataEntitlement instance,
) => <String, dynamic>{
  'plan_code': instance.planCode,
  'enforcement':
      _$UsageResponseDataEntitlementEnforcementEnumEnumMap[instance
          .enforcement]!,
  'effective_at': instance.effectiveAt.toIso8601String(),
  'expires_at': ?instance.expiresAt?.toIso8601String(),
};

const _$UsageResponseDataEntitlementEnforcementEnumEnumMap = {
  UsageResponseDataEntitlementEnforcementEnum.none: 'none',
};
