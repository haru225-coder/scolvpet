// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enclosure_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EnclosureListResponseCWProxy {
  EnclosureListResponse data(List<Enclosure> data);

  EnclosureListResponse page(PageInfo page);

  EnclosureListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureListResponse call({
    List<Enclosure> data,
    PageInfo page,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEnclosureListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEnclosureListResponse.copyWith.fieldName(...)`
class _$EnclosureListResponseCWProxyImpl
    implements _$EnclosureListResponseCWProxy {
  const _$EnclosureListResponseCWProxyImpl(this._value);

  final EnclosureListResponse _value;

  @override
  EnclosureListResponse data(List<Enclosure> data) => this(data: data);

  @override
  EnclosureListResponse page(PageInfo page) => this(page: page);

  @override
  EnclosureListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return EnclosureListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<Enclosure>,
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

extension $EnclosureListResponseCopyWith on EnclosureListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfEnclosureListResponse.copyWith(...)` or like so:`instanceOfEnclosureListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EnclosureListResponseCWProxy get copyWith =>
      _$EnclosureListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnclosureListResponse _$EnclosureListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('EnclosureListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'page', 'meta']);
  final val = EnclosureListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => Enclosure.fromJson(e as Map<String, dynamic>))
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

Map<String, dynamic> _$EnclosureListResponseToJson(
  EnclosureListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'page': instance.page.toJson(),
  'meta': instance.meta.toJson(),
};
