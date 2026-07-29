// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wechat_subscription_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WechatSubscriptionListResponseCWProxy {
  WechatSubscriptionListResponse data(List<WechatSubscription> data);

  WechatSubscriptionListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WechatSubscriptionListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WechatSubscriptionListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WechatSubscriptionListResponse call({
    List<WechatSubscription> data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWechatSubscriptionListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWechatSubscriptionListResponse.copyWith.fieldName(...)`
class _$WechatSubscriptionListResponseCWProxyImpl
    implements _$WechatSubscriptionListResponseCWProxy {
  const _$WechatSubscriptionListResponseCWProxyImpl(this._value);

  final WechatSubscriptionListResponse _value;

  @override
  WechatSubscriptionListResponse data(List<WechatSubscription> data) =>
      this(data: data);

  @override
  WechatSubscriptionListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WechatSubscriptionListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WechatSubscriptionListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WechatSubscriptionListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return WechatSubscriptionListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<WechatSubscription>,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $WechatSubscriptionListResponseCopyWith
    on WechatSubscriptionListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfWechatSubscriptionListResponse.copyWith(...)` or like so:`instanceOfWechatSubscriptionListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WechatSubscriptionListResponseCWProxy get copyWith =>
      _$WechatSubscriptionListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WechatSubscriptionListResponse _$WechatSubscriptionListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WechatSubscriptionListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = WechatSubscriptionListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => WechatSubscription.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$WechatSubscriptionListResponseToJson(
  WechatSubscriptionListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'meta': instance.meta.toJson(),
};
