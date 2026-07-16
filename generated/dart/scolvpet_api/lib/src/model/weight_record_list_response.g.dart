// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_record_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeightRecordListResponseCWProxy {
  WeightRecordListResponse data(List<WeightRecord> data);

  WeightRecordListResponse page(PageInfo page);

  WeightRecordListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightRecordListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightRecordListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightRecordListResponse call({
    List<WeightRecord> data,
    PageInfo page,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeightRecordListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeightRecordListResponse.copyWith.fieldName(...)`
class _$WeightRecordListResponseCWProxyImpl
    implements _$WeightRecordListResponseCWProxy {
  const _$WeightRecordListResponseCWProxyImpl(this._value);

  final WeightRecordListResponse _value;

  @override
  WeightRecordListResponse data(List<WeightRecord> data) => this(data: data);

  @override
  WeightRecordListResponse page(PageInfo page) => this(page: page);

  @override
  WeightRecordListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightRecordListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightRecordListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightRecordListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return WeightRecordListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<WeightRecord>,
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

extension $WeightRecordListResponseCopyWith on WeightRecordListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfWeightRecordListResponse.copyWith(...)` or like so:`instanceOfWeightRecordListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeightRecordListResponseCWProxy get copyWith =>
      _$WeightRecordListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightRecordListResponse _$WeightRecordListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WeightRecordListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'page', 'meta']);
  final val = WeightRecordListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => WeightRecord.fromJson(e as Map<String, dynamic>))
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

Map<String, dynamic> _$WeightRecordListResponseToJson(
  WeightRecordListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'page': instance.page.toJson(),
  'meta': instance.meta.toJson(),
};
