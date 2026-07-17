// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement_feature.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EntitlementFeatureCWProxy {
  EntitlementFeature code(String code);

  EntitlementFeature title(String title);

  EntitlementFeature description(String description);

  EntitlementFeature allowed(bool allowed);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EntitlementFeature(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EntitlementFeature(...).copyWith(id: 12, name: "My name")
  /// ````
  EntitlementFeature call({
    String code,
    String title,
    String description,
    bool allowed,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEntitlementFeature.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEntitlementFeature.copyWith.fieldName(...)`
class _$EntitlementFeatureCWProxyImpl implements _$EntitlementFeatureCWProxy {
  const _$EntitlementFeatureCWProxyImpl(this._value);

  final EntitlementFeature _value;

  @override
  EntitlementFeature code(String code) => this(code: code);

  @override
  EntitlementFeature title(String title) => this(title: title);

  @override
  EntitlementFeature description(String description) =>
      this(description: description);

  @override
  EntitlementFeature allowed(bool allowed) => this(allowed: allowed);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EntitlementFeature(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EntitlementFeature(...).copyWith(id: 12, name: "My name")
  /// ````
  EntitlementFeature call({
    Object? code = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? allowed = const $CopyWithPlaceholder(),
  }) {
    return EntitlementFeature(
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String,
      allowed: allowed == const $CopyWithPlaceholder()
          ? _value.allowed
          // ignore: cast_nullable_to_non_nullable
          : allowed as bool,
    );
  }
}

extension $EntitlementFeatureCopyWith on EntitlementFeature {
  /// Returns a callable class that can be used as follows: `instanceOfEntitlementFeature.copyWith(...)` or like so:`instanceOfEntitlementFeature.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EntitlementFeatureCWProxy get copyWith =>
      _$EntitlementFeatureCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntitlementFeature _$EntitlementFeatureFromJson(Map<String, dynamic> json) =>
    $checkedCreate('EntitlementFeature', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['code', 'title', 'description', 'allowed'],
      );
      final val = EntitlementFeature(
        code: $checkedConvert('code', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        description: $checkedConvert('description', (v) => v as String),
        allowed: $checkedConvert('allowed', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$EntitlementFeatureToJson(EntitlementFeature instance) =>
    <String, dynamic>{
      'code': instance.code,
      'title': instance.title,
      'description': instance.description,
      'allowed': instance.allowed,
    };
