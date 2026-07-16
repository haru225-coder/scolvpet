// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedigree_parentage_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PedigreeParentageListResponseCWProxy {
  PedigreeParentageListResponse data(List<PedigreeParentage> data);

  PedigreeParentageListResponse page(PageInfo page);

  PedigreeParentageListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PedigreeParentageListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PedigreeParentageListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PedigreeParentageListResponse call({
    List<PedigreeParentage> data,
    PageInfo page,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPedigreeParentageListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPedigreeParentageListResponse.copyWith.fieldName(...)`
class _$PedigreeParentageListResponseCWProxyImpl
    implements _$PedigreeParentageListResponseCWProxy {
  const _$PedigreeParentageListResponseCWProxyImpl(this._value);

  final PedigreeParentageListResponse _value;

  @override
  PedigreeParentageListResponse data(List<PedigreeParentage> data) =>
      this(data: data);

  @override
  PedigreeParentageListResponse page(PageInfo page) => this(page: page);

  @override
  PedigreeParentageListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PedigreeParentageListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PedigreeParentageListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PedigreeParentageListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return PedigreeParentageListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<PedigreeParentage>,
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

extension $PedigreeParentageListResponseCopyWith
    on PedigreeParentageListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPedigreeParentageListResponse.copyWith(...)` or like so:`instanceOfPedigreeParentageListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PedigreeParentageListResponseCWProxy get copyWith =>
      _$PedigreeParentageListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PedigreeParentageListResponse _$PedigreeParentageListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PedigreeParentageListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'page', 'meta']);
  final val = PedigreeParentageListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => PedigreeParentage.fromJson(e as Map<String, dynamic>))
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

Map<String, dynamic> _$PedigreeParentageListResponseToJson(
  PedigreeParentageListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'page': instance.page.toJson(),
  'meta': instance.meta.toJson(),
};
