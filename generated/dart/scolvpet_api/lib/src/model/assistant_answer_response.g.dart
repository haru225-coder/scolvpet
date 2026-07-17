// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_answer_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantAnswerResponseCWProxy {
  AssistantAnswerResponse data(AssistantAnswer data);

  AssistantAnswerResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantAnswerResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantAnswerResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantAnswerResponse call({AssistantAnswer data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantAnswerResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantAnswerResponse.copyWith.fieldName(...)`
class _$AssistantAnswerResponseCWProxyImpl
    implements _$AssistantAnswerResponseCWProxy {
  const _$AssistantAnswerResponseCWProxyImpl(this._value);

  final AssistantAnswerResponse _value;

  @override
  AssistantAnswerResponse data(AssistantAnswer data) => this(data: data);

  @override
  AssistantAnswerResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantAnswerResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantAnswerResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantAnswerResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return AssistantAnswerResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as AssistantAnswer,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $AssistantAnswerResponseCopyWith on AssistantAnswerResponse {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantAnswerResponse.copyWith(...)` or like so:`instanceOfAssistantAnswerResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantAnswerResponseCWProxy get copyWith =>
      _$AssistantAnswerResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantAnswerResponse _$AssistantAnswerResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssistantAnswerResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = AssistantAnswerResponse(
    data: $checkedConvert(
      'data',
      (v) => AssistantAnswer.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$AssistantAnswerResponseToJson(
  AssistantAnswerResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
