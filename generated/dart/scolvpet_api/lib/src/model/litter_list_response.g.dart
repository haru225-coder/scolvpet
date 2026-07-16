// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'litter_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LitterListResponseCWProxy {
  LitterListResponse data(List<Litter> data);

  LitterListResponse page(PageInfo page);

  LitterListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LitterListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LitterListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  LitterListResponse call({
    List<Litter> data,
    PageInfo page,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLitterListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLitterListResponse.copyWith.fieldName(...)`
class _$LitterListResponseCWProxyImpl implements _$LitterListResponseCWProxy {
  const _$LitterListResponseCWProxyImpl(this._value);

  final LitterListResponse _value;

  @override
  LitterListResponse data(List<Litter> data) => this(data: data);

  @override
  LitterListResponse page(PageInfo page) => this(page: page);

  @override
  LitterListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LitterListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LitterListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  LitterListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return LitterListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<Litter>,
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

extension $LitterListResponseCopyWith on LitterListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfLitterListResponse.copyWith(...)` or like so:`instanceOfLitterListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LitterListResponseCWProxy get copyWith =>
      _$LitterListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LitterListResponse _$LitterListResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LitterListResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'page', 'meta']);
      final val = LitterListResponse(
        data: $checkedConvert(
          'data',
          (v) => (v as List<dynamic>)
              .map((e) => Litter.fromJson(e as Map<String, dynamic>))
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

Map<String, dynamic> _$LitterListResponseToJson(LitterListResponse instance) =>
    <String, dynamic>{
      'data': instance.data.map((e) => e.toJson()).toList(),
      'page': instance.page.toJson(),
      'meta': instance.meta.toJson(),
    };
