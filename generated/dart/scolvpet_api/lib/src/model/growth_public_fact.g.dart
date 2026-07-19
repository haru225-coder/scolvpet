// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_public_fact.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GrowthPublicFactCWProxy {
  GrowthPublicFact key(String key);

  GrowthPublicFact value(String value);

  GrowthPublicFact source_(String source_);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrowthPublicFact(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrowthPublicFact(...).copyWith(id: 12, name: "My name")
  /// ````
  GrowthPublicFact call({String key, String value, String source_});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGrowthPublicFact.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGrowthPublicFact.copyWith.fieldName(...)`
class _$GrowthPublicFactCWProxyImpl implements _$GrowthPublicFactCWProxy {
  const _$GrowthPublicFactCWProxyImpl(this._value);

  final GrowthPublicFact _value;

  @override
  GrowthPublicFact key(String key) => this(key: key);

  @override
  GrowthPublicFact value(String value) => this(value: value);

  @override
  GrowthPublicFact source_(String source_) => this(source_: source_);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrowthPublicFact(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrowthPublicFact(...).copyWith(id: 12, name: "My name")
  /// ````
  GrowthPublicFact call({
    Object? key = const $CopyWithPlaceholder(),
    Object? value = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
  }) {
    return GrowthPublicFact(
      key: key == const $CopyWithPlaceholder()
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as String,
      value: value == const $CopyWithPlaceholder()
          ? _value.value
          // ignore: cast_nullable_to_non_nullable
          : value as String,
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as String,
    );
  }
}

extension $GrowthPublicFactCopyWith on GrowthPublicFact {
  /// Returns a callable class that can be used as follows: `instanceOfGrowthPublicFact.copyWith(...)` or like so:`instanceOfGrowthPublicFact.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GrowthPublicFactCWProxy get copyWith => _$GrowthPublicFactCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrowthPublicFact _$GrowthPublicFactFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GrowthPublicFact', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['key', 'value', 'source']);
      final val = GrowthPublicFact(
        key: $checkedConvert('key', (v) => v as String),
        value: $checkedConvert('value', (v) => v as String),
        source_: $checkedConvert('source', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$GrowthPublicFactToJson(GrowthPublicFact instance) =>
    <String, dynamic>{
      'key': instance.key,
      'value': instance.value,
      'source': instance.source_,
    };
