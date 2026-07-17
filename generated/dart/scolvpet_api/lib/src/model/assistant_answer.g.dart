// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_answer.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantAnswerCWProxy {
  AssistantAnswer answer(String answer);

  AssistantAnswer intent(String intent);

  AssistantAnswer mode(AssistantAnswerModeEnum mode);

  AssistantAnswer facts(List<AssistantFact> facts);

  AssistantAnswer disclaimer(String disclaimer);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantAnswer(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantAnswer(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantAnswer call({
    String answer,
    String intent,
    AssistantAnswerModeEnum mode,
    List<AssistantFact> facts,
    String disclaimer,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantAnswer.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantAnswer.copyWith.fieldName(...)`
class _$AssistantAnswerCWProxyImpl implements _$AssistantAnswerCWProxy {
  const _$AssistantAnswerCWProxyImpl(this._value);

  final AssistantAnswer _value;

  @override
  AssistantAnswer answer(String answer) => this(answer: answer);

  @override
  AssistantAnswer intent(String intent) => this(intent: intent);

  @override
  AssistantAnswer mode(AssistantAnswerModeEnum mode) => this(mode: mode);

  @override
  AssistantAnswer facts(List<AssistantFact> facts) => this(facts: facts);

  @override
  AssistantAnswer disclaimer(String disclaimer) => this(disclaimer: disclaimer);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantAnswer(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantAnswer(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantAnswer call({
    Object? answer = const $CopyWithPlaceholder(),
    Object? intent = const $CopyWithPlaceholder(),
    Object? mode = const $CopyWithPlaceholder(),
    Object? facts = const $CopyWithPlaceholder(),
    Object? disclaimer = const $CopyWithPlaceholder(),
  }) {
    return AssistantAnswer(
      answer: answer == const $CopyWithPlaceholder()
          ? _value.answer
          // ignore: cast_nullable_to_non_nullable
          : answer as String,
      intent: intent == const $CopyWithPlaceholder()
          ? _value.intent
          // ignore: cast_nullable_to_non_nullable
          : intent as String,
      mode: mode == const $CopyWithPlaceholder()
          ? _value.mode
          // ignore: cast_nullable_to_non_nullable
          : mode as AssistantAnswerModeEnum,
      facts: facts == const $CopyWithPlaceholder()
          ? _value.facts
          // ignore: cast_nullable_to_non_nullable
          : facts as List<AssistantFact>,
      disclaimer: disclaimer == const $CopyWithPlaceholder()
          ? _value.disclaimer
          // ignore: cast_nullable_to_non_nullable
          : disclaimer as String,
    );
  }
}

extension $AssistantAnswerCopyWith on AssistantAnswer {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantAnswer.copyWith(...)` or like so:`instanceOfAssistantAnswer.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantAnswerCWProxy get copyWith => _$AssistantAnswerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantAnswer _$AssistantAnswerFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AssistantAnswer', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['answer', 'intent', 'mode', 'facts', 'disclaimer'],
      );
      final val = AssistantAnswer(
        answer: $checkedConvert('answer', (v) => v as String),
        intent: $checkedConvert('intent', (v) => v as String),
        mode: $checkedConvert(
          'mode',
          (v) => $enumDecode(_$AssistantAnswerModeEnumEnumMap, v),
        ),
        facts: $checkedConvert(
          'facts',
          (v) => (v as List<dynamic>)
              .map((e) => AssistantFact.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        disclaimer: $checkedConvert('disclaimer', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$AssistantAnswerToJson(AssistantAnswer instance) =>
    <String, dynamic>{
      'answer': instance.answer,
      'intent': instance.intent,
      'mode': _$AssistantAnswerModeEnumEnumMap[instance.mode]!,
      'facts': instance.facts.map((e) => e.toJson()).toList(),
      'disclaimer': instance.disclaimer,
    };

const _$AssistantAnswerModeEnumEnumMap = {
  AssistantAnswerModeEnum.rules: 'rules',
  AssistantAnswerModeEnum.llm: 'llm',
};
