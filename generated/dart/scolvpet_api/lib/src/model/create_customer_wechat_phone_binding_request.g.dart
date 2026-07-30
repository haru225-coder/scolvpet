// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_customer_wechat_phone_binding_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateCustomerWechatPhoneBindingRequestCWProxy {
  CreateCustomerWechatPhoneBindingRequest wechatTicket(String wechatTicket);

  CreateCustomerWechatPhoneBindingRequest phoneCode(String phoneCode);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateCustomerWechatPhoneBindingRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateCustomerWechatPhoneBindingRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateCustomerWechatPhoneBindingRequest call({
    String wechatTicket,
    String phoneCode,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateCustomerWechatPhoneBindingRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateCustomerWechatPhoneBindingRequest.copyWith.fieldName(...)`
class _$CreateCustomerWechatPhoneBindingRequestCWProxyImpl
    implements _$CreateCustomerWechatPhoneBindingRequestCWProxy {
  const _$CreateCustomerWechatPhoneBindingRequestCWProxyImpl(this._value);

  final CreateCustomerWechatPhoneBindingRequest _value;

  @override
  CreateCustomerWechatPhoneBindingRequest wechatTicket(String wechatTicket) =>
      this(wechatTicket: wechatTicket);

  @override
  CreateCustomerWechatPhoneBindingRequest phoneCode(String phoneCode) =>
      this(phoneCode: phoneCode);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateCustomerWechatPhoneBindingRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateCustomerWechatPhoneBindingRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateCustomerWechatPhoneBindingRequest call({
    Object? wechatTicket = const $CopyWithPlaceholder(),
    Object? phoneCode = const $CopyWithPlaceholder(),
  }) {
    return CreateCustomerWechatPhoneBindingRequest(
      wechatTicket: wechatTicket == const $CopyWithPlaceholder()
          ? _value.wechatTicket
          // ignore: cast_nullable_to_non_nullable
          : wechatTicket as String,
      phoneCode: phoneCode == const $CopyWithPlaceholder()
          ? _value.phoneCode
          // ignore: cast_nullable_to_non_nullable
          : phoneCode as String,
    );
  }
}

extension $CreateCustomerWechatPhoneBindingRequestCopyWith
    on CreateCustomerWechatPhoneBindingRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateCustomerWechatPhoneBindingRequest.copyWith(...)` or like so:`instanceOfCreateCustomerWechatPhoneBindingRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateCustomerWechatPhoneBindingRequestCWProxy get copyWith =>
      _$CreateCustomerWechatPhoneBindingRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCustomerWechatPhoneBindingRequest
_$CreateCustomerWechatPhoneBindingRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CreateCustomerWechatPhoneBindingRequest',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['wechat_ticket', 'phone_code']);
        final val = CreateCustomerWechatPhoneBindingRequest(
          wechatTicket: $checkedConvert('wechat_ticket', (v) => v as String),
          phoneCode: $checkedConvert('phone_code', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {
        'wechatTicket': 'wechat_ticket',
        'phoneCode': 'phone_code',
      },
    );

Map<String, dynamic> _$CreateCustomerWechatPhoneBindingRequestToJson(
  CreateCustomerWechatPhoneBindingRequest instance,
) => <String, dynamic>{
  'wechat_ticket': instance.wechatTicket,
  'phone_code': instance.phoneCode,
};
