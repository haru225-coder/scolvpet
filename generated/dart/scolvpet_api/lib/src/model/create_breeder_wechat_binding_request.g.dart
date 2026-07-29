// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_breeder_wechat_binding_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateBreederWechatBindingRequestCWProxy {
  CreateBreederWechatBindingRequest wechatTicket(String wechatTicket);

  CreateBreederWechatBindingRequest phone(String phone);

  CreateBreederWechatBindingRequest verificationId(String verificationId);

  CreateBreederWechatBindingRequest code(String code);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateBreederWechatBindingRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateBreederWechatBindingRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateBreederWechatBindingRequest call({
    String wechatTicket,
    String phone,
    String verificationId,
    String code,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateBreederWechatBindingRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateBreederWechatBindingRequest.copyWith.fieldName(...)`
class _$CreateBreederWechatBindingRequestCWProxyImpl
    implements _$CreateBreederWechatBindingRequestCWProxy {
  const _$CreateBreederWechatBindingRequestCWProxyImpl(this._value);

  final CreateBreederWechatBindingRequest _value;

  @override
  CreateBreederWechatBindingRequest wechatTicket(String wechatTicket) =>
      this(wechatTicket: wechatTicket);

  @override
  CreateBreederWechatBindingRequest phone(String phone) => this(phone: phone);

  @override
  CreateBreederWechatBindingRequest verificationId(String verificationId) =>
      this(verificationId: verificationId);

  @override
  CreateBreederWechatBindingRequest code(String code) => this(code: code);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateBreederWechatBindingRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateBreederWechatBindingRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateBreederWechatBindingRequest call({
    Object? wechatTicket = const $CopyWithPlaceholder(),
    Object? phone = const $CopyWithPlaceholder(),
    Object? verificationId = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
  }) {
    return CreateBreederWechatBindingRequest(
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

extension $CreateBreederWechatBindingRequestCopyWith
    on CreateBreederWechatBindingRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateBreederWechatBindingRequest.copyWith(...)` or like so:`instanceOfCreateBreederWechatBindingRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateBreederWechatBindingRequestCWProxy get copyWith =>
      _$CreateBreederWechatBindingRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateBreederWechatBindingRequest _$CreateBreederWechatBindingRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CreateBreederWechatBindingRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['wechat_ticket', 'phone', 'verification_id', 'code'],
    );
    final val = CreateBreederWechatBindingRequest(
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

Map<String, dynamic> _$CreateBreederWechatBindingRequestToJson(
  CreateBreederWechatBindingRequest instance,
) => <String, dynamic>{
  'wechat_ticket': instance.wechatTicket,
  'phone': instance.phone,
  'verification_id': instance.verificationId,
  'code': instance.code,
};
