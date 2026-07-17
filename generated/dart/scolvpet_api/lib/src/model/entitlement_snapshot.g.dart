// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement_snapshot.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EntitlementSnapshotCWProxy {
  EntitlementSnapshot planCode(String planCode);

  EntitlementSnapshot planTitle(String planTitle);

  EntitlementSnapshot enforcement(
    EntitlementSnapshotEnforcementEnum enforcement,
  );

  EntitlementSnapshot source_(String source_);

  EntitlementSnapshot effectiveAt(DateTime effectiveAt);

  EntitlementSnapshot expiresAt(DateTime? expiresAt);

  EntitlementSnapshot features(List<EntitlementFeature> features);

  EntitlementSnapshot limits(List<EntitlementLimit> limits);

  EntitlementSnapshot overLimit(bool overLimit);

  EntitlementSnapshot paywallHint(String? paywallHint);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EntitlementSnapshot(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EntitlementSnapshot(...).copyWith(id: 12, name: "My name")
  /// ````
  EntitlementSnapshot call({
    String planCode,
    String planTitle,
    EntitlementSnapshotEnforcementEnum enforcement,
    String source_,
    DateTime effectiveAt,
    DateTime? expiresAt,
    List<EntitlementFeature> features,
    List<EntitlementLimit> limits,
    bool overLimit,
    String? paywallHint,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEntitlementSnapshot.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEntitlementSnapshot.copyWith.fieldName(...)`
class _$EntitlementSnapshotCWProxyImpl implements _$EntitlementSnapshotCWProxy {
  const _$EntitlementSnapshotCWProxyImpl(this._value);

  final EntitlementSnapshot _value;

  @override
  EntitlementSnapshot planCode(String planCode) => this(planCode: planCode);

  @override
  EntitlementSnapshot planTitle(String planTitle) => this(planTitle: planTitle);

  @override
  EntitlementSnapshot enforcement(
    EntitlementSnapshotEnforcementEnum enforcement,
  ) => this(enforcement: enforcement);

  @override
  EntitlementSnapshot source_(String source_) => this(source_: source_);

  @override
  EntitlementSnapshot effectiveAt(DateTime effectiveAt) =>
      this(effectiveAt: effectiveAt);

  @override
  EntitlementSnapshot expiresAt(DateTime? expiresAt) =>
      this(expiresAt: expiresAt);

  @override
  EntitlementSnapshot features(List<EntitlementFeature> features) =>
      this(features: features);

  @override
  EntitlementSnapshot limits(List<EntitlementLimit> limits) =>
      this(limits: limits);

  @override
  EntitlementSnapshot overLimit(bool overLimit) => this(overLimit: overLimit);

  @override
  EntitlementSnapshot paywallHint(String? paywallHint) =>
      this(paywallHint: paywallHint);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EntitlementSnapshot(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EntitlementSnapshot(...).copyWith(id: 12, name: "My name")
  /// ````
  EntitlementSnapshot call({
    Object? planCode = const $CopyWithPlaceholder(),
    Object? planTitle = const $CopyWithPlaceholder(),
    Object? enforcement = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
    Object? effectiveAt = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
    Object? features = const $CopyWithPlaceholder(),
    Object? limits = const $CopyWithPlaceholder(),
    Object? overLimit = const $CopyWithPlaceholder(),
    Object? paywallHint = const $CopyWithPlaceholder(),
  }) {
    return EntitlementSnapshot(
      planCode: planCode == const $CopyWithPlaceholder()
          ? _value.planCode
          // ignore: cast_nullable_to_non_nullable
          : planCode as String,
      planTitle: planTitle == const $CopyWithPlaceholder()
          ? _value.planTitle
          // ignore: cast_nullable_to_non_nullable
          : planTitle as String,
      enforcement: enforcement == const $CopyWithPlaceholder()
          ? _value.enforcement
          // ignore: cast_nullable_to_non_nullable
          : enforcement as EntitlementSnapshotEnforcementEnum,
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as String,
      effectiveAt: effectiveAt == const $CopyWithPlaceholder()
          ? _value.effectiveAt
          // ignore: cast_nullable_to_non_nullable
          : effectiveAt as DateTime,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime?,
      features: features == const $CopyWithPlaceholder()
          ? _value.features
          // ignore: cast_nullable_to_non_nullable
          : features as List<EntitlementFeature>,
      limits: limits == const $CopyWithPlaceholder()
          ? _value.limits
          // ignore: cast_nullable_to_non_nullable
          : limits as List<EntitlementLimit>,
      overLimit: overLimit == const $CopyWithPlaceholder()
          ? _value.overLimit
          // ignore: cast_nullable_to_non_nullable
          : overLimit as bool,
      paywallHint: paywallHint == const $CopyWithPlaceholder()
          ? _value.paywallHint
          // ignore: cast_nullable_to_non_nullable
          : paywallHint as String?,
    );
  }
}

extension $EntitlementSnapshotCopyWith on EntitlementSnapshot {
  /// Returns a callable class that can be used as follows: `instanceOfEntitlementSnapshot.copyWith(...)` or like so:`instanceOfEntitlementSnapshot.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EntitlementSnapshotCWProxy get copyWith =>
      _$EntitlementSnapshotCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntitlementSnapshot _$EntitlementSnapshotFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'EntitlementSnapshot',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'plan_code',
        'plan_title',
        'enforcement',
        'source',
        'effective_at',
        'features',
        'limits',
        'over_limit',
      ],
    );
    final val = EntitlementSnapshot(
      planCode: $checkedConvert('plan_code', (v) => v as String),
      planTitle: $checkedConvert('plan_title', (v) => v as String),
      enforcement: $checkedConvert(
        'enforcement',
        (v) => $enumDecode(_$EntitlementSnapshotEnforcementEnumEnumMap, v),
      ),
      source_: $checkedConvert('source', (v) => v as String),
      effectiveAt: $checkedConvert(
        'effective_at',
        (v) => DateTime.parse(v as String),
      ),
      expiresAt: $checkedConvert(
        'expires_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      features: $checkedConvert(
        'features',
        (v) => (v as List<dynamic>)
            .map((e) => EntitlementFeature.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      limits: $checkedConvert(
        'limits',
        (v) => (v as List<dynamic>)
            .map((e) => EntitlementLimit.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      overLimit: $checkedConvert('over_limit', (v) => v as bool),
      paywallHint: $checkedConvert('paywall_hint', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'planCode': 'plan_code',
    'planTitle': 'plan_title',
    'source_': 'source',
    'effectiveAt': 'effective_at',
    'expiresAt': 'expires_at',
    'overLimit': 'over_limit',
    'paywallHint': 'paywall_hint',
  },
);

Map<String, dynamic> _$EntitlementSnapshotToJson(
  EntitlementSnapshot instance,
) => <String, dynamic>{
  'plan_code': instance.planCode,
  'plan_title': instance.planTitle,
  'enforcement':
      _$EntitlementSnapshotEnforcementEnumEnumMap[instance.enforcement]!,
  'source': instance.source_,
  'effective_at': instance.effectiveAt.toIso8601String(),
  'expires_at': ?instance.expiresAt?.toIso8601String(),
  'features': instance.features.map((e) => e.toJson()).toList(),
  'limits': instance.limits.map((e) => e.toJson()).toList(),
  'over_limit': instance.overLimit,
  'paywall_hint': ?instance.paywallHint,
};

const _$EntitlementSnapshotEnforcementEnumEnumMap = {
  EntitlementSnapshotEnforcementEnum.none: 'none',
  EntitlementSnapshotEnforcementEnum.soft: 'soft',
  EntitlementSnapshotEnforcementEnum.hard: 'hard',
};
