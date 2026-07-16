// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_record_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HealthRecordListResponseCWProxy {
  HealthRecordListResponse data(List<HealthRecord> data);

  HealthRecordListResponse page(PageInfo page);

  HealthRecordListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HealthRecordListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HealthRecordListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  HealthRecordListResponse call({
    List<HealthRecord> data,
    PageInfo page,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHealthRecordListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHealthRecordListResponse.copyWith.fieldName(...)`
class _$HealthRecordListResponseCWProxyImpl
    implements _$HealthRecordListResponseCWProxy {
  const _$HealthRecordListResponseCWProxyImpl(this._value);

  final HealthRecordListResponse _value;

  @override
  HealthRecordListResponse data(List<HealthRecord> data) => this(data: data);

  @override
  HealthRecordListResponse page(PageInfo page) => this(page: page);

  @override
  HealthRecordListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HealthRecordListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HealthRecordListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  HealthRecordListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return HealthRecordListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<HealthRecord>,
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

extension $HealthRecordListResponseCopyWith on HealthRecordListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfHealthRecordListResponse.copyWith(...)` or like so:`instanceOfHealthRecordListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HealthRecordListResponseCWProxy get copyWith =>
      _$HealthRecordListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthRecordListResponse _$HealthRecordListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('HealthRecordListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'page', 'meta']);
  final val = HealthRecordListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => HealthRecord.fromJson(e as Map<String, dynamic>))
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

Map<String, dynamic> _$HealthRecordListResponseToJson(
  HealthRecordListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'page': instance.page.toJson(),
  'meta': instance.meta.toJson(),
};
