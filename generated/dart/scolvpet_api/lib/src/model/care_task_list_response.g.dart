// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'care_task_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CareTaskListResponseCWProxy {
  CareTaskListResponse data(List<CareTask> data);

  CareTaskListResponse page(PageInfo page);

  CareTaskListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CareTaskListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CareTaskListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CareTaskListResponse call({
    List<CareTask> data,
    PageInfo page,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCareTaskListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCareTaskListResponse.copyWith.fieldName(...)`
class _$CareTaskListResponseCWProxyImpl
    implements _$CareTaskListResponseCWProxy {
  const _$CareTaskListResponseCWProxyImpl(this._value);

  final CareTaskListResponse _value;

  @override
  CareTaskListResponse data(List<CareTask> data) => this(data: data);

  @override
  CareTaskListResponse page(PageInfo page) => this(page: page);

  @override
  CareTaskListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CareTaskListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CareTaskListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CareTaskListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return CareTaskListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<CareTask>,
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

extension $CareTaskListResponseCopyWith on CareTaskListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfCareTaskListResponse.copyWith(...)` or like so:`instanceOfCareTaskListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CareTaskListResponseCWProxy get copyWith =>
      _$CareTaskListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CareTaskListResponse _$CareTaskListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CareTaskListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'page', 'meta']);
  final val = CareTaskListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => CareTask.fromJson(e as Map<String, dynamic>))
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

Map<String, dynamic> _$CareTaskListResponseToJson(
  CareTaskListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'page': instance.page.toJson(),
  'meta': instance.meta.toJson(),
};
