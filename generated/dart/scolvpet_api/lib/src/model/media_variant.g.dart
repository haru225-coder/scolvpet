// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_variant.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MediaVariantCWProxy {
  MediaVariant id(String id);

  MediaVariant kind(MediaVariantKindEnum kind);

  MediaVariant status(MediaVariantStatusEnum status);

  MediaVariant url(String? url);

  MediaVariant width(int? width);

  MediaVariant height(int? height);

  MediaVariant durationSeconds(num? durationSeconds);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaVariant(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaVariant(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaVariant call({
    String id,
    MediaVariantKindEnum kind,
    MediaVariantStatusEnum status,
    String? url,
    int? width,
    int? height,
    num? durationSeconds,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMediaVariant.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMediaVariant.copyWith.fieldName(...)`
class _$MediaVariantCWProxyImpl implements _$MediaVariantCWProxy {
  const _$MediaVariantCWProxyImpl(this._value);

  final MediaVariant _value;

  @override
  MediaVariant id(String id) => this(id: id);

  @override
  MediaVariant kind(MediaVariantKindEnum kind) => this(kind: kind);

  @override
  MediaVariant status(MediaVariantStatusEnum status) => this(status: status);

  @override
  MediaVariant url(String? url) => this(url: url);

  @override
  MediaVariant width(int? width) => this(width: width);

  @override
  MediaVariant height(int? height) => this(height: height);

  @override
  MediaVariant durationSeconds(num? durationSeconds) =>
      this(durationSeconds: durationSeconds);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaVariant(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaVariant(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaVariant call({
    Object? id = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? width = const $CopyWithPlaceholder(),
    Object? height = const $CopyWithPlaceholder(),
    Object? durationSeconds = const $CopyWithPlaceholder(),
  }) {
    return MediaVariant(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as MediaVariantKindEnum,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as MediaVariantStatusEnum,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String?,
      width: width == const $CopyWithPlaceholder()
          ? _value.width
          // ignore: cast_nullable_to_non_nullable
          : width as int?,
      height: height == const $CopyWithPlaceholder()
          ? _value.height
          // ignore: cast_nullable_to_non_nullable
          : height as int?,
      durationSeconds: durationSeconds == const $CopyWithPlaceholder()
          ? _value.durationSeconds
          // ignore: cast_nullable_to_non_nullable
          : durationSeconds as num?,
    );
  }
}

extension $MediaVariantCopyWith on MediaVariant {
  /// Returns a callable class that can be used as follows: `instanceOfMediaVariant.copyWith(...)` or like so:`instanceOfMediaVariant.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MediaVariantCWProxy get copyWith => _$MediaVariantCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaVariant _$MediaVariantFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MediaVariant', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'kind', 'status']);
      final val = MediaVariant(
        id: $checkedConvert('id', (v) => v as String),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$MediaVariantKindEnumEnumMap, v),
        ),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$MediaVariantStatusEnumEnumMap, v),
        ),
        url: $checkedConvert('url', (v) => v as String?),
        width: $checkedConvert('width', (v) => (v as num?)?.toInt()),
        height: $checkedConvert('height', (v) => (v as num?)?.toInt()),
        durationSeconds: $checkedConvert('duration_seconds', (v) => v as num?),
      );
      return val;
    }, fieldKeyMap: const {'durationSeconds': 'duration_seconds'});

Map<String, dynamic> _$MediaVariantToJson(MediaVariant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': _$MediaVariantKindEnumEnumMap[instance.kind]!,
      'status': _$MediaVariantStatusEnumEnumMap[instance.status]!,
      'url': ?instance.url,
      'width': ?instance.width,
      'height': ?instance.height,
      'duration_seconds': ?instance.durationSeconds,
    };

const _$MediaVariantKindEnumEnumMap = {
  MediaVariantKindEnum.thumbnail: 'thumbnail',
  MediaVariantKindEnum.preview: 'preview',
  MediaVariantKindEnum.edited: 'edited',
  MediaVariantKindEnum.video720p: 'video_720p',
  MediaVariantKindEnum.video1080p: 'video_1080p',
  MediaVariantKindEnum.cover: 'cover',
};

const _$MediaVariantStatusEnumEnumMap = {
  MediaVariantStatusEnum.queued: 'queued',
  MediaVariantStatusEnum.processing: 'processing',
  MediaVariantStatusEnum.ready: 'ready',
  MediaVariantStatusEnum.failed: 'failed',
};
