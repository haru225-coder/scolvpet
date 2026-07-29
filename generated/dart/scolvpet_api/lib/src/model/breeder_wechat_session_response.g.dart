// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breeder_wechat_session_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BreederWechatSessionResponseCWProxy {
  BreederWechatSessionResponse data(BreederWechatSessionResponseData data);

  BreederWechatSessionResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BreederWechatSessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BreederWechatSessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  BreederWechatSessionResponse call({
    BreederWechatSessionResponseData data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBreederWechatSessionResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBreederWechatSessionResponse.copyWith.fieldName(...)`
class _$BreederWechatSessionResponseCWProxyImpl
    implements _$BreederWechatSessionResponseCWProxy {
  const _$BreederWechatSessionResponseCWProxyImpl(this._value);

  final BreederWechatSessionResponse _value;

  @override
  BreederWechatSessionResponse data(BreederWechatSessionResponseData data) =>
      this(data: data);

  @override
  BreederWechatSessionResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BreederWechatSessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BreederWechatSessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  BreederWechatSessionResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return BreederWechatSessionResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as BreederWechatSessionResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $BreederWechatSessionResponseCopyWith
    on BreederWechatSessionResponse {
  /// Returns a callable class that can be used as follows: `instanceOfBreederWechatSessionResponse.copyWith(...)` or like so:`instanceOfBreederWechatSessionResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BreederWechatSessionResponseCWProxy get copyWith =>
      _$BreederWechatSessionResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BreederWechatSessionResponse _$BreederWechatSessionResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('BreederWechatSessionResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = BreederWechatSessionResponse(
    data: $checkedConvert(
      'data',
      (v) =>
          BreederWechatSessionResponseData.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$BreederWechatSessionResponseToJson(
  BreederWechatSessionResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
