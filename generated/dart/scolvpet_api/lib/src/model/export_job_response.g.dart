// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_job_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExportJobResponseCWProxy {
  ExportJobResponse data(ExportJob data);

  ExportJobResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExportJobResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExportJobResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ExportJobResponse call({ExportJob data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExportJobResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExportJobResponse.copyWith.fieldName(...)`
class _$ExportJobResponseCWProxyImpl implements _$ExportJobResponseCWProxy {
  const _$ExportJobResponseCWProxyImpl(this._value);

  final ExportJobResponse _value;

  @override
  ExportJobResponse data(ExportJob data) => this(data: data);

  @override
  ExportJobResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExportJobResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExportJobResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ExportJobResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return ExportJobResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as ExportJob,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $ExportJobResponseCopyWith on ExportJobResponse {
  /// Returns a callable class that can be used as follows: `instanceOfExportJobResponse.copyWith(...)` or like so:`instanceOfExportJobResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExportJobResponseCWProxy get copyWith =>
      _$ExportJobResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExportJobResponse _$ExportJobResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ExportJobResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = ExportJobResponse(
        data: $checkedConvert(
          'data',
          (v) => ExportJob.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ExportJobResponseToJson(ExportJobResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
