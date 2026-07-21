// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_message_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantMessageListResponseCWProxy {
  AssistantMessageListResponse data(List<AssistantMessage> data);

  AssistantMessageListResponse page(Map<String, Object>? page);

  AssistantMessageListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantMessageListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantMessageListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantMessageListResponse call({
    List<AssistantMessage> data,
    Map<String, Object>? page,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantMessageListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantMessageListResponse.copyWith.fieldName(...)`
class _$AssistantMessageListResponseCWProxyImpl
    implements _$AssistantMessageListResponseCWProxy {
  const _$AssistantMessageListResponseCWProxyImpl(this._value);

  final AssistantMessageListResponse _value;

  @override
  AssistantMessageListResponse data(List<AssistantMessage> data) =>
      this(data: data);

  @override
  AssistantMessageListResponse page(Map<String, Object>? page) =>
      this(page: page);

  @override
  AssistantMessageListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantMessageListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantMessageListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantMessageListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return AssistantMessageListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<AssistantMessage>,
      page: page == const $CopyWithPlaceholder()
          ? _value.page
          // ignore: cast_nullable_to_non_nullable
          : page as Map<String, Object>?,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $AssistantMessageListResponseCopyWith
    on AssistantMessageListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantMessageListResponse.copyWith(...)` or like so:`instanceOfAssistantMessageListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantMessageListResponseCWProxy get copyWith =>
      _$AssistantMessageListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantMessageListResponse _$AssistantMessageListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssistantMessageListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = AssistantMessageListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => AssistantMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    page: $checkedConvert(
      'page',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$AssistantMessageListResponseToJson(
  AssistantMessageListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'page': ?instance.page,
  'meta': instance.meta.toJson(),
};
