// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_push_message_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreatePushMessageRequestCWProxy {
  CreatePushMessageRequest title(String title);

  CreatePushMessageRequest body(String body);

  CreatePushMessageRequest data(Map<String, Object>? data);

  CreatePushMessageRequest targetDeviceId(String? targetDeviceId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreatePushMessageRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreatePushMessageRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreatePushMessageRequest call({
    String title,
    String body,
    Map<String, Object>? data,
    String? targetDeviceId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreatePushMessageRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreatePushMessageRequest.copyWith.fieldName(...)`
class _$CreatePushMessageRequestCWProxyImpl
    implements _$CreatePushMessageRequestCWProxy {
  const _$CreatePushMessageRequestCWProxyImpl(this._value);

  final CreatePushMessageRequest _value;

  @override
  CreatePushMessageRequest title(String title) => this(title: title);

  @override
  CreatePushMessageRequest body(String body) => this(body: body);

  @override
  CreatePushMessageRequest data(Map<String, Object>? data) => this(data: data);

  @override
  CreatePushMessageRequest targetDeviceId(String? targetDeviceId) =>
      this(targetDeviceId: targetDeviceId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreatePushMessageRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreatePushMessageRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreatePushMessageRequest call({
    Object? title = const $CopyWithPlaceholder(),
    Object? body = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
    Object? targetDeviceId = const $CopyWithPlaceholder(),
  }) {
    return CreatePushMessageRequest(
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String,
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as Map<String, Object>?,
      targetDeviceId: targetDeviceId == const $CopyWithPlaceholder()
          ? _value.targetDeviceId
          // ignore: cast_nullable_to_non_nullable
          : targetDeviceId as String?,
    );
  }
}

extension $CreatePushMessageRequestCopyWith on CreatePushMessageRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreatePushMessageRequest.copyWith(...)` or like so:`instanceOfCreatePushMessageRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreatePushMessageRequestCWProxy get copyWith =>
      _$CreatePushMessageRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePushMessageRequest _$CreatePushMessageRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CreatePushMessageRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['title', 'body']);
    final val = CreatePushMessageRequest(
      title: $checkedConvert('title', (v) => v as String),
      body: $checkedConvert('body', (v) => v as String),
      data: $checkedConvert(
        'data',
        (v) => (v as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, e as Object),
        ),
      ),
      targetDeviceId: $checkedConvert('target_device_id', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {'targetDeviceId': 'target_device_id'},
);

Map<String, dynamic> _$CreatePushMessageRequestToJson(
  CreatePushMessageRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'body': instance.body,
  'data': ?instance.data,
  'target_device_id': ?instance.targetDeviceId,
};
