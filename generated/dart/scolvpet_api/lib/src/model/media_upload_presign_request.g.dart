// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_upload_presign_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MediaUploadPresignRequestCWProxy {
  MediaUploadPresignRequest fileName(String fileName);

  MediaUploadPresignRequest contentType(
    MediaUploadPresignRequestContentTypeEnum contentType,
  );

  MediaUploadPresignRequest sizeBytes(int sizeBytes);

  MediaUploadPresignRequest sha256(String sha256);

  MediaUploadPresignRequest purpose(
    MediaUploadPresignRequestPurposeEnum? purpose,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaUploadPresignRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaUploadPresignRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaUploadPresignRequest call({
    String fileName,
    MediaUploadPresignRequestContentTypeEnum contentType,
    int sizeBytes,
    String sha256,
    MediaUploadPresignRequestPurposeEnum? purpose,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMediaUploadPresignRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMediaUploadPresignRequest.copyWith.fieldName(...)`
class _$MediaUploadPresignRequestCWProxyImpl
    implements _$MediaUploadPresignRequestCWProxy {
  const _$MediaUploadPresignRequestCWProxyImpl(this._value);

  final MediaUploadPresignRequest _value;

  @override
  MediaUploadPresignRequest fileName(String fileName) =>
      this(fileName: fileName);

  @override
  MediaUploadPresignRequest contentType(
    MediaUploadPresignRequestContentTypeEnum contentType,
  ) => this(contentType: contentType);

  @override
  MediaUploadPresignRequest sizeBytes(int sizeBytes) =>
      this(sizeBytes: sizeBytes);

  @override
  MediaUploadPresignRequest sha256(String sha256) => this(sha256: sha256);

  @override
  MediaUploadPresignRequest purpose(
    MediaUploadPresignRequestPurposeEnum? purpose,
  ) => this(purpose: purpose);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaUploadPresignRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaUploadPresignRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaUploadPresignRequest call({
    Object? fileName = const $CopyWithPlaceholder(),
    Object? contentType = const $CopyWithPlaceholder(),
    Object? sizeBytes = const $CopyWithPlaceholder(),
    Object? sha256 = const $CopyWithPlaceholder(),
    Object? purpose = const $CopyWithPlaceholder(),
  }) {
    return MediaUploadPresignRequest(
      fileName: fileName == const $CopyWithPlaceholder()
          ? _value.fileName
          // ignore: cast_nullable_to_non_nullable
          : fileName as String,
      contentType: contentType == const $CopyWithPlaceholder()
          ? _value.contentType
          // ignore: cast_nullable_to_non_nullable
          : contentType as MediaUploadPresignRequestContentTypeEnum,
      sizeBytes: sizeBytes == const $CopyWithPlaceholder()
          ? _value.sizeBytes
          // ignore: cast_nullable_to_non_nullable
          : sizeBytes as int,
      sha256: sha256 == const $CopyWithPlaceholder()
          ? _value.sha256
          // ignore: cast_nullable_to_non_nullable
          : sha256 as String,
      purpose: purpose == const $CopyWithPlaceholder()
          ? _value.purpose
          // ignore: cast_nullable_to_non_nullable
          : purpose as MediaUploadPresignRequestPurposeEnum?,
    );
  }
}

extension $MediaUploadPresignRequestCopyWith on MediaUploadPresignRequest {
  /// Returns a callable class that can be used as follows: `instanceOfMediaUploadPresignRequest.copyWith(...)` or like so:`instanceOfMediaUploadPresignRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MediaUploadPresignRequestCWProxy get copyWith =>
      _$MediaUploadPresignRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaUploadPresignRequest _$MediaUploadPresignRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'MediaUploadPresignRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['file_name', 'content_type', 'size_bytes', 'sha256'],
    );
    final val = MediaUploadPresignRequest(
      fileName: $checkedConvert('file_name', (v) => v as String),
      contentType: $checkedConvert(
        'content_type',
        (v) =>
            $enumDecode(_$MediaUploadPresignRequestContentTypeEnumEnumMap, v),
      ),
      sizeBytes: $checkedConvert('size_bytes', (v) => (v as num).toInt()),
      sha256: $checkedConvert('sha256', (v) => v as String),
      purpose: $checkedConvert(
        'purpose',
        (v) => $enumDecodeNullable(
          _$MediaUploadPresignRequestPurposeEnumEnumMap,
          v,
        ),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'fileName': 'file_name',
    'contentType': 'content_type',
    'sizeBytes': 'size_bytes',
  },
);

Map<String, dynamic> _$MediaUploadPresignRequestToJson(
  MediaUploadPresignRequest instance,
) => <String, dynamic>{
  'file_name': instance.fileName,
  'content_type':
      _$MediaUploadPresignRequestContentTypeEnumEnumMap[instance.contentType]!,
  'size_bytes': instance.sizeBytes,
  'sha256': instance.sha256,
  'purpose': ?_$MediaUploadPresignRequestPurposeEnumEnumMap[instance.purpose],
};

const _$MediaUploadPresignRequestContentTypeEnumEnumMap = {
  MediaUploadPresignRequestContentTypeEnum.imageSlashJpeg: 'image/jpeg',
  MediaUploadPresignRequestContentTypeEnum.imageSlashPng: 'image/png',
  MediaUploadPresignRequestContentTypeEnum.imageSlashWebp: 'image/webp',
  MediaUploadPresignRequestContentTypeEnum.videoSlashMp4: 'video/mp4',
  MediaUploadPresignRequestContentTypeEnum.videoSlashQuicktime:
      'video/quicktime',
};

const _$MediaUploadPresignRequestPurposeEnumEnumMap = {
  MediaUploadPresignRequestPurposeEnum.hamsterProfile: 'hamster_profile',
  MediaUploadPresignRequestPurposeEnum.litterTimeline: 'litter_timeline',
  MediaUploadPresignRequestPurposeEnum.healthRecord: 'health_record',
  MediaUploadPresignRequestPurposeEnum.pairingObservation:
      'pairing_observation',
  MediaUploadPresignRequestPurposeEnum.share: 'share',
  MediaUploadPresignRequestPurposeEnum.other: 'other',
};
