// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_job_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportJobResponseCWProxy {
  ImportJobResponse data(ImportJob data);

  ImportJobResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportJobResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportJobResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportJobResponse call({ImportJob data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportJobResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportJobResponse.copyWith.fieldName(...)`
class _$ImportJobResponseCWProxyImpl implements _$ImportJobResponseCWProxy {
  const _$ImportJobResponseCWProxyImpl(this._value);

  final ImportJobResponse _value;

  @override
  ImportJobResponse data(ImportJob data) => this(data: data);

  @override
  ImportJobResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportJobResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportJobResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportJobResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return ImportJobResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as ImportJob,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $ImportJobResponseCopyWith on ImportJobResponse {
  /// Returns a callable class that can be used as follows: `instanceOfImportJobResponse.copyWith(...)` or like so:`instanceOfImportJobResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportJobResponseCWProxy get copyWith =>
      _$ImportJobResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportJobResponse _$ImportJobResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ImportJobResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = ImportJobResponse(
        data: $checkedConvert(
          'data',
          (v) => ImportJob.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ImportJobResponseToJson(ImportJobResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
