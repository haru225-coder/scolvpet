// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_job_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportJobListResponseCWProxy {
  ImportJobListResponse data(List<ImportJob> data);

  ImportJobListResponse page(PageInfo page);

  ImportJobListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportJobListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportJobListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportJobListResponse call({
    List<ImportJob> data,
    PageInfo page,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportJobListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportJobListResponse.copyWith.fieldName(...)`
class _$ImportJobListResponseCWProxyImpl
    implements _$ImportJobListResponseCWProxy {
  const _$ImportJobListResponseCWProxyImpl(this._value);

  final ImportJobListResponse _value;

  @override
  ImportJobListResponse data(List<ImportJob> data) => this(data: data);

  @override
  ImportJobListResponse page(PageInfo page) => this(page: page);

  @override
  ImportJobListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportJobListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportJobListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportJobListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return ImportJobListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<ImportJob>,
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

extension $ImportJobListResponseCopyWith on ImportJobListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfImportJobListResponse.copyWith(...)` or like so:`instanceOfImportJobListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportJobListResponseCWProxy get copyWith =>
      _$ImportJobListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportJobListResponse _$ImportJobListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ImportJobListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'page', 'meta']);
  final val = ImportJobListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => ImportJob.fromJson(e as Map<String, dynamic>))
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

Map<String, dynamic> _$ImportJobListResponseToJson(
  ImportJobListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'page': instance.page.toJson(),
  'meta': instance.meta.toJson(),
};
