// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kinship_check.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$KinshipCheckCWProxy {
  KinshipCheck checkedAt(DateTime checkedAt);

  KinshipCheck commonAncestorCount(int commonAncestorCount);

  KinshipCheck riskLevel(KinshipCheckRiskLevelEnum riskLevel);

  KinshipCheck coefficient(num? coefficient);

  KinshipCheck ruleVersion(String ruleVersion);

  KinshipCheck warnings(List<String>? warnings);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `KinshipCheck(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// KinshipCheck(...).copyWith(id: 12, name: "My name")
  /// ````
  KinshipCheck call({
    DateTime checkedAt,
    int commonAncestorCount,
    KinshipCheckRiskLevelEnum riskLevel,
    num? coefficient,
    String ruleVersion,
    List<String>? warnings,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfKinshipCheck.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfKinshipCheck.copyWith.fieldName(...)`
class _$KinshipCheckCWProxyImpl implements _$KinshipCheckCWProxy {
  const _$KinshipCheckCWProxyImpl(this._value);

  final KinshipCheck _value;

  @override
  KinshipCheck checkedAt(DateTime checkedAt) => this(checkedAt: checkedAt);

  @override
  KinshipCheck commonAncestorCount(int commonAncestorCount) =>
      this(commonAncestorCount: commonAncestorCount);

  @override
  KinshipCheck riskLevel(KinshipCheckRiskLevelEnum riskLevel) =>
      this(riskLevel: riskLevel);

  @override
  KinshipCheck coefficient(num? coefficient) => this(coefficient: coefficient);

  @override
  KinshipCheck ruleVersion(String ruleVersion) =>
      this(ruleVersion: ruleVersion);

  @override
  KinshipCheck warnings(List<String>? warnings) => this(warnings: warnings);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `KinshipCheck(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// KinshipCheck(...).copyWith(id: 12, name: "My name")
  /// ````
  KinshipCheck call({
    Object? checkedAt = const $CopyWithPlaceholder(),
    Object? commonAncestorCount = const $CopyWithPlaceholder(),
    Object? riskLevel = const $CopyWithPlaceholder(),
    Object? coefficient = const $CopyWithPlaceholder(),
    Object? ruleVersion = const $CopyWithPlaceholder(),
    Object? warnings = const $CopyWithPlaceholder(),
  }) {
    return KinshipCheck(
      checkedAt: checkedAt == const $CopyWithPlaceholder()
          ? _value.checkedAt
          // ignore: cast_nullable_to_non_nullable
          : checkedAt as DateTime,
      commonAncestorCount: commonAncestorCount == const $CopyWithPlaceholder()
          ? _value.commonAncestorCount
          // ignore: cast_nullable_to_non_nullable
          : commonAncestorCount as int,
      riskLevel: riskLevel == const $CopyWithPlaceholder()
          ? _value.riskLevel
          // ignore: cast_nullable_to_non_nullable
          : riskLevel as KinshipCheckRiskLevelEnum,
      coefficient: coefficient == const $CopyWithPlaceholder()
          ? _value.coefficient
          // ignore: cast_nullable_to_non_nullable
          : coefficient as num?,
      ruleVersion: ruleVersion == const $CopyWithPlaceholder()
          ? _value.ruleVersion
          // ignore: cast_nullable_to_non_nullable
          : ruleVersion as String,
      warnings: warnings == const $CopyWithPlaceholder()
          ? _value.warnings
          // ignore: cast_nullable_to_non_nullable
          : warnings as List<String>?,
    );
  }
}

extension $KinshipCheckCopyWith on KinshipCheck {
  /// Returns a callable class that can be used as follows: `instanceOfKinshipCheck.copyWith(...)` or like so:`instanceOfKinshipCheck.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$KinshipCheckCWProxy get copyWith => _$KinshipCheckCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KinshipCheck _$KinshipCheckFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'KinshipCheck',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'checked_at',
            'common_ancestor_count',
            'risk_level',
            'rule_version',
          ],
        );
        final val = KinshipCheck(
          checkedAt: $checkedConvert(
            'checked_at',
            (v) => DateTime.parse(v as String),
          ),
          commonAncestorCount: $checkedConvert(
            'common_ancestor_count',
            (v) => (v as num).toInt(),
          ),
          riskLevel: $checkedConvert(
            'risk_level',
            (v) => $enumDecode(_$KinshipCheckRiskLevelEnumEnumMap, v),
          ),
          coefficient: $checkedConvert('coefficient', (v) => v as num?),
          ruleVersion: $checkedConvert('rule_version', (v) => v as String),
          warnings: $checkedConvert(
            'warnings',
            (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'checkedAt': 'checked_at',
        'commonAncestorCount': 'common_ancestor_count',
        'riskLevel': 'risk_level',
        'ruleVersion': 'rule_version',
      },
    );

Map<String, dynamic> _$KinshipCheckToJson(KinshipCheck instance) =>
    <String, dynamic>{
      'checked_at': instance.checkedAt.toIso8601String(),
      'common_ancestor_count': instance.commonAncestorCount,
      'risk_level': _$KinshipCheckRiskLevelEnumEnumMap[instance.riskLevel]!,
      'coefficient': ?instance.coefficient,
      'rule_version': instance.ruleVersion,
      'warnings': ?instance.warnings,
    };

const _$KinshipCheckRiskLevelEnumEnumMap = {
  KinshipCheckRiskLevelEnum.none: 'none',
  KinshipCheckRiskLevelEnum.low: 'low',
  KinshipCheckRiskLevelEnum.medium: 'medium',
  KinshipCheckRiskLevelEnum.high: 'high',
  KinshipCheckRiskLevelEnum.blocked: 'blocked',
};
