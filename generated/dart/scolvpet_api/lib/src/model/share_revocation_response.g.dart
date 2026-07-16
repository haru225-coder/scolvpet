// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_revocation_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ShareRevocationResponseCWProxy {
  ShareRevocationResponse data(ShareRevocationResponseData data);

  ShareRevocationResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ShareRevocationResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ShareRevocationResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ShareRevocationResponse call({
    ShareRevocationResponseData data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfShareRevocationResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfShareRevocationResponse.copyWith.fieldName(...)`
class _$ShareRevocationResponseCWProxyImpl
    implements _$ShareRevocationResponseCWProxy {
  const _$ShareRevocationResponseCWProxyImpl(this._value);

  final ShareRevocationResponse _value;

  @override
  ShareRevocationResponse data(ShareRevocationResponseData data) =>
      this(data: data);

  @override
  ShareRevocationResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ShareRevocationResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ShareRevocationResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ShareRevocationResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return ShareRevocationResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as ShareRevocationResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $ShareRevocationResponseCopyWith on ShareRevocationResponse {
  /// Returns a callable class that can be used as follows: `instanceOfShareRevocationResponse.copyWith(...)` or like so:`instanceOfShareRevocationResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ShareRevocationResponseCWProxy get copyWith =>
      _$ShareRevocationResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShareRevocationResponse _$ShareRevocationResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ShareRevocationResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = ShareRevocationResponse(
    data: $checkedConvert(
      'data',
      (v) => ShareRevocationResponseData.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ShareRevocationResponseToJson(
  ShareRevocationResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
