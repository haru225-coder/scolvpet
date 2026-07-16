// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enclosure_stay_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EnclosureStayListResponseCWProxy {
  EnclosureStayListResponse data(List<EnclosureStay> data);

  EnclosureStayListResponse page(PageInfo page);

  EnclosureStayListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureStayListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureStayListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureStayListResponse call({
    List<EnclosureStay> data,
    PageInfo page,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEnclosureStayListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEnclosureStayListResponse.copyWith.fieldName(...)`
class _$EnclosureStayListResponseCWProxyImpl
    implements _$EnclosureStayListResponseCWProxy {
  const _$EnclosureStayListResponseCWProxyImpl(this._value);

  final EnclosureStayListResponse _value;

  @override
  EnclosureStayListResponse data(List<EnclosureStay> data) => this(data: data);

  @override
  EnclosureStayListResponse page(PageInfo page) => this(page: page);

  @override
  EnclosureStayListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureStayListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureStayListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureStayListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return EnclosureStayListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<EnclosureStay>,
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

extension $EnclosureStayListResponseCopyWith on EnclosureStayListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfEnclosureStayListResponse.copyWith(...)` or like so:`instanceOfEnclosureStayListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EnclosureStayListResponseCWProxy get copyWith =>
      _$EnclosureStayListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnclosureStayListResponse _$EnclosureStayListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('EnclosureStayListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'page', 'meta']);
  final val = EnclosureStayListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => EnclosureStay.fromJson(e as Map<String, dynamic>))
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

Map<String, dynamic> _$EnclosureStayListResponseToJson(
  EnclosureStayListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'page': instance.page.toJson(),
  'meta': instance.meta.toJson(),
};
