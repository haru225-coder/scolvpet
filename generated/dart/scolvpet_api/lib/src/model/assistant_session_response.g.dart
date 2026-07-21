// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_session_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantSessionResponseCWProxy {
  AssistantSessionResponse data(AssistantSession data);

  AssistantSessionResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantSessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantSessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantSessionResponse call({AssistantSession data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantSessionResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantSessionResponse.copyWith.fieldName(...)`
class _$AssistantSessionResponseCWProxyImpl
    implements _$AssistantSessionResponseCWProxy {
  const _$AssistantSessionResponseCWProxyImpl(this._value);

  final AssistantSessionResponse _value;

  @override
  AssistantSessionResponse data(AssistantSession data) => this(data: data);

  @override
  AssistantSessionResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantSessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantSessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantSessionResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return AssistantSessionResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as AssistantSession,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $AssistantSessionResponseCopyWith on AssistantSessionResponse {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantSessionResponse.copyWith(...)` or like so:`instanceOfAssistantSessionResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantSessionResponseCWProxy get copyWith =>
      _$AssistantSessionResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantSessionResponse _$AssistantSessionResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssistantSessionResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = AssistantSessionResponse(
    data: $checkedConvert(
      'data',
      (v) => AssistantSession.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$AssistantSessionResponseToJson(
  AssistantSessionResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
