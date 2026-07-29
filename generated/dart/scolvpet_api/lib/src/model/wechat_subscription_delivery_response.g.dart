// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wechat_subscription_delivery_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WechatSubscriptionDeliveryResponseCWProxy {
  WechatSubscriptionDeliveryResponse data(
    WechatSubscriptionDeliveryResponseData data,
  );

  WechatSubscriptionDeliveryResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WechatSubscriptionDeliveryResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WechatSubscriptionDeliveryResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WechatSubscriptionDeliveryResponse call({
    WechatSubscriptionDeliveryResponseData data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWechatSubscriptionDeliveryResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWechatSubscriptionDeliveryResponse.copyWith.fieldName(...)`
class _$WechatSubscriptionDeliveryResponseCWProxyImpl
    implements _$WechatSubscriptionDeliveryResponseCWProxy {
  const _$WechatSubscriptionDeliveryResponseCWProxyImpl(this._value);

  final WechatSubscriptionDeliveryResponse _value;

  @override
  WechatSubscriptionDeliveryResponse data(
    WechatSubscriptionDeliveryResponseData data,
  ) => this(data: data);

  @override
  WechatSubscriptionDeliveryResponse meta(ResponseMeta meta) =>
      this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WechatSubscriptionDeliveryResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WechatSubscriptionDeliveryResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WechatSubscriptionDeliveryResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return WechatSubscriptionDeliveryResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as WechatSubscriptionDeliveryResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $WechatSubscriptionDeliveryResponseCopyWith
    on WechatSubscriptionDeliveryResponse {
  /// Returns a callable class that can be used as follows: `instanceOfWechatSubscriptionDeliveryResponse.copyWith(...)` or like so:`instanceOfWechatSubscriptionDeliveryResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WechatSubscriptionDeliveryResponseCWProxy get copyWith =>
      _$WechatSubscriptionDeliveryResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WechatSubscriptionDeliveryResponse _$WechatSubscriptionDeliveryResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WechatSubscriptionDeliveryResponse', json, (
  $checkedConvert,
) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = WechatSubscriptionDeliveryResponse(
    data: $checkedConvert(
      'data',
      (v) => WechatSubscriptionDeliveryResponseData.fromJson(
        v as Map<String, dynamic>,
      ),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$WechatSubscriptionDeliveryResponseToJson(
  WechatSubscriptionDeliveryResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
