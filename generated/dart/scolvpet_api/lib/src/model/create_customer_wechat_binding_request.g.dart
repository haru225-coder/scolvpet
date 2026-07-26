// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_customer_wechat_binding_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateCustomerWechatBindingRequestCWProxy {
  CreateCustomerWechatBindingRequest wechatTicket(String wechatTicket);

  CreateCustomerWechatBindingRequest phone(String phone);

  CreateCustomerWechatBindingRequest verificationId(String verificationId);

  CreateCustomerWechatBindingRequest code(String code);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateCustomerWechatBindingRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateCustomerWechatBindingRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateCustomerWechatBindingRequest call({
    String wechatTicket,
    String phone,
    String verificationId,
    String code,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateCustomerWechatBindingRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateCustomerWechatBindingRequest.copyWith.fieldName(...)`
class _$CreateCustomerWechatBindingRequestCWProxyImpl
    implements _$CreateCustomerWechatBindingRequestCWProxy {
  const _$CreateCustomerWechatBindingRequestCWProxyImpl(this._value);

  final CreateCustomerWechatBindingRequest _value;

  @override
  CreateCustomerWechatBindingRequest wechatTicket(String wechatTicket) =>
      this(wechatTicket: wechatTicket);

  @override
  CreateCustomerWechatBindingRequest phone(String phone) => this(phone: phone);

  @override
  CreateCustomerWechatBindingRequest verificationId(String verificationId) =>
      this(verificationId: verificationId);

  @override
  CreateCustomerWechatBindingRequest code(String code) => this(code: code);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateCustomerWechatBindingRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateCustomerWechatBindingRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateCustomerWechatBindingRequest call({
    Object? wechatTicket = const $CopyWithPlaceholder(),
    Object? phone = const $CopyWithPlaceholder(),
    Object? verificationId = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
  }) {
    return CreateCustomerWechatBindingRequest(
      wechatTicket: wechatTicket == const $CopyWithPlaceholder()
          ? _value.wechatTicket
          // ignore: cast_nullable_to_non_nullable
          : wechatTicket as String,
      phone: phone == const $CopyWithPlaceholder()
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String,
      verificationId: verificationId == const $CopyWithPlaceholder()
          ? _value.verificationId
          // ignore: cast_nullable_to_non_nullable
          : verificationId as String,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
    );
  }
}

extension $CreateCustomerWechatBindingRequestCopyWith
    on CreateCustomerWechatBindingRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateCustomerWechatBindingRequest.copyWith(...)` or like so:`instanceOfCreateCustomerWechatBindingRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateCustomerWechatBindingRequestCWProxy get copyWith =>
      _$CreateCustomerWechatBindingRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCustomerWechatBindingRequest _$CreateCustomerWechatBindingRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CreateCustomerWechatBindingRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['wechat_ticket', 'phone', 'verification_id', 'code'],
    );
    final val = CreateCustomerWechatBindingRequest(
      wechatTicket: $checkedConvert('wechat_ticket', (v) => v as String),
      phone: $checkedConvert('phone', (v) => v as String),
      verificationId: $checkedConvert('verification_id', (v) => v as String),
      code: $checkedConvert('code', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'wechatTicket': 'wechat_ticket',
    'verificationId': 'verification_id',
  },
);

Map<String, dynamic> _$CreateCustomerWechatBindingRequestToJson(
  CreateCustomerWechatBindingRequest instance,
) => <String, dynamic>{
  'wechat_ticket': instance.wechatTicket,
  'phone': instance.phone,
  'verification_id': instance.verificationId,
  'code': instance.code,
};
