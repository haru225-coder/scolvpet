// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_ask_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantAskRequestCWProxy {
  AssistantAskRequest question(String question);

  AssistantAskRequest preferLlm(bool? preferLlm);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantAskRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantAskRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantAskRequest call({String question, bool? preferLlm});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantAskRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantAskRequest.copyWith.fieldName(...)`
class _$AssistantAskRequestCWProxyImpl implements _$AssistantAskRequestCWProxy {
  const _$AssistantAskRequestCWProxyImpl(this._value);

  final AssistantAskRequest _value;

  @override
  AssistantAskRequest question(String question) => this(question: question);

  @override
  AssistantAskRequest preferLlm(bool? preferLlm) => this(preferLlm: preferLlm);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantAskRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantAskRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantAskRequest call({
    Object? question = const $CopyWithPlaceholder(),
    Object? preferLlm = const $CopyWithPlaceholder(),
  }) {
    return AssistantAskRequest(
      question: question == const $CopyWithPlaceholder()
          ? _value.question
          // ignore: cast_nullable_to_non_nullable
          : question as String,
      preferLlm: preferLlm == const $CopyWithPlaceholder()
          ? _value.preferLlm
          // ignore: cast_nullable_to_non_nullable
          : preferLlm as bool?,
    );
  }
}

extension $AssistantAskRequestCopyWith on AssistantAskRequest {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantAskRequest.copyWith(...)` or like so:`instanceOfAssistantAskRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantAskRequestCWProxy get copyWith =>
      _$AssistantAskRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantAskRequest _$AssistantAskRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AssistantAskRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['question']);
      final val = AssistantAskRequest(
        question: $checkedConvert('question', (v) => v as String),
        preferLlm: $checkedConvert('prefer_llm', (v) => v as bool? ?? false),
      );
      return val;
    }, fieldKeyMap: const {'preferLlm': 'prefer_llm'});

Map<String, dynamic> _$AssistantAskRequestToJson(
  AssistantAskRequest instance,
) => <String, dynamic>{
  'question': instance.question,
  'prefer_llm': ?instance.preferLlm,
};
