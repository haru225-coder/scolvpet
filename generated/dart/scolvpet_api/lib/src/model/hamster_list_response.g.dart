// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hamster_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HamsterListResponseCWProxy {
  HamsterListResponse data(List<Hamster> data);

  HamsterListResponse page(PageInfo page);

  HamsterListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HamsterListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HamsterListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  HamsterListResponse call({
    List<Hamster> data,
    PageInfo page,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHamsterListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHamsterListResponse.copyWith.fieldName(...)`
class _$HamsterListResponseCWProxyImpl implements _$HamsterListResponseCWProxy {
  const _$HamsterListResponseCWProxyImpl(this._value);

  final HamsterListResponse _value;

  @override
  HamsterListResponse data(List<Hamster> data) => this(data: data);

  @override
  HamsterListResponse page(PageInfo page) => this(page: page);

  @override
  HamsterListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HamsterListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HamsterListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  HamsterListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return HamsterListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<Hamster>,
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

extension $HamsterListResponseCopyWith on HamsterListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfHamsterListResponse.copyWith(...)` or like so:`instanceOfHamsterListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HamsterListResponseCWProxy get copyWith =>
      _$HamsterListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HamsterListResponse _$HamsterListResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('HamsterListResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'page', 'meta']);
      final val = HamsterListResponse(
        data: $checkedConvert(
          'data',
          (v) => (v as List<dynamic>)
              .map((e) => Hamster.fromJson(e as Map<String, dynamic>))
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

Map<String, dynamic> _$HamsterListResponseToJson(
  HamsterListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'page': instance.page.toJson(),
  'meta': instance.meta.toJson(),
};
