// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_message_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PushMessageListResponseCWProxy {
  PushMessageListResponse data(List<PushMessage> data);

  PushMessageListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PushMessageListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PushMessageListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PushMessageListResponse call({List<PushMessage> data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPushMessageListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPushMessageListResponse.copyWith.fieldName(...)`
class _$PushMessageListResponseCWProxyImpl
    implements _$PushMessageListResponseCWProxy {
  const _$PushMessageListResponseCWProxyImpl(this._value);

  final PushMessageListResponse _value;

  @override
  PushMessageListResponse data(List<PushMessage> data) => this(data: data);

  @override
  PushMessageListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PushMessageListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PushMessageListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PushMessageListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return PushMessageListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<PushMessage>,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $PushMessageListResponseCopyWith on PushMessageListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPushMessageListResponse.copyWith(...)` or like so:`instanceOfPushMessageListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PushMessageListResponseCWProxy get copyWith =>
      _$PushMessageListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushMessageListResponse _$PushMessageListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PushMessageListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = PushMessageListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => PushMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$PushMessageListResponseToJson(
  PushMessageListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'meta': instance.meta.toJson(),
};
