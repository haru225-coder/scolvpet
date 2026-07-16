// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_upload_presign_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MediaUploadPresignResponseCWProxy {
  MediaUploadPresignResponse data(UploadSession data);

  MediaUploadPresignResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaUploadPresignResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaUploadPresignResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaUploadPresignResponse call({UploadSession data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMediaUploadPresignResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMediaUploadPresignResponse.copyWith.fieldName(...)`
class _$MediaUploadPresignResponseCWProxyImpl
    implements _$MediaUploadPresignResponseCWProxy {
  const _$MediaUploadPresignResponseCWProxyImpl(this._value);

  final MediaUploadPresignResponse _value;

  @override
  MediaUploadPresignResponse data(UploadSession data) => this(data: data);

  @override
  MediaUploadPresignResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaUploadPresignResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaUploadPresignResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaUploadPresignResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return MediaUploadPresignResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as UploadSession,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $MediaUploadPresignResponseCopyWith on MediaUploadPresignResponse {
  /// Returns a callable class that can be used as follows: `instanceOfMediaUploadPresignResponse.copyWith(...)` or like so:`instanceOfMediaUploadPresignResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MediaUploadPresignResponseCWProxy get copyWith =>
      _$MediaUploadPresignResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaUploadPresignResponse _$MediaUploadPresignResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MediaUploadPresignResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = MediaUploadPresignResponse(
    data: $checkedConvert(
      'data',
      (v) => UploadSession.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$MediaUploadPresignResponseToJson(
  MediaUploadPresignResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
