// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_asset.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MediaAssetCWProxy {
  MediaAsset id(String id);

  MediaAsset ownerId(String ownerId);

  MediaAsset mediaType(MediaAssetMediaTypeEnum mediaType);

  MediaAsset contentType(String contentType);

  MediaAsset sizeBytes(int sizeBytes);

  MediaAsset sha256(String sha256);

  MediaAsset status(MediaAssetStatusEnum status);

  MediaAsset originalUrl(String? originalUrl);

  MediaAsset coverVariantId(String? coverVariantId);

  MediaAsset variants(List<MediaVariant> variants);

  MediaAsset version(int version);

  MediaAsset createdAt(DateTime createdAt);

  MediaAsset updatedAt(DateTime updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaAsset(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaAsset(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaAsset call({
    String id,
    String ownerId,
    MediaAssetMediaTypeEnum mediaType,
    String contentType,
    int sizeBytes,
    String sha256,
    MediaAssetStatusEnum status,
    String? originalUrl,
    String? coverVariantId,
    List<MediaVariant> variants,
    int version,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMediaAsset.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMediaAsset.copyWith.fieldName(...)`
class _$MediaAssetCWProxyImpl implements _$MediaAssetCWProxy {
  const _$MediaAssetCWProxyImpl(this._value);

  final MediaAsset _value;

  @override
  MediaAsset id(String id) => this(id: id);

  @override
  MediaAsset ownerId(String ownerId) => this(ownerId: ownerId);

  @override
  MediaAsset mediaType(MediaAssetMediaTypeEnum mediaType) =>
      this(mediaType: mediaType);

  @override
  MediaAsset contentType(String contentType) => this(contentType: contentType);

  @override
  MediaAsset sizeBytes(int sizeBytes) => this(sizeBytes: sizeBytes);

  @override
  MediaAsset sha256(String sha256) => this(sha256: sha256);

  @override
  MediaAsset status(MediaAssetStatusEnum status) => this(status: status);

  @override
  MediaAsset originalUrl(String? originalUrl) => this(originalUrl: originalUrl);

  @override
  MediaAsset coverVariantId(String? coverVariantId) =>
      this(coverVariantId: coverVariantId);

  @override
  MediaAsset variants(List<MediaVariant> variants) => this(variants: variants);

  @override
  MediaAsset version(int version) => this(version: version);

  @override
  MediaAsset createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  MediaAsset updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaAsset(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaAsset(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaAsset call({
    Object? id = const $CopyWithPlaceholder(),
    Object? ownerId = const $CopyWithPlaceholder(),
    Object? mediaType = const $CopyWithPlaceholder(),
    Object? contentType = const $CopyWithPlaceholder(),
    Object? sizeBytes = const $CopyWithPlaceholder(),
    Object? sha256 = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? originalUrl = const $CopyWithPlaceholder(),
    Object? coverVariantId = const $CopyWithPlaceholder(),
    Object? variants = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return MediaAsset(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      ownerId: ownerId == const $CopyWithPlaceholder()
          ? _value.ownerId
          // ignore: cast_nullable_to_non_nullable
          : ownerId as String,
      mediaType: mediaType == const $CopyWithPlaceholder()
          ? _value.mediaType
          // ignore: cast_nullable_to_non_nullable
          : mediaType as MediaAssetMediaTypeEnum,
      contentType: contentType == const $CopyWithPlaceholder()
          ? _value.contentType
          // ignore: cast_nullable_to_non_nullable
          : contentType as String,
      sizeBytes: sizeBytes == const $CopyWithPlaceholder()
          ? _value.sizeBytes
          // ignore: cast_nullable_to_non_nullable
          : sizeBytes as int,
      sha256: sha256 == const $CopyWithPlaceholder()
          ? _value.sha256
          // ignore: cast_nullable_to_non_nullable
          : sha256 as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as MediaAssetStatusEnum,
      originalUrl: originalUrl == const $CopyWithPlaceholder()
          ? _value.originalUrl
          // ignore: cast_nullable_to_non_nullable
          : originalUrl as String?,
      coverVariantId: coverVariantId == const $CopyWithPlaceholder()
          ? _value.coverVariantId
          // ignore: cast_nullable_to_non_nullable
          : coverVariantId as String?,
      variants: variants == const $CopyWithPlaceholder()
          ? _value.variants
          // ignore: cast_nullable_to_non_nullable
          : variants as List<MediaVariant>,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
    );
  }
}

extension $MediaAssetCopyWith on MediaAsset {
  /// Returns a callable class that can be used as follows: `instanceOfMediaAsset.copyWith(...)` or like so:`instanceOfMediaAsset.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MediaAssetCWProxy get copyWith => _$MediaAssetCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaAsset _$MediaAssetFromJson(Map<String, dynamic> json) => $checkedCreate(
  'MediaAsset',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'owner_id',
        'media_type',
        'content_type',
        'size_bytes',
        'sha256',
        'status',
        'variants',
        'version',
        'created_at',
        'updated_at',
      ],
    );
    final val = MediaAsset(
      id: $checkedConvert('id', (v) => v as String),
      ownerId: $checkedConvert('owner_id', (v) => v as String),
      mediaType: $checkedConvert(
        'media_type',
        (v) => $enumDecode(_$MediaAssetMediaTypeEnumEnumMap, v),
      ),
      contentType: $checkedConvert('content_type', (v) => v as String),
      sizeBytes: $checkedConvert('size_bytes', (v) => (v as num).toInt()),
      sha256: $checkedConvert('sha256', (v) => v as String),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$MediaAssetStatusEnumEnumMap, v),
      ),
      originalUrl: $checkedConvert('original_url', (v) => v as String?),
      coverVariantId: $checkedConvert('cover_variant_id', (v) => v as String?),
      variants: $checkedConvert(
        'variants',
        (v) => (v as List<dynamic>)
            .map((e) => MediaVariant.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      version: $checkedConvert('version', (v) => (v as num).toInt()),
      createdAt: $checkedConvert(
        'created_at',
        (v) => DateTime.parse(v as String),
      ),
      updatedAt: $checkedConvert(
        'updated_at',
        (v) => DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'ownerId': 'owner_id',
    'mediaType': 'media_type',
    'contentType': 'content_type',
    'sizeBytes': 'size_bytes',
    'originalUrl': 'original_url',
    'coverVariantId': 'cover_variant_id',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
  },
);

Map<String, dynamic> _$MediaAssetToJson(MediaAsset instance) =>
    <String, dynamic>{
      'id': instance.id,
      'owner_id': instance.ownerId,
      'media_type': _$MediaAssetMediaTypeEnumEnumMap[instance.mediaType]!,
      'content_type': instance.contentType,
      'size_bytes': instance.sizeBytes,
      'sha256': instance.sha256,
      'status': _$MediaAssetStatusEnumEnumMap[instance.status]!,
      'original_url': ?instance.originalUrl,
      'cover_variant_id': ?instance.coverVariantId,
      'variants': instance.variants.map((e) => e.toJson()).toList(),
      'version': instance.version,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$MediaAssetMediaTypeEnumEnumMap = {
  MediaAssetMediaTypeEnum.image: 'image',
  MediaAssetMediaTypeEnum.video: 'video',
};

const _$MediaAssetStatusEnumEnumMap = {
  MediaAssetStatusEnum.processing: 'processing',
  MediaAssetStatusEnum.ready: 'ready',
  MediaAssetStatusEnum.failed: 'failed',
};
