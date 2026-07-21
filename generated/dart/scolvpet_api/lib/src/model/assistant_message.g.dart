// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_message.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantMessageCWProxy {
  AssistantMessage id(String id);

  AssistantMessage ownerId(String ownerId);

  AssistantMessage sessionId(String sessionId);

  AssistantMessage role(AssistantMessageRoleEnum role);

  AssistantMessage content(String content);

  AssistantMessage mode(AssistantMessageModeEnum? mode);

  AssistantMessage factsJson(List<Object>? factsJson);

  AssistantMessage createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantMessage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantMessage(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantMessage call({
    String id,
    String ownerId,
    String sessionId,
    AssistantMessageRoleEnum role,
    String content,
    AssistantMessageModeEnum? mode,
    List<Object>? factsJson,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantMessage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantMessage.copyWith.fieldName(...)`
class _$AssistantMessageCWProxyImpl implements _$AssistantMessageCWProxy {
  const _$AssistantMessageCWProxyImpl(this._value);

  final AssistantMessage _value;

  @override
  AssistantMessage id(String id) => this(id: id);

  @override
  AssistantMessage ownerId(String ownerId) => this(ownerId: ownerId);

  @override
  AssistantMessage sessionId(String sessionId) => this(sessionId: sessionId);

  @override
  AssistantMessage role(AssistantMessageRoleEnum role) => this(role: role);

  @override
  AssistantMessage content(String content) => this(content: content);

  @override
  AssistantMessage mode(AssistantMessageModeEnum? mode) => this(mode: mode);

  @override
  AssistantMessage factsJson(List<Object>? factsJson) =>
      this(factsJson: factsJson);

  @override
  AssistantMessage createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantMessage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantMessage(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantMessage call({
    Object? id = const $CopyWithPlaceholder(),
    Object? ownerId = const $CopyWithPlaceholder(),
    Object? sessionId = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? content = const $CopyWithPlaceholder(),
    Object? mode = const $CopyWithPlaceholder(),
    Object? factsJson = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return AssistantMessage(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      ownerId: ownerId == const $CopyWithPlaceholder()
          ? _value.ownerId
          // ignore: cast_nullable_to_non_nullable
          : ownerId as String,
      sessionId: sessionId == const $CopyWithPlaceholder()
          ? _value.sessionId
          // ignore: cast_nullable_to_non_nullable
          : sessionId as String,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as AssistantMessageRoleEnum,
      content: content == const $CopyWithPlaceholder()
          ? _value.content
          // ignore: cast_nullable_to_non_nullable
          : content as String,
      mode: mode == const $CopyWithPlaceholder()
          ? _value.mode
          // ignore: cast_nullable_to_non_nullable
          : mode as AssistantMessageModeEnum?,
      factsJson: factsJson == const $CopyWithPlaceholder()
          ? _value.factsJson
          // ignore: cast_nullable_to_non_nullable
          : factsJson as List<Object>?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $AssistantMessageCopyWith on AssistantMessage {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantMessage.copyWith(...)` or like so:`instanceOfAssistantMessage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantMessageCWProxy get copyWith => _$AssistantMessageCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantMessage _$AssistantMessageFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'AssistantMessage',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'owner_id',
            'session_id',
            'role',
            'content',
            'created_at',
          ],
        );
        final val = AssistantMessage(
          id: $checkedConvert('id', (v) => v as String),
          ownerId: $checkedConvert('owner_id', (v) => v as String),
          sessionId: $checkedConvert('session_id', (v) => v as String),
          role: $checkedConvert(
            'role',
            (v) => $enumDecode(_$AssistantMessageRoleEnumEnumMap, v),
          ),
          content: $checkedConvert('content', (v) => v as String),
          mode: $checkedConvert(
            'mode',
            (v) => $enumDecodeNullable(_$AssistantMessageModeEnumEnumMap, v),
          ),
          factsJson: $checkedConvert(
            'facts_json',
            (v) => (v as List<dynamic>?)?.map((e) => e as Object).toList(),
          ),
          createdAt: $checkedConvert(
            'created_at',
            (v) => DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'ownerId': 'owner_id',
        'sessionId': 'session_id',
        'factsJson': 'facts_json',
        'createdAt': 'created_at',
      },
    );

Map<String, dynamic> _$AssistantMessageToJson(AssistantMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'owner_id': instance.ownerId,
      'session_id': instance.sessionId,
      'role': _$AssistantMessageRoleEnumEnumMap[instance.role]!,
      'content': instance.content,
      'mode': ?_$AssistantMessageModeEnumEnumMap[instance.mode],
      'facts_json': ?instance.factsJson,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$AssistantMessageRoleEnumEnumMap = {
  AssistantMessageRoleEnum.user: 'user',
  AssistantMessageRoleEnum.assistant: 'assistant',
  AssistantMessageRoleEnum.system: 'system',
};

const _$AssistantMessageModeEnumEnumMap = {
  AssistantMessageModeEnum.rules: 'rules',
  AssistantMessageModeEnum.llm: 'llm',
};
