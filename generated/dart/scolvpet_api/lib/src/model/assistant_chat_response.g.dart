// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_chat_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantChatResponseCWProxy {
  AssistantChatResponse data(AssistantChatResult data);

  AssistantChatResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantChatResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantChatResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantChatResponse call({AssistantChatResult data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantChatResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantChatResponse.copyWith.fieldName(...)`
class _$AssistantChatResponseCWProxyImpl
    implements _$AssistantChatResponseCWProxy {
  const _$AssistantChatResponseCWProxyImpl(this._value);

  final AssistantChatResponse _value;

  @override
  AssistantChatResponse data(AssistantChatResult data) => this(data: data);

  @override
  AssistantChatResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantChatResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantChatResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantChatResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return AssistantChatResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as AssistantChatResult,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $AssistantChatResponseCopyWith on AssistantChatResponse {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantChatResponse.copyWith(...)` or like so:`instanceOfAssistantChatResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantChatResponseCWProxy get copyWith =>
      _$AssistantChatResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantChatResponse _$AssistantChatResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssistantChatResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = AssistantChatResponse(
    data: $checkedConvert(
      'data',
      (v) => AssistantChatResult.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$AssistantChatResponseToJson(
  AssistantChatResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
