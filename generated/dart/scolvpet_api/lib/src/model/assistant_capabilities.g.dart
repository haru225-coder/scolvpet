// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_capabilities.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantCapabilitiesCWProxy {
  AssistantCapabilities intents(List<String> intents);

  AssistantCapabilities modeDefault(
    AssistantCapabilitiesModeDefaultEnum modeDefault,
  );

  AssistantCapabilities llmAvailable(bool llmAvailable);

  AssistantCapabilities disclaimer(String disclaimer);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantCapabilities(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantCapabilities(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantCapabilities call({
    List<String> intents,
    AssistantCapabilitiesModeDefaultEnum modeDefault,
    bool llmAvailable,
    String disclaimer,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantCapabilities.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantCapabilities.copyWith.fieldName(...)`
class _$AssistantCapabilitiesCWProxyImpl
    implements _$AssistantCapabilitiesCWProxy {
  const _$AssistantCapabilitiesCWProxyImpl(this._value);

  final AssistantCapabilities _value;

  @override
  AssistantCapabilities intents(List<String> intents) => this(intents: intents);

  @override
  AssistantCapabilities modeDefault(
    AssistantCapabilitiesModeDefaultEnum modeDefault,
  ) => this(modeDefault: modeDefault);

  @override
  AssistantCapabilities llmAvailable(bool llmAvailable) =>
      this(llmAvailable: llmAvailable);

  @override
  AssistantCapabilities disclaimer(String disclaimer) =>
      this(disclaimer: disclaimer);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantCapabilities(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantCapabilities(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantCapabilities call({
    Object? intents = const $CopyWithPlaceholder(),
    Object? modeDefault = const $CopyWithPlaceholder(),
    Object? llmAvailable = const $CopyWithPlaceholder(),
    Object? disclaimer = const $CopyWithPlaceholder(),
  }) {
    return AssistantCapabilities(
      intents: intents == const $CopyWithPlaceholder()
          ? _value.intents
          // ignore: cast_nullable_to_non_nullable
          : intents as List<String>,
      modeDefault: modeDefault == const $CopyWithPlaceholder()
          ? _value.modeDefault
          // ignore: cast_nullable_to_non_nullable
          : modeDefault as AssistantCapabilitiesModeDefaultEnum,
      llmAvailable: llmAvailable == const $CopyWithPlaceholder()
          ? _value.llmAvailable
          // ignore: cast_nullable_to_non_nullable
          : llmAvailable as bool,
      disclaimer: disclaimer == const $CopyWithPlaceholder()
          ? _value.disclaimer
          // ignore: cast_nullable_to_non_nullable
          : disclaimer as String,
    );
  }
}

extension $AssistantCapabilitiesCopyWith on AssistantCapabilities {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantCapabilities.copyWith(...)` or like so:`instanceOfAssistantCapabilities.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantCapabilitiesCWProxy get copyWith =>
      _$AssistantCapabilitiesCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantCapabilities _$AssistantCapabilitiesFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AssistantCapabilities',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'intents',
        'mode_default',
        'llm_available',
        'disclaimer',
      ],
    );
    final val = AssistantCapabilities(
      intents: $checkedConvert(
        'intents',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      modeDefault: $checkedConvert(
        'mode_default',
        (v) => $enumDecode(_$AssistantCapabilitiesModeDefaultEnumEnumMap, v),
      ),
      llmAvailable: $checkedConvert('llm_available', (v) => v as bool),
      disclaimer: $checkedConvert('disclaimer', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'modeDefault': 'mode_default',
    'llmAvailable': 'llm_available',
  },
);

Map<String, dynamic> _$AssistantCapabilitiesToJson(
  AssistantCapabilities instance,
) => <String, dynamic>{
  'intents': instance.intents,
  'mode_default':
      _$AssistantCapabilitiesModeDefaultEnumEnumMap[instance.modeDefault]!,
  'llm_available': instance.llmAvailable,
  'disclaimer': instance.disclaimer,
};

const _$AssistantCapabilitiesModeDefaultEnumEnumMap = {
  AssistantCapabilitiesModeDefaultEnum.rules: 'rules',
};
