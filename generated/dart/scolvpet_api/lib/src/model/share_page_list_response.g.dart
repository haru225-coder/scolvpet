// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_page_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SharePageListResponseCWProxy {
  SharePageListResponse data(List<SharePage> data);

  SharePageListResponse page(PageInfo page);

  SharePageListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SharePageListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SharePageListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SharePageListResponse call({
    List<SharePage> data,
    PageInfo page,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSharePageListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSharePageListResponse.copyWith.fieldName(...)`
class _$SharePageListResponseCWProxyImpl
    implements _$SharePageListResponseCWProxy {
  const _$SharePageListResponseCWProxyImpl(this._value);

  final SharePageListResponse _value;

  @override
  SharePageListResponse data(List<SharePage> data) => this(data: data);

  @override
  SharePageListResponse page(PageInfo page) => this(page: page);

  @override
  SharePageListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SharePageListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SharePageListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SharePageListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return SharePageListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<SharePage>,
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

extension $SharePageListResponseCopyWith on SharePageListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfSharePageListResponse.copyWith(...)` or like so:`instanceOfSharePageListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SharePageListResponseCWProxy get copyWith =>
      _$SharePageListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharePageListResponse _$SharePageListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SharePageListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'page', 'meta']);
  final val = SharePageListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => SharePage.fromJson(e as Map<String, dynamic>))
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

Map<String, dynamic> _$SharePageListResponseToJson(
  SharePageListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'page': instance.page.toJson(),
  'meta': instance.meta.toJson(),
};
