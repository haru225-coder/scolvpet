// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_upload_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportUploadResponseCWProxy {
  ImportUploadResponse data(UploadSession data);

  ImportUploadResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportUploadResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportUploadResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportUploadResponse call({UploadSession data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportUploadResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportUploadResponse.copyWith.fieldName(...)`
class _$ImportUploadResponseCWProxyImpl
    implements _$ImportUploadResponseCWProxy {
  const _$ImportUploadResponseCWProxyImpl(this._value);

  final ImportUploadResponse _value;

  @override
  ImportUploadResponse data(UploadSession data) => this(data: data);

  @override
  ImportUploadResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportUploadResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportUploadResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportUploadResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return ImportUploadResponse(
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

extension $ImportUploadResponseCopyWith on ImportUploadResponse {
  /// Returns a callable class that can be used as follows: `instanceOfImportUploadResponse.copyWith(...)` or like so:`instanceOfImportUploadResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportUploadResponseCWProxy get copyWith =>
      _$ImportUploadResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportUploadResponse _$ImportUploadResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ImportUploadResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = ImportUploadResponse(
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

Map<String, dynamic> _$ImportUploadResponseToJson(
  ImportUploadResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
