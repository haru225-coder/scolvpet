// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_upload_complete_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MediaUploadCompleteRequestCWProxy {
  MediaUploadCompleteRequest objectEtag(String objectEtag);

  MediaUploadCompleteRequest sizeBytes(int sizeBytes);

  MediaUploadCompleteRequest sha256(String sha256);

  MediaUploadCompleteRequest capturedAt(DateTime? capturedAt);

  MediaUploadCompleteRequest timezone(String? timezone);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaUploadCompleteRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaUploadCompleteRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaUploadCompleteRequest call({
    String objectEtag,
    int sizeBytes,
    String sha256,
    DateTime? capturedAt,
    String? timezone,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMediaUploadCompleteRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMediaUploadCompleteRequest.copyWith.fieldName(...)`
class _$MediaUploadCompleteRequestCWProxyImpl
    implements _$MediaUploadCompleteRequestCWProxy {
  const _$MediaUploadCompleteRequestCWProxyImpl(this._value);

  final MediaUploadCompleteRequest _value;

  @override
  MediaUploadCompleteRequest objectEtag(String objectEtag) =>
      this(objectEtag: objectEtag);

  @override
  MediaUploadCompleteRequest sizeBytes(int sizeBytes) =>
      this(sizeBytes: sizeBytes);

  @override
  MediaUploadCompleteRequest sha256(String sha256) => this(sha256: sha256);

  @override
  MediaUploadCompleteRequest capturedAt(DateTime? capturedAt) =>
      this(capturedAt: capturedAt);

  @override
  MediaUploadCompleteRequest timezone(String? timezone) =>
      this(timezone: timezone);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaUploadCompleteRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaUploadCompleteRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaUploadCompleteRequest call({
    Object? objectEtag = const $CopyWithPlaceholder(),
    Object? sizeBytes = const $CopyWithPlaceholder(),
    Object? sha256 = const $CopyWithPlaceholder(),
    Object? capturedAt = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
  }) {
    return MediaUploadCompleteRequest(
      objectEtag: objectEtag == const $CopyWithPlaceholder()
          ? _value.objectEtag
          // ignore: cast_nullable_to_non_nullable
          : objectEtag as String,
      sizeBytes: sizeBytes == const $CopyWithPlaceholder()
          ? _value.sizeBytes
          // ignore: cast_nullable_to_non_nullable
          : sizeBytes as int,
      sha256: sha256 == const $CopyWithPlaceholder()
          ? _value.sha256
          // ignore: cast_nullable_to_non_nullable
          : sha256 as String,
      capturedAt: capturedAt == const $CopyWithPlaceholder()
          ? _value.capturedAt
          // ignore: cast_nullable_to_non_nullable
          : capturedAt as DateTime?,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String?,
    );
  }
}

extension $MediaUploadCompleteRequestCopyWith on MediaUploadCompleteRequest {
  /// Returns a callable class that can be used as follows: `instanceOfMediaUploadCompleteRequest.copyWith(...)` or like so:`instanceOfMediaUploadCompleteRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MediaUploadCompleteRequestCWProxy get copyWith =>
      _$MediaUploadCompleteRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaUploadCompleteRequest _$MediaUploadCompleteRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'MediaUploadCompleteRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['object_etag', 'size_bytes', 'sha256'],
    );
    final val = MediaUploadCompleteRequest(
      objectEtag: $checkedConvert('object_etag', (v) => v as String),
      sizeBytes: $checkedConvert('size_bytes', (v) => (v as num).toInt()),
      sha256: $checkedConvert('sha256', (v) => v as String),
      capturedAt: $checkedConvert(
        'captured_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      timezone: $checkedConvert('timezone', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'objectEtag': 'object_etag',
    'sizeBytes': 'size_bytes',
    'capturedAt': 'captured_at',
  },
);

Map<String, dynamic> _$MediaUploadCompleteRequestToJson(
  MediaUploadCompleteRequest instance,
) => <String, dynamic>{
  'object_etag': instance.objectEtag,
  'size_bytes': instance.sizeBytes,
  'sha256': instance.sha256,
  'captured_at': ?instance.capturedAt?.toIso8601String(),
  'timezone': ?instance.timezone,
};
