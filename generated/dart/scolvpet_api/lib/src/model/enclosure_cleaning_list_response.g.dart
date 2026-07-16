// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enclosure_cleaning_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EnclosureCleaningListResponseCWProxy {
  EnclosureCleaningListResponse data(List<EnclosureCleaning> data);

  EnclosureCleaningListResponse page(PageInfo page);

  EnclosureCleaningListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureCleaningListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureCleaningListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureCleaningListResponse call({
    List<EnclosureCleaning> data,
    PageInfo page,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEnclosureCleaningListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEnclosureCleaningListResponse.copyWith.fieldName(...)`
class _$EnclosureCleaningListResponseCWProxyImpl
    implements _$EnclosureCleaningListResponseCWProxy {
  const _$EnclosureCleaningListResponseCWProxyImpl(this._value);

  final EnclosureCleaningListResponse _value;

  @override
  EnclosureCleaningListResponse data(List<EnclosureCleaning> data) =>
      this(data: data);

  @override
  EnclosureCleaningListResponse page(PageInfo page) => this(page: page);

  @override
  EnclosureCleaningListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureCleaningListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureCleaningListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureCleaningListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return EnclosureCleaningListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<EnclosureCleaning>,
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

extension $EnclosureCleaningListResponseCopyWith
    on EnclosureCleaningListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfEnclosureCleaningListResponse.copyWith(...)` or like so:`instanceOfEnclosureCleaningListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EnclosureCleaningListResponseCWProxy get copyWith =>
      _$EnclosureCleaningListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnclosureCleaningListResponse _$EnclosureCleaningListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('EnclosureCleaningListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'page', 'meta']);
  final val = EnclosureCleaningListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => EnclosureCleaning.fromJson(e as Map<String, dynamic>))
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

Map<String, dynamic> _$EnclosureCleaningListResponseToJson(
  EnclosureCleaningListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'page': instance.page.toJson(),
  'meta': instance.meta.toJson(),
};
