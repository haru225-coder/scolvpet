// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_job_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExportJobListResponseCWProxy {
  ExportJobListResponse data(List<ExportJob> data);

  ExportJobListResponse page(PageInfo page);

  ExportJobListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExportJobListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExportJobListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ExportJobListResponse call({
    List<ExportJob> data,
    PageInfo page,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExportJobListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExportJobListResponse.copyWith.fieldName(...)`
class _$ExportJobListResponseCWProxyImpl
    implements _$ExportJobListResponseCWProxy {
  const _$ExportJobListResponseCWProxyImpl(this._value);

  final ExportJobListResponse _value;

  @override
  ExportJobListResponse data(List<ExportJob> data) => this(data: data);

  @override
  ExportJobListResponse page(PageInfo page) => this(page: page);

  @override
  ExportJobListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExportJobListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExportJobListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ExportJobListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return ExportJobListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<ExportJob>,
      page: page == const $CopyWithPlaceholder()
          ? _value.page
          // ignore: cast_nullable_to_non_nullable
          : page as PageInfo,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $ExportJobListResponseCopyWith on ExportJobListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfExportJobListResponse.copyWith(...)` or like so:`instanceOfExportJobListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExportJobListResponseCWProxy get copyWith =>
      _$ExportJobListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExportJobListResponse _$ExportJobListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ExportJobListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'page', 'meta']);
  final val = ExportJobListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => ExportJob.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    page: $checkedConvert(
      'page',
      (v) => PageInfo.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ExportJobListResponseToJson(
  ExportJobListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'page': instance.page.toJson(),
  'meta': instance.meta.toJson(),
};
