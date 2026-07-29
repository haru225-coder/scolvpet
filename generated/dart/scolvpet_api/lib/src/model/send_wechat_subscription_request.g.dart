// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_wechat_subscription_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SendWechatSubscriptionRequestCWProxy {
  SendWechatSubscriptionRequest templateId(String templateId);

  SendWechatSubscriptionRequest page(String? page);

  SendWechatSubscriptionRequest data(Map<String, String> data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SendWechatSubscriptionRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SendWechatSubscriptionRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SendWechatSubscriptionRequest call({
    String templateId,
    String? page,
    Map<String, String> data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSendWechatSubscriptionRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSendWechatSubscriptionRequest.copyWith.fieldName(...)`
class _$SendWechatSubscriptionRequestCWProxyImpl
    implements _$SendWechatSubscriptionRequestCWProxy {
  const _$SendWechatSubscriptionRequestCWProxyImpl(this._value);

  final SendWechatSubscriptionRequest _value;

  @override
  SendWechatSubscriptionRequest templateId(String templateId) =>
      this(templateId: templateId);

  @override
  SendWechatSubscriptionRequest page(String? page) => this(page: page);

  @override
  SendWechatSubscriptionRequest data(Map<String, String> data) =>
      this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SendWechatSubscriptionRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SendWechatSubscriptionRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SendWechatSubscriptionRequest call({
    Object? templateId = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return SendWechatSubscriptionRequest(
      templateId: templateId == const $CopyWithPlaceholder()
          ? _value.templateId
          // ignore: cast_nullable_to_non_nullable
          : templateId as String,
      page: page == const $CopyWithPlaceholder()
          ? _value.page
          // ignore: cast_nullable_to_non_nullable
          : page as String?,
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as Map<String, String>,
    );
  }
}

extension $SendWechatSubscriptionRequestCopyWith
    on SendWechatSubscriptionRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSendWechatSubscriptionRequest.copyWith(...)` or like so:`instanceOfSendWechatSubscriptionRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SendWechatSubscriptionRequestCWProxy get copyWith =>
      _$SendWechatSubscriptionRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendWechatSubscriptionRequest _$SendWechatSubscriptionRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'SendWechatSubscriptionRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['template_id', 'data']);
    final val = SendWechatSubscriptionRequest(
      templateId: $checkedConvert('template_id', (v) => v as String),
      page: $checkedConvert('page', (v) => v as String?),
      data: $checkedConvert('data', (v) => Map<String, String>.from(v as Map)),
    );
    return val;
  },
  fieldKeyMap: const {'templateId': 'template_id'},
);

Map<String, dynamic> _$SendWechatSubscriptionRequestToJson(
  SendWechatSubscriptionRequest instance,
) => <String, dynamic>{
  'template_id': instance.templateId,
  'page': ?instance.page,
  'data': instance.data,
};
