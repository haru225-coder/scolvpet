// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_chat_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantChatRequestCWProxy {
  AssistantChatRequest sessionId(String? sessionId);

  AssistantChatRequest message(String message);

  AssistantChatRequest preferLlm(bool? preferLlm);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantChatRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantChatRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantChatRequest call({
    String? sessionId,
    String message,
    bool? preferLlm,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantChatRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantChatRequest.copyWith.fieldName(...)`
class _$AssistantChatRequestCWProxyImpl
    implements _$AssistantChatRequestCWProxy {
  const _$AssistantChatRequestCWProxyImpl(this._value);

  final AssistantChatRequest _value;

  @override
  AssistantChatRequest sessionId(String? sessionId) =>
      this(sessionId: sessionId);

  @override
  AssistantChatRequest message(String message) => this(message: message);

  @override
  AssistantChatRequest preferLlm(bool? preferLlm) => this(preferLlm: preferLlm);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantChatRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantChatRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantChatRequest call({
    Object? sessionId = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? preferLlm = const $CopyWithPlaceholder(),
  }) {
    return AssistantChatRequest(
      sessionId: sessionId == const $CopyWithPlaceholder()
          ? _value.sessionId
          // ignore: cast_nullable_to_non_nullable
          : sessionId as String?,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
      preferLlm: preferLlm == const $CopyWithPlaceholder()
          ? _value.preferLlm
          // ignore: cast_nullable_to_non_nullable
          : preferLlm as bool?,
    );
  }
}

extension $AssistantChatRequestCopyWith on AssistantChatRequest {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantChatRequest.copyWith(...)` or like so:`instanceOfAssistantChatRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantChatRequestCWProxy get copyWith =>
      _$AssistantChatRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantChatRequest _$AssistantChatRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AssistantChatRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['message']);
    final val = AssistantChatRequest(
      sessionId: $checkedConvert('session_id', (v) => v as String?),
      message: $checkedConvert('message', (v) => v as String),
      preferLlm: $checkedConvert('prefer_llm', (v) => v as bool? ?? true),
    );
    return val;
  },
  fieldKeyMap: const {'sessionId': 'session_id', 'preferLlm': 'prefer_llm'},
);

Map<String, dynamic> _$AssistantChatRequestToJson(
  AssistantChatRequest instance,
) => <String, dynamic>{
  'session_id': ?instance.sessionId,
  'message': instance.message,
  'prefer_llm': ?instance.preferLlm,
};
