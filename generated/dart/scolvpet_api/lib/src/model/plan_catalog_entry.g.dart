// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_catalog_entry.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PlanCatalogEntryCWProxy {
  PlanCatalogEntry code(PlanCatalogEntryCodeEnum code);

  PlanCatalogEntry title(String title);

  PlanCatalogEntry description(String description);

  PlanCatalogEntry priceHint(String priceHint);

  PlanCatalogEntry features(Map<String, bool> features);

  PlanCatalogEntry limits(Map<String, num> limits);

  PlanCatalogEntry enforcement(PlanCatalogEntryEnforcementEnum enforcement);

  PlanCatalogEntry highlight(bool? highlight);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlanCatalogEntry(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlanCatalogEntry(...).copyWith(id: 12, name: "My name")
  /// ````
  PlanCatalogEntry call({
    PlanCatalogEntryCodeEnum code,
    String title,
    String description,
    String priceHint,
    Map<String, bool> features,
    Map<String, num> limits,
    PlanCatalogEntryEnforcementEnum enforcement,
    bool? highlight,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPlanCatalogEntry.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPlanCatalogEntry.copyWith.fieldName(...)`
class _$PlanCatalogEntryCWProxyImpl implements _$PlanCatalogEntryCWProxy {
  const _$PlanCatalogEntryCWProxyImpl(this._value);

  final PlanCatalogEntry _value;

  @override
  PlanCatalogEntry code(PlanCatalogEntryCodeEnum code) => this(code: code);

  @override
  PlanCatalogEntry title(String title) => this(title: title);

  @override
  PlanCatalogEntry description(String description) =>
      this(description: description);

  @override
  PlanCatalogEntry priceHint(String priceHint) => this(priceHint: priceHint);

  @override
  PlanCatalogEntry features(Map<String, bool> features) =>
      this(features: features);

  @override
  PlanCatalogEntry limits(Map<String, num> limits) => this(limits: limits);

  @override
  PlanCatalogEntry enforcement(PlanCatalogEntryEnforcementEnum enforcement) =>
      this(enforcement: enforcement);

  @override
  PlanCatalogEntry highlight(bool? highlight) => this(highlight: highlight);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlanCatalogEntry(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlanCatalogEntry(...).copyWith(id: 12, name: "My name")
  /// ````
  PlanCatalogEntry call({
    Object? code = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? priceHint = const $CopyWithPlaceholder(),
    Object? features = const $CopyWithPlaceholder(),
    Object? limits = const $CopyWithPlaceholder(),
    Object? enforcement = const $CopyWithPlaceholder(),
    Object? highlight = const $CopyWithPlaceholder(),
  }) {
    return PlanCatalogEntry(
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as PlanCatalogEntryCodeEnum,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String,
      priceHint: priceHint == const $CopyWithPlaceholder()
          ? _value.priceHint
          // ignore: cast_nullable_to_non_nullable
          : priceHint as String,
      features: features == const $CopyWithPlaceholder()
          ? _value.features
          // ignore: cast_nullable_to_non_nullable
          : features as Map<String, bool>,
      limits: limits == const $CopyWithPlaceholder()
          ? _value.limits
          // ignore: cast_nullable_to_non_nullable
          : limits as Map<String, num>,
      enforcement: enforcement == const $CopyWithPlaceholder()
          ? _value.enforcement
          // ignore: cast_nullable_to_non_nullable
          : enforcement as PlanCatalogEntryEnforcementEnum,
      highlight: highlight == const $CopyWithPlaceholder()
          ? _value.highlight
          // ignore: cast_nullable_to_non_nullable
          : highlight as bool?,
    );
  }
}

extension $PlanCatalogEntryCopyWith on PlanCatalogEntry {
  /// Returns a callable class that can be used as follows: `instanceOfPlanCatalogEntry.copyWith(...)` or like so:`instanceOfPlanCatalogEntry.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PlanCatalogEntryCWProxy get copyWith => _$PlanCatalogEntryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanCatalogEntry _$PlanCatalogEntryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PlanCatalogEntry', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'code',
          'title',
          'description',
          'price_hint',
          'features',
          'limits',
          'enforcement',
        ],
      );
      final val = PlanCatalogEntry(
        code: $checkedConvert(
          'code',
          (v) => $enumDecode(_$PlanCatalogEntryCodeEnumEnumMap, v),
        ),
        title: $checkedConvert('title', (v) => v as String),
        description: $checkedConvert('description', (v) => v as String),
        priceHint: $checkedConvert('price_hint', (v) => v as String),
        features: $checkedConvert(
          'features',
          (v) => Map<String, bool>.from(v as Map),
        ),
        limits: $checkedConvert(
          'limits',
          (v) => Map<String, num>.from(v as Map),
        ),
        enforcement: $checkedConvert(
          'enforcement',
          (v) => $enumDecode(_$PlanCatalogEntryEnforcementEnumEnumMap, v),
        ),
        highlight: $checkedConvert('highlight', (v) => v as bool?),
      );
      return val;
    }, fieldKeyMap: const {'priceHint': 'price_hint'});

Map<String, dynamic> _$PlanCatalogEntryToJson(PlanCatalogEntry instance) =>
    <String, dynamic>{
      'code': _$PlanCatalogEntryCodeEnumEnumMap[instance.code]!,
      'title': instance.title,
      'description': instance.description,
      'price_hint': instance.priceHint,
      'features': instance.features,
      'limits': instance.limits,
      'enforcement':
          _$PlanCatalogEntryEnforcementEnumEnumMap[instance.enforcement]!,
      'highlight': ?instance.highlight,
    };

const _$PlanCatalogEntryCodeEnumEnumMap = {
  PlanCatalogEntryCodeEnum.free: 'free',
  PlanCatalogEntryCodeEnum.pro: 'pro',
};

const _$PlanCatalogEntryEnforcementEnumEnumMap = {
  PlanCatalogEntryEnforcementEnum.none: 'none',
  PlanCatalogEntryEnforcementEnum.soft: 'soft',
  PlanCatalogEntryEnforcementEnum.hard: 'hard',
};
