// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_chat_action.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantChatActionCWProxy {
  AssistantChatAction actionId(String? actionId);

  AssistantChatAction type(String type);

  AssistantChatAction label(String label);

  AssistantChatAction summary(String summary);

  AssistantChatAction requiresConfirmation(bool requiresConfirmation);

  AssistantChatAction payload(Map<String, Object> payload);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantChatAction(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantChatAction(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantChatAction call({
    String? actionId,
    String type,
    String label,
    String summary,
    bool requiresConfirmation,
    Map<String, Object> payload,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantChatAction.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantChatAction.copyWith.fieldName(...)`
class _$AssistantChatActionCWProxyImpl implements _$AssistantChatActionCWProxy {
  const _$AssistantChatActionCWProxyImpl(this._value);

  final AssistantChatAction _value;

  @override
  AssistantChatAction actionId(String? actionId) => this(actionId: actionId);

  @override
  AssistantChatAction type(String type) => this(type: type);

  @override
  AssistantChatAction label(String label) => this(label: label);

  @override
  AssistantChatAction summary(String summary) => this(summary: summary);

  @override
  AssistantChatAction requiresConfirmation(bool requiresConfirmation) =>
      this(requiresConfirmation: requiresConfirmation);

  @override
  AssistantChatAction payload(Map<String, Object> payload) =>
      this(payload: payload);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantChatAction(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantChatAction(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantChatAction call({
    Object? actionId = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? label = const $CopyWithPlaceholder(),
    Object? summary = const $CopyWithPlaceholder(),
    Object? requiresConfirmation = const $CopyWithPlaceholder(),
    Object? payload = const $CopyWithPlaceholder(),
  }) {
    return AssistantChatAction(
      actionId: actionId == const $CopyWithPlaceholder()
          ? _value.actionId
          // ignore: cast_nullable_to_non_nullable
          : actionId as String?,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as String,
      label: label == const $CopyWithPlaceholder()
          ? _value.label
          // ignore: cast_nullable_to_non_nullable
          : label as String,
      summary: summary == const $CopyWithPlaceholder()
          ? _value.summary
          // ignore: cast_nullable_to_non_nullable
          : summary as String,
      requiresConfirmation: requiresConfirmation == const $CopyWithPlaceholder()
          ? _value.requiresConfirmation
          // ignore: cast_nullable_to_non_nullable
          : requiresConfirmation as bool,
      payload: payload == const $CopyWithPlaceholder()
          ? _value.payload
          // ignore: cast_nullable_to_non_nullable
          : payload as Map<String, Object>,
    );
  }
}

extension $AssistantChatActionCopyWith on AssistantChatAction {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantChatAction.copyWith(...)` or like so:`instanceOfAssistantChatAction.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantChatActionCWProxy get copyWith =>
      _$AssistantChatActionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantChatAction _$AssistantChatActionFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'AssistantChatAction',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'type',
            'label',
            'summary',
            'requires_confirmation',
            'payload',
          ],
        );
        final val = AssistantChatAction(
          actionId: $checkedConvert('action_id', (v) => v as String?),
          type: $checkedConvert('type', (v) => v as String),
          label: $checkedConvert('label', (v) => v as String),
          summary: $checkedConvert('summary', (v) => v as String),
          requiresConfirmation: $checkedConvert(
            'requires_confirmation',
            (v) => v as bool,
          ),
          payload: $checkedConvert(
            'payload',
            (v) => (v as Map<String, dynamic>).map(
              (k, e) => MapEntry(k, e as Object),
            ),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'actionId': 'action_id',
        'requiresConfirmation': 'requires_confirmation',
      },
    );

Map<String, dynamic> _$AssistantChatActionToJson(
  AssistantChatAction instance,
) => <String, dynamic>{
  'action_id': ?instance.actionId,
  'type': instance.type,
  'label': instance.label,
  'summary': instance.summary,
  'requires_confirmation': instance.requiresConfirmation,
  'payload': instance.payload,
};
