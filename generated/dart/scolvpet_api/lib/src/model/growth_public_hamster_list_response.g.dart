// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_public_hamster_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GrowthPublicHamsterListResponseCWProxy {
  GrowthPublicHamsterListResponse data(List<GrowthPublicHamster> data);

  GrowthPublicHamsterListResponse page(PageInfo? page);

  GrowthPublicHamsterListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrowthPublicHamsterListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrowthPublicHamsterListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  GrowthPublicHamsterListResponse call({
    List<GrowthPublicHamster> data,
    PageInfo? page,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGrowthPublicHamsterListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGrowthPublicHamsterListResponse.copyWith.fieldName(...)`
class _$GrowthPublicHamsterListResponseCWProxyImpl
    implements _$GrowthPublicHamsterListResponseCWProxy {
  const _$GrowthPublicHamsterListResponseCWProxyImpl(this._value);

  final GrowthPublicHamsterListResponse _value;

  @override
  GrowthPublicHamsterListResponse data(List<GrowthPublicHamster> data) =>
      this(data: data);

  @override
  GrowthPublicHamsterListResponse page(PageInfo? page) => this(page: page);

  @override
  GrowthPublicHamsterListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrowthPublicHamsterListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrowthPublicHamsterListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  GrowthPublicHamsterListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return GrowthPublicHamsterListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<GrowthPublicHamster>,
      page: page == const $CopyWithPlaceholder()
          ? _value.page
          // ignore: cast_nullable_to_non_nullable
          : page as PageInfo?,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $GrowthPublicHamsterListResponseCopyWith
    on GrowthPublicHamsterListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfGrowthPublicHamsterListResponse.copyWith(...)` or like so:`instanceOfGrowthPublicHamsterListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GrowthPublicHamsterListResponseCWProxy get copyWith =>
      _$GrowthPublicHamsterListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrowthPublicHamsterListResponse _$GrowthPublicHamsterListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('GrowthPublicHamsterListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = GrowthPublicHamsterListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => GrowthPublicHamster.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    page: $checkedConvert(
      'page',
      (v) => v == null ? null : PageInfo.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$GrowthPublicHamsterListResponseToJson(
  GrowthPublicHamsterListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'page': ?instance.page?.toJson(),
  'meta': instance.meta.toJson(),
};
