// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_link_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DownloadLinkResponseDataCWProxy {
  DownloadLinkResponseData downloadUrl(String downloadUrl);

  DownloadLinkResponseData expiresAt(DateTime expiresAt);

  DownloadLinkResponseData fileName(String fileName);

  DownloadLinkResponseData sizeBytes(int sizeBytes);

  DownloadLinkResponseData sha256(String sha256);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DownloadLinkResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DownloadLinkResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  DownloadLinkResponseData call({
    String downloadUrl,
    DateTime expiresAt,
    String fileName,
    int sizeBytes,
    String sha256,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDownloadLinkResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDownloadLinkResponseData.copyWith.fieldName(...)`
class _$DownloadLinkResponseDataCWProxyImpl
    implements _$DownloadLinkResponseDataCWProxy {
  const _$DownloadLinkResponseDataCWProxyImpl(this._value);

  final DownloadLinkResponseData _value;

  @override
  DownloadLinkResponseData downloadUrl(String downloadUrl) =>
      this(downloadUrl: downloadUrl);

  @override
  DownloadLinkResponseData expiresAt(DateTime expiresAt) =>
      this(expiresAt: expiresAt);

  @override
  DownloadLinkResponseData fileName(String fileName) =>
      this(fileName: fileName);

  @override
  DownloadLinkResponseData sizeBytes(int sizeBytes) =>
      this(sizeBytes: sizeBytes);

  @override
  DownloadLinkResponseData sha256(String sha256) => this(sha256: sha256);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DownloadLinkResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DownloadLinkResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  DownloadLinkResponseData call({
    Object? downloadUrl = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
    Object? fileName = const $CopyWithPlaceholder(),
    Object? sizeBytes = const $CopyWithPlaceholder(),
    Object? sha256 = const $CopyWithPlaceholder(),
  }) {
    return DownloadLinkResponseData(
      downloadUrl: downloadUrl == const $CopyWithPlaceholder()
          ? _value.downloadUrl
          // ignore: cast_nullable_to_non_nullable
          : downloadUrl as String,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime,
      fileName: fileName == const $CopyWithPlaceholder()
          ? _value.fileName
          // ignore: cast_nullable_to_non_nullable
          : fileName as String,
      sizeBytes: sizeBytes == const $CopyWithPlaceholder()
          ? _value.sizeBytes
          // ignore: cast_nullable_to_non_nullable
          : sizeBytes as int,
      sha256: sha256 == const $CopyWithPlaceholder()
          ? _value.sha256
          // ignore: cast_nullable_to_non_nullable
          : sha256 as String,
    );
  }
}

extension $DownloadLinkResponseDataCopyWith on DownloadLinkResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfDownloadLinkResponseData.copyWith(...)` or like so:`instanceOfDownloadLinkResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DownloadLinkResponseDataCWProxy get copyWith =>
      _$DownloadLinkResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DownloadLinkResponseData _$DownloadLinkResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'DownloadLinkResponseData',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'download_url',
        'expires_at',
        'file_name',
        'size_bytes',
        'sha256',
      ],
    );
    final val = DownloadLinkResponseData(
      downloadUrl: $checkedConvert('download_url', (v) => v as String),
      expiresAt: $checkedConvert(
        'expires_at',
        (v) => DateTime.parse(v as String),
      ),
      fileName: $checkedConvert('file_name', (v) => v as String),
      sizeBytes: $checkedConvert('size_bytes', (v) => (v as num).toInt()),
      sha256: $checkedConvert('sha256', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'downloadUrl': 'download_url',
    'expiresAt': 'expires_at',
    'fileName': 'file_name',
    'sizeBytes': 'size_bytes',
  },
);

Map<String, dynamic> _$DownloadLinkResponseDataToJson(
  DownloadLinkResponseData instance,
) => <String, dynamic>{
  'download_url': instance.downloadUrl,
  'expires_at': instance.expiresAt.toIso8601String(),
  'file_name': instance.fileName,
  'size_bytes': instance.sizeBytes,
  'sha256': instance.sha256,
};
