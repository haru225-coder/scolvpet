// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_row_result_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportRowResultListResponseCWProxy {
  ImportRowResultListResponse data(List<ImportRowResult> data);

  ImportRowResultListResponse page(PageInfo page);

  ImportRowResultListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportRowResultListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportRowResultListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportRowResultListResponse call({
    List<ImportRowResult> data,
    PageInfo page,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportRowResultListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportRowResultListResponse.copyWith.fieldName(...)`
class _$ImportRowResultListResponseCWProxyImpl
    implements _$ImportRowResultListResponseCWProxy {
  const _$ImportRowResultListResponseCWProxyImpl(this._value);

  final ImportRowResultListResponse _value;

  @override
  ImportRowResultListResponse data(List<ImportRowResult> data) =>
      this(data: data);

  @override
  ImportRowResultListResponse page(PageInfo page) => this(page: page);

  @override
  ImportRowResultListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportRowResultListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportRowResultListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportRowResultListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return ImportRowResultListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<ImportRowResult>,
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

extension $ImportRowResultListResponseCopyWith on ImportRowResultListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfImportRowResultListResponse.copyWith(...)` or like so:`instanceOfImportRowResultListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportRowResultListResponseCWProxy get copyWith =>
      _$ImportRowResultListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportRowResultListResponse _$ImportRowResultListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ImportRowResultListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'page', 'meta']);
  final val = ImportRowResultListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => ImportRowResult.fromJson(e as Map<String, dynamic>))
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

Map<String, dynamic> _$ImportRowResultListResponseToJson(
  ImportRowResultListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'page': instance.page.toJson(),
  'meta': instance.meta.toJson(),
};
