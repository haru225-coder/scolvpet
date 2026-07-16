// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_upload_create_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportUploadCreateRequestCWProxy {
  ImportUploadCreateRequest fileName(String fileName);

  ImportUploadCreateRequest sizeBytes(int sizeBytes);

  ImportUploadCreateRequest sha256(String sha256);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportUploadCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportUploadCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportUploadCreateRequest call({
    String fileName,
    int sizeBytes,
    String sha256,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportUploadCreateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportUploadCreateRequest.copyWith.fieldName(...)`
class _$ImportUploadCreateRequestCWProxyImpl
    implements _$ImportUploadCreateRequestCWProxy {
  const _$ImportUploadCreateRequestCWProxyImpl(this._value);

  final ImportUploadCreateRequest _value;

  @override
  ImportUploadCreateRequest fileName(String fileName) =>
      this(fileName: fileName);

  @override
  ImportUploadCreateRequest sizeBytes(int sizeBytes) =>
      this(sizeBytes: sizeBytes);

  @override
  ImportUploadCreateRequest sha256(String sha256) => this(sha256: sha256);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportUploadCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportUploadCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportUploadCreateRequest call({
    Object? fileName = const $CopyWithPlaceholder(),
    Object? sizeBytes = const $CopyWithPlaceholder(),
    Object? sha256 = const $CopyWithPlaceholder(),
  }) {
    return ImportUploadCreateRequest(
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

extension $ImportUploadCreateRequestCopyWith on ImportUploadCreateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfImportUploadCreateRequest.copyWith(...)` or like so:`instanceOfImportUploadCreateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportUploadCreateRequestCWProxy get copyWith =>
      _$ImportUploadCreateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportUploadCreateRequest _$ImportUploadCreateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ImportUploadCreateRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['file_name', 'size_bytes', 'sha256']);
    final val = ImportUploadCreateRequest(
      fileName: $checkedConvert('file_name', (v) => v as String),
      sizeBytes: $checkedConvert('size_bytes', (v) => (v as num).toInt()),
      sha256: $checkedConvert('sha256', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {'fileName': 'file_name', 'sizeBytes': 'size_bytes'},
);

Map<String, dynamic> _$ImportUploadCreateRequestToJson(
  ImportUploadCreateRequest instance,
) => <String, dynamic>{
  'file_name': instance.fileName,
  'size_bytes': instance.sizeBytes,
  'sha256': instance.sha256,
};
