// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_processing_retry_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MediaProcessingRetryResponseCWProxy {
  MediaProcessingRetryResponse data(MediaProcessingRetryResponseData data);

  MediaProcessingRetryResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaProcessingRetryResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaProcessingRetryResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaProcessingRetryResponse call({
    MediaProcessingRetryResponseData data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMediaProcessingRetryResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMediaProcessingRetryResponse.copyWith.fieldName(...)`
class _$MediaProcessingRetryResponseCWProxyImpl
    implements _$MediaProcessingRetryResponseCWProxy {
  const _$MediaProcessingRetryResponseCWProxyImpl(this._value);

  final MediaProcessingRetryResponse _value;

  @override
  MediaProcessingRetryResponse data(MediaProcessingRetryResponseData data) =>
      this(data: data);

  @override
  MediaProcessingRetryResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaProcessingRetryResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaProcessingRetryResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaProcessingRetryResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return MediaProcessingRetryResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as MediaProcessingRetryResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $MediaProcessingRetryResponseCopyWith
    on MediaProcessingRetryResponse {
  /// Returns a callable class that can be used as follows: `instanceOfMediaProcessingRetryResponse.copyWith(...)` or like so:`instanceOfMediaProcessingRetryResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MediaProcessingRetryResponseCWProxy get copyWith =>
      _$MediaProcessingRetryResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaProcessingRetryResponse _$MediaProcessingRetryResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MediaProcessingRetryResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = MediaProcessingRetryResponse(
    data: $checkedConvert(
      'data',
      (v) =>
          MediaProcessingRetryResponseData.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$MediaProcessingRetryResponseToJson(
  MediaProcessingRetryResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
