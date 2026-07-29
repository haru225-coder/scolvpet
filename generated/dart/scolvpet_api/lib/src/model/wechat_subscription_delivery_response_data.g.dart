// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wechat_subscription_delivery_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WechatSubscriptionDeliveryResponseDataCWProxy {
  WechatSubscriptionDeliveryResponseData templateId(String templateId);

  WechatSubscriptionDeliveryResponseData providerMessageId(
    String providerMessageId,
  );

  WechatSubscriptionDeliveryResponseData sentAt(DateTime sentAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WechatSubscriptionDeliveryResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WechatSubscriptionDeliveryResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  WechatSubscriptionDeliveryResponseData call({
    String templateId,
    String providerMessageId,
    DateTime sentAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWechatSubscriptionDeliveryResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWechatSubscriptionDeliveryResponseData.copyWith.fieldName(...)`
class _$WechatSubscriptionDeliveryResponseDataCWProxyImpl
    implements _$WechatSubscriptionDeliveryResponseDataCWProxy {
  const _$WechatSubscriptionDeliveryResponseDataCWProxyImpl(this._value);

  final WechatSubscriptionDeliveryResponseData _value;

  @override
  WechatSubscriptionDeliveryResponseData templateId(String templateId) =>
      this(templateId: templateId);

  @override
  WechatSubscriptionDeliveryResponseData providerMessageId(
    String providerMessageId,
  ) => this(providerMessageId: providerMessageId);

  @override
  WechatSubscriptionDeliveryResponseData sentAt(DateTime sentAt) =>
      this(sentAt: sentAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WechatSubscriptionDeliveryResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WechatSubscriptionDeliveryResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  WechatSubscriptionDeliveryResponseData call({
    Object? templateId = const $CopyWithPlaceholder(),
    Object? providerMessageId = const $CopyWithPlaceholder(),
    Object? sentAt = const $CopyWithPlaceholder(),
  }) {
    return WechatSubscriptionDeliveryResponseData(
      templateId: templateId == const $CopyWithPlaceholder()
          ? _value.templateId
          // ignore: cast_nullable_to_non_nullable
          : templateId as String,
      providerMessageId: providerMessageId == const $CopyWithPlaceholder()
          ? _value.providerMessageId
          // ignore: cast_nullable_to_non_nullable
          : providerMessageId as String,
      sentAt: sentAt == const $CopyWithPlaceholder()
          ? _value.sentAt
          // ignore: cast_nullable_to_non_nullable
          : sentAt as DateTime,
    );
  }
}

extension $WechatSubscriptionDeliveryResponseDataCopyWith
    on WechatSubscriptionDeliveryResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfWechatSubscriptionDeliveryResponseData.copyWith(...)` or like so:`instanceOfWechatSubscriptionDeliveryResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WechatSubscriptionDeliveryResponseDataCWProxy get copyWith =>
      _$WechatSubscriptionDeliveryResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WechatSubscriptionDeliveryResponseData
_$WechatSubscriptionDeliveryResponseDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WechatSubscriptionDeliveryResponseData',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['template_id', 'provider_message_id', 'sent_at'],
        );
        final val = WechatSubscriptionDeliveryResponseData(
          templateId: $checkedConvert('template_id', (v) => v as String),
          providerMessageId: $checkedConvert(
            'provider_message_id',
            (v) => v as String,
          ),
          sentAt: $checkedConvert(
            'sent_at',
            (v) => DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'templateId': 'template_id',
        'providerMessageId': 'provider_message_id',
        'sentAt': 'sent_at',
      },
    );

Map<String, dynamic> _$WechatSubscriptionDeliveryResponseDataToJson(
  WechatSubscriptionDeliveryResponseData instance,
) => <String, dynamic>{
  'template_id': instance.templateId,
  'provider_message_id': instance.providerMessageId,
  'sent_at': instance.sentAt.toIso8601String(),
};
