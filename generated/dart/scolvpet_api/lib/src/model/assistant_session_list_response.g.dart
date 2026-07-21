// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_session_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantSessionListResponseCWProxy {
  AssistantSessionListResponse data(List<AssistantSession> data);

  AssistantSessionListResponse page(Map<String, Object>? page);

  AssistantSessionListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantSessionListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantSessionListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantSessionListResponse call({
    List<AssistantSession> data,
    Map<String, Object>? page,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantSessionListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantSessionListResponse.copyWith.fieldName(...)`
class _$AssistantSessionListResponseCWProxyImpl
    implements _$AssistantSessionListResponseCWProxy {
  const _$AssistantSessionListResponseCWProxyImpl(this._value);

  final AssistantSessionListResponse _value;

  @override
  AssistantSessionListResponse data(List<AssistantSession> data) =>
      this(data: data);

  @override
  AssistantSessionListResponse page(Map<String, Object>? page) =>
      this(page: page);

  @override
  AssistantSessionListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantSessionListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantSessionListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantSessionListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return AssistantSessionListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<AssistantSession>,
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

extension $AssistantSessionListResponseCopyWith
    on AssistantSessionListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantSessionListResponse.copyWith(...)` or like so:`instanceOfAssistantSessionListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantSessionListResponseCWProxy get copyWith =>
      _$AssistantSessionListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantSessionListResponse _$AssistantSessionListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssistantSessionListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = AssistantSessionListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => AssistantSession.fromJson(e as Map<String, dynamic>))
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

Map<String, dynamic> _$AssistantSessionListResponseToJson(
  AssistantSessionListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'page': ?instance.page,
  'meta': instance.meta.toJson(),
};
