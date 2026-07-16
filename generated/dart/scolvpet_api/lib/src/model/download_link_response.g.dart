// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_link_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DownloadLinkResponseCWProxy {
  DownloadLinkResponse data(DownloadLinkResponseData data);

  DownloadLinkResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DownloadLinkResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DownloadLinkResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  DownloadLinkResponse call({DownloadLinkResponseData data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDownloadLinkResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDownloadLinkResponse.copyWith.fieldName(...)`
class _$DownloadLinkResponseCWProxyImpl
    implements _$DownloadLinkResponseCWProxy {
  const _$DownloadLinkResponseCWProxyImpl(this._value);

  final DownloadLinkResponse _value;

  @override
  DownloadLinkResponse data(DownloadLinkResponseData data) => this(data: data);

  @override
  DownloadLinkResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DownloadLinkResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DownloadLinkResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  DownloadLinkResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return DownloadLinkResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as DownloadLinkResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $DownloadLinkResponseCopyWith on DownloadLinkResponse {
  /// Returns a callable class that can be used as follows: `instanceOfDownloadLinkResponse.copyWith(...)` or like so:`instanceOfDownloadLinkResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DownloadLinkResponseCWProxy get copyWith =>
      _$DownloadLinkResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DownloadLinkResponse _$DownloadLinkResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DownloadLinkResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = DownloadLinkResponse(
    data: $checkedConvert(
      'data',
      (v) => DownloadLinkResponseData.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$DownloadLinkResponseToJson(
  DownloadLinkResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
