// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'miniprogram_release_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MiniprogramReleaseListResponseCWProxy {
  MiniprogramReleaseListResponse data(List<MiniprogramRelease> data);

  MiniprogramReleaseListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MiniprogramReleaseListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MiniprogramReleaseListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MiniprogramReleaseListResponse call({
    List<MiniprogramRelease> data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMiniprogramReleaseListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMiniprogramReleaseListResponse.copyWith.fieldName(...)`
class _$MiniprogramReleaseListResponseCWProxyImpl
    implements _$MiniprogramReleaseListResponseCWProxy {
  const _$MiniprogramReleaseListResponseCWProxyImpl(this._value);

  final MiniprogramReleaseListResponse _value;

  @override
  MiniprogramReleaseListResponse data(List<MiniprogramRelease> data) =>
      this(data: data);

  @override
  MiniprogramReleaseListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MiniprogramReleaseListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MiniprogramReleaseListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MiniprogramReleaseListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return MiniprogramReleaseListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<MiniprogramRelease>,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $MiniprogramReleaseListResponseCopyWith
    on MiniprogramReleaseListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfMiniprogramReleaseListResponse.copyWith(...)` or like so:`instanceOfMiniprogramReleaseListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MiniprogramReleaseListResponseCWProxy get copyWith =>
      _$MiniprogramReleaseListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MiniprogramReleaseListResponse _$MiniprogramReleaseListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MiniprogramReleaseListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = MiniprogramReleaseListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => MiniprogramRelease.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$MiniprogramReleaseListResponseToJson(
  MiniprogramReleaseListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'meta': instance.meta.toJson(),
};
