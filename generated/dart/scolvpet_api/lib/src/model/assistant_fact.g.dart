// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_fact.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantFactCWProxy {
  AssistantFact key(String key);

  AssistantFact label(String label);

  AssistantFact value(String value);

  AssistantFact source_(String source_);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantFact(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantFact(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantFact call({String key, String label, String value, String source_});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantFact.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantFact.copyWith.fieldName(...)`
class _$AssistantFactCWProxyImpl implements _$AssistantFactCWProxy {
  const _$AssistantFactCWProxyImpl(this._value);

  final AssistantFact _value;

  @override
  AssistantFact key(String key) => this(key: key);

  @override
  AssistantFact label(String label) => this(label: label);

  @override
  AssistantFact value(String value) => this(value: value);

  @override
  AssistantFact source_(String source_) => this(source_: source_);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantFact(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantFact(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantFact call({
    Object? key = const $CopyWithPlaceholder(),
    Object? label = const $CopyWithPlaceholder(),
    Object? value = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
  }) {
    return AssistantFact(
      key: key == const $CopyWithPlaceholder()
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as String,
      label: label == const $CopyWithPlaceholder()
          ? _value.label
          // ignore: cast_nullable_to_non_nullable
          : label as String,
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

extension $AssistantFactCopyWith on AssistantFact {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantFact.copyWith(...)` or like so:`instanceOfAssistantFact.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantFactCWProxy get copyWith => _$AssistantFactCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantFact _$AssistantFactFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AssistantFact', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['key', 'label', 'value', 'source']);
      final val = AssistantFact(
        key: $checkedConvert('key', (v) => v as String),
        label: $checkedConvert('label', (v) => v as String),
        value: $checkedConvert('value', (v) => v as String),
        source_: $checkedConvert('source', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$AssistantFactToJson(AssistantFact instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
      'value': instance.value,
      'source': instance.source_,
    };
