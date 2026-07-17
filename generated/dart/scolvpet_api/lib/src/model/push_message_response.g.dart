// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_message_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PushMessageResponseCWProxy {
  PushMessageResponse data(PushMessage data);

  PushMessageResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PushMessageResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PushMessageResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PushMessageResponse call({PushMessage data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPushMessageResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPushMessageResponse.copyWith.fieldName(...)`
class _$PushMessageResponseCWProxyImpl implements _$PushMessageResponseCWProxy {
  const _$PushMessageResponseCWProxyImpl(this._value);

  final PushMessageResponse _value;

  @override
  PushMessageResponse data(PushMessage data) => this(data: data);

  @override
  PushMessageResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PushMessageResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PushMessageResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PushMessageResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return PushMessageResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as PushMessage,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $PushMessageResponseCopyWith on PushMessageResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPushMessageResponse.copyWith(...)` or like so:`instanceOfPushMessageResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PushMessageResponseCWProxy get copyWith =>
      _$PushMessageResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushMessageResponse _$PushMessageResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PushMessageResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = PushMessageResponse(
        data: $checkedConvert(
          'data',
          (v) => PushMessage.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PushMessageResponseToJson(
  PushMessageResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
