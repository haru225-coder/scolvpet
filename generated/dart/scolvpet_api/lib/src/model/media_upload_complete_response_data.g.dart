// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_upload_complete_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MediaUploadCompleteResponseDataCWProxy {
  MediaUploadCompleteResponseData media(MediaAsset media);

  MediaUploadCompleteResponseData processingJob(AsyncJob processingJob);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaUploadCompleteResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaUploadCompleteResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaUploadCompleteResponseData call({
    MediaAsset media,
    AsyncJob processingJob,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMediaUploadCompleteResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMediaUploadCompleteResponseData.copyWith.fieldName(...)`
class _$MediaUploadCompleteResponseDataCWProxyImpl
    implements _$MediaUploadCompleteResponseDataCWProxy {
  const _$MediaUploadCompleteResponseDataCWProxyImpl(this._value);

  final MediaUploadCompleteResponseData _value;

  @override
  MediaUploadCompleteResponseData media(MediaAsset media) => this(media: media);

  @override
  MediaUploadCompleteResponseData processingJob(AsyncJob processingJob) =>
      this(processingJob: processingJob);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaUploadCompleteResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaUploadCompleteResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaUploadCompleteResponseData call({
    Object? media = const $CopyWithPlaceholder(),
    Object? processingJob = const $CopyWithPlaceholder(),
  }) {
    return MediaUploadCompleteResponseData(
      media: media == const $CopyWithPlaceholder()
          ? _value.media
          // ignore: cast_nullable_to_non_nullable
          : media as MediaAsset,
      processingJob: processingJob == const $CopyWithPlaceholder()
          ? _value.processingJob
          // ignore: cast_nullable_to_non_nullable
          : processingJob as AsyncJob,
    );
  }
}

extension $MediaUploadCompleteResponseDataCopyWith
    on MediaUploadCompleteResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfMediaUploadCompleteResponseData.copyWith(...)` or like so:`instanceOfMediaUploadCompleteResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MediaUploadCompleteResponseDataCWProxy get copyWith =>
      _$MediaUploadCompleteResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaUploadCompleteResponseData _$MediaUploadCompleteResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'MediaUploadCompleteResponseData',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['media', 'processing_job']);
    final val = MediaUploadCompleteResponseData(
      media: $checkedConvert(
        'media',
        (v) => MediaAsset.fromJson(v as Map<String, dynamic>),
      ),
      processingJob: $checkedConvert(
        'processing_job',
        (v) => AsyncJob.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
  fieldKeyMap: const {'processingJob': 'processing_job'},
);

Map<String, dynamic> _$MediaUploadCompleteResponseDataToJson(
  MediaUploadCompleteResponseData instance,
) => <String, dynamic>{
  'media': instance.media.toJson(),
  'processing_job': instance.processingJob.toJson(),
};
