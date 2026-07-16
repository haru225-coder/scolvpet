// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_cover_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MediaCoverRequestCWProxy {
  MediaCoverRequest timeOffsetSeconds(num? timeOffsetSeconds);

  MediaCoverRequest mediaVariantId(String? mediaVariantId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaCoverRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaCoverRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaCoverRequest call({num? timeOffsetSeconds, String? mediaVariantId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMediaCoverRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMediaCoverRequest.copyWith.fieldName(...)`
class _$MediaCoverRequestCWProxyImpl implements _$MediaCoverRequestCWProxy {
  const _$MediaCoverRequestCWProxyImpl(this._value);

  final MediaCoverRequest _value;

  @override
  MediaCoverRequest timeOffsetSeconds(num? timeOffsetSeconds) =>
      this(timeOffsetSeconds: timeOffsetSeconds);

  @override
  MediaCoverRequest mediaVariantId(String? mediaVariantId) =>
      this(mediaVariantId: mediaVariantId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaCoverRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaCoverRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaCoverRequest call({
    Object? timeOffsetSeconds = const $CopyWithPlaceholder(),
    Object? mediaVariantId = const $CopyWithPlaceholder(),
  }) {
    return MediaCoverRequest(
      timeOffsetSeconds: timeOffsetSeconds == const $CopyWithPlaceholder()
          ? _value.timeOffsetSeconds
          // ignore: cast_nullable_to_non_nullable
          : timeOffsetSeconds as num?,
      mediaVariantId: mediaVariantId == const $CopyWithPlaceholder()
          ? _value.mediaVariantId
          // ignore: cast_nullable_to_non_nullable
          : mediaVariantId as String?,
    );
  }
}

extension $MediaCoverRequestCopyWith on MediaCoverRequest {
  /// Returns a callable class that can be used as follows: `instanceOfMediaCoverRequest.copyWith(...)` or like so:`instanceOfMediaCoverRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MediaCoverRequestCWProxy get copyWith =>
      _$MediaCoverRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaCoverRequest _$MediaCoverRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'MediaCoverRequest',
      json,
      ($checkedConvert) {
        final val = MediaCoverRequest(
          timeOffsetSeconds: $checkedConvert(
            'time_offset_seconds',
            (v) => v as num?,
          ),
          mediaVariantId: $checkedConvert(
            'media_variant_id',
            (v) => v as String?,
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'timeOffsetSeconds': 'time_offset_seconds',
        'mediaVariantId': 'media_variant_id',
      },
    );

Map<String, dynamic> _$MediaCoverRequestToJson(MediaCoverRequest instance) =>
    <String, dynamic>{
      'time_offset_seconds': ?instance.timeOffsetSeconds,
      'media_variant_id': ?instance.mediaVariantId,
    };
