// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_snapshot_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UsageSnapshotListResponseCWProxy {
  UsageSnapshotListResponse data(List<UsageSnapshot> data);

  UsageSnapshotListResponse page(PageInfo page);

  UsageSnapshotListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UsageSnapshotListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UsageSnapshotListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  UsageSnapshotListResponse call({
    List<UsageSnapshot> data,
    PageInfo page,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUsageSnapshotListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUsageSnapshotListResponse.copyWith.fieldName(...)`
class _$UsageSnapshotListResponseCWProxyImpl
    implements _$UsageSnapshotListResponseCWProxy {
  const _$UsageSnapshotListResponseCWProxyImpl(this._value);

  final UsageSnapshotListResponse _value;

  @override
  UsageSnapshotListResponse data(List<UsageSnapshot> data) => this(data: data);

  @override
  UsageSnapshotListResponse page(PageInfo page) => this(page: page);

  @override
  UsageSnapshotListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UsageSnapshotListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UsageSnapshotListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  UsageSnapshotListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return UsageSnapshotListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<UsageSnapshot>,
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

extension $UsageSnapshotListResponseCopyWith on UsageSnapshotListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfUsageSnapshotListResponse.copyWith(...)` or like so:`instanceOfUsageSnapshotListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UsageSnapshotListResponseCWProxy get copyWith =>
      _$UsageSnapshotListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsageSnapshotListResponse _$UsageSnapshotListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UsageSnapshotListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'page', 'meta']);
  final val = UsageSnapshotListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => UsageSnapshot.fromJson(e as Map<String, dynamic>))
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

Map<String, dynamic> _$UsageSnapshotListResponseToJson(
  UsageSnapshotListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'page': instance.page.toJson(),
  'meta': instance.meta.toJson(),
};
