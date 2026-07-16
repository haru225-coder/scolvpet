// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_processing_retry_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MediaProcessingRetryResponseDataCWProxy {
  MediaProcessingRetryResponseData media(MediaAsset media);

  MediaProcessingRetryResponseData job(AsyncJob job);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaProcessingRetryResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaProcessingRetryResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaProcessingRetryResponseData call({MediaAsset media, AsyncJob job});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMediaProcessingRetryResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMediaProcessingRetryResponseData.copyWith.fieldName(...)`
class _$MediaProcessingRetryResponseDataCWProxyImpl
    implements _$MediaProcessingRetryResponseDataCWProxy {
  const _$MediaProcessingRetryResponseDataCWProxyImpl(this._value);

  final MediaProcessingRetryResponseData _value;

  @override
  MediaProcessingRetryResponseData media(MediaAsset media) =>
      this(media: media);

  @override
  MediaProcessingRetryResponseData job(AsyncJob job) => this(job: job);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaProcessingRetryResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaProcessingRetryResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaProcessingRetryResponseData call({
    Object? media = const $CopyWithPlaceholder(),
    Object? job = const $CopyWithPlaceholder(),
  }) {
    return MediaProcessingRetryResponseData(
      media: media == const $CopyWithPlaceholder()
          ? _value.media
          // ignore: cast_nullable_to_non_nullable
          : media as MediaAsset,
      job: job == const $CopyWithPlaceholder()
          ? _value.job
          // ignore: cast_nullable_to_non_nullable
          : job as AsyncJob,
    );
  }
}

extension $MediaProcessingRetryResponseDataCopyWith
    on MediaProcessingRetryResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfMediaProcessingRetryResponseData.copyWith(...)` or like so:`instanceOfMediaProcessingRetryResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MediaProcessingRetryResponseDataCWProxy get copyWith =>
      _$MediaProcessingRetryResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaProcessingRetryResponseData _$MediaProcessingRetryResponseDataFromJson(
  Map<String, dynamic> json,
) =>
    $checkedCreate('MediaProcessingRetryResponseData', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['media', 'job']);
      final val = MediaProcessingRetryResponseData(
        media: $checkedConvert(
          'media',
          (v) => MediaAsset.fromJson(v as Map<String, dynamic>),
        ),
        job: $checkedConvert(
          'job',
          (v) => AsyncJob.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MediaProcessingRetryResponseDataToJson(
  MediaProcessingRetryResponseData instance,
) => <String, dynamic>{
  'media': instance.media.toJson(),
  'job': instance.job.toJson(),
};
