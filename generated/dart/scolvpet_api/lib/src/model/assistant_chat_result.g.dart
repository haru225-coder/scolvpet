// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_chat_result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantChatResultCWProxy {
  AssistantChatResult sessionId(String sessionId);

  AssistantChatResult messageId(String messageId);

  AssistantChatResult answer(String answer);

  AssistantChatResult intent(String intent);

  AssistantChatResult mode(AssistantChatResultModeEnum mode);

  AssistantChatResult facts(List<AssistantFact> facts);

  AssistantChatResult actions(List<AssistantChatAction> actions);

  AssistantChatResult disclaimer(String disclaimer);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantChatResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantChatResult(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantChatResult call({
    String sessionId,
    String messageId,
    String answer,
    String intent,
    AssistantChatResultModeEnum mode,
    List<AssistantFact> facts,
    List<AssistantChatAction> actions,
    String disclaimer,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantChatResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantChatResult.copyWith.fieldName(...)`
class _$AssistantChatResultCWProxyImpl implements _$AssistantChatResultCWProxy {
  const _$AssistantChatResultCWProxyImpl(this._value);

  final AssistantChatResult _value;

  @override
  AssistantChatResult sessionId(String sessionId) => this(sessionId: sessionId);

  @override
  AssistantChatResult messageId(String messageId) => this(messageId: messageId);

  @override
  AssistantChatResult answer(String answer) => this(answer: answer);

  @override
  AssistantChatResult intent(String intent) => this(intent: intent);

  @override
  AssistantChatResult mode(AssistantChatResultModeEnum mode) =>
      this(mode: mode);

  @override
  AssistantChatResult facts(List<AssistantFact> facts) => this(facts: facts);

  @override
  AssistantChatResult actions(List<AssistantChatAction> actions) =>
      this(actions: actions);

  @override
  AssistantChatResult disclaimer(String disclaimer) =>
      this(disclaimer: disclaimer);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantChatResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantChatResult(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantChatResult call({
    Object? sessionId = const $CopyWithPlaceholder(),
    Object? messageId = const $CopyWithPlaceholder(),
    Object? answer = const $CopyWithPlaceholder(),
    Object? intent = const $CopyWithPlaceholder(),
    Object? mode = const $CopyWithPlaceholder(),
    Object? facts = const $CopyWithPlaceholder(),
    Object? actions = const $CopyWithPlaceholder(),
    Object? disclaimer = const $CopyWithPlaceholder(),
  }) {
    return AssistantChatResult(
      sessionId: sessionId == const $CopyWithPlaceholder()
          ? _value.sessionId
          // ignore: cast_nullable_to_non_nullable
          : sessionId as String,
      messageId: messageId == const $CopyWithPlaceholder()
          ? _value.messageId
          // ignore: cast_nullable_to_non_nullable
          : messageId as String,
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
          : mode as AssistantChatResultModeEnum,
      facts: facts == const $CopyWithPlaceholder()
          ? _value.facts
          // ignore: cast_nullable_to_non_nullable
          : facts as List<AssistantFact>,
      actions: actions == const $CopyWithPlaceholder()
          ? _value.actions
          // ignore: cast_nullable_to_non_nullable
          : actions as List<AssistantChatAction>,
      disclaimer: disclaimer == const $CopyWithPlaceholder()
          ? _value.disclaimer
          // ignore: cast_nullable_to_non_nullable
          : disclaimer as String,
    );
  }
}

extension $AssistantChatResultCopyWith on AssistantChatResult {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantChatResult.copyWith(...)` or like so:`instanceOfAssistantChatResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantChatResultCWProxy get copyWith =>
      _$AssistantChatResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantChatResult _$AssistantChatResultFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'AssistantChatResult',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'session_id',
            'message_id',
            'answer',
            'intent',
            'mode',
            'facts',
            'actions',
            'disclaimer',
          ],
        );
        final val = AssistantChatResult(
          sessionId: $checkedConvert('session_id', (v) => v as String),
          messageId: $checkedConvert('message_id', (v) => v as String),
          answer: $checkedConvert('answer', (v) => v as String),
          intent: $checkedConvert('intent', (v) => v as String),
          mode: $checkedConvert(
            'mode',
            (v) => $enumDecode(_$AssistantChatResultModeEnumEnumMap, v),
          ),
          facts: $checkedConvert(
            'facts',
            (v) => (v as List<dynamic>)
                .map((e) => AssistantFact.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
          actions: $checkedConvert(
            'actions',
            (v) => (v as List<dynamic>)
                .map(
                  (e) =>
                      AssistantChatAction.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
          ),
          disclaimer: $checkedConvert('disclaimer', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {'sessionId': 'session_id', 'messageId': 'message_id'},
    );

Map<String, dynamic> _$AssistantChatResultToJson(
  AssistantChatResult instance,
) => <String, dynamic>{
  'session_id': instance.sessionId,
  'message_id': instance.messageId,
  'answer': instance.answer,
  'intent': instance.intent,
  'mode': _$AssistantChatResultModeEnumEnumMap[instance.mode]!,
  'facts': instance.facts.map((e) => e.toJson()).toList(),
  'actions': instance.actions.map((e) => e.toJson()).toList(),
  'disclaimer': instance.disclaimer,
};

const _$AssistantChatResultModeEnumEnumMap = {
  AssistantChatResultModeEnum.rules: 'rules',
  AssistantChatResultModeEnum.llm: 'llm',
};
