// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_upload_complete_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MediaUploadCompleteResponseCWProxy {
  MediaUploadCompleteResponse data(MediaUploadCompleteResponseData data);

  MediaUploadCompleteResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaUploadCompleteResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaUploadCompleteResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaUploadCompleteResponse call({
    MediaUploadCompleteResponseData data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMediaUploadCompleteResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMediaUploadCompleteResponse.copyWith.fieldName(...)`
class _$MediaUploadCompleteResponseCWProxyImpl
    implements _$MediaUploadCompleteResponseCWProxy {
  const _$MediaUploadCompleteResponseCWProxyImpl(this._value);

  final MediaUploadCompleteResponse _value;

  @override
  MediaUploadCompleteResponse data(MediaUploadCompleteResponseData data) =>
      this(data: data);

  @override
  MediaUploadCompleteResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaUploadCompleteResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaUploadCompleteResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaUploadCompleteResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return MediaUploadCompleteResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as MediaUploadCompleteResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $MediaUploadCompleteResponseCopyWith on MediaUploadCompleteResponse {
  /// Returns a callable class that can be used as follows: `instanceOfMediaUploadCompleteResponse.copyWith(...)` or like so:`instanceOfMediaUploadCompleteResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MediaUploadCompleteResponseCWProxy get copyWith =>
      _$MediaUploadCompleteResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaUploadCompleteResponse _$MediaUploadCompleteResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MediaUploadCompleteResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = MediaUploadCompleteResponse(
    data: $checkedConvert(
      'data',
      (v) =>
          MediaUploadCompleteResponseData.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$MediaUploadCompleteResponseToJson(
  MediaUploadCompleteResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
