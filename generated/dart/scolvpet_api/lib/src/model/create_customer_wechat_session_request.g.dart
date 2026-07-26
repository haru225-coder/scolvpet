// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_customer_wechat_session_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateCustomerWechatSessionRequestCWProxy {
  CreateCustomerWechatSessionRequest jsCode(String jsCode);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateCustomerWechatSessionRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateCustomerWechatSessionRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateCustomerWechatSessionRequest call({String jsCode});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateCustomerWechatSessionRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateCustomerWechatSessionRequest.copyWith.fieldName(...)`
class _$CreateCustomerWechatSessionRequestCWProxyImpl
    implements _$CreateCustomerWechatSessionRequestCWProxy {
  const _$CreateCustomerWechatSessionRequestCWProxyImpl(this._value);

  final CreateCustomerWechatSessionRequest _value;

  @override
  CreateCustomerWechatSessionRequest jsCode(String jsCode) =>
      this(jsCode: jsCode);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateCustomerWechatSessionRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateCustomerWechatSessionRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateCustomerWechatSessionRequest call({
    Object? jsCode = const $CopyWithPlaceholder(),
  }) {
    return CreateCustomerWechatSessionRequest(
      jsCode: jsCode == const $CopyWithPlaceholder()
          ? _value.jsCode
          // ignore: cast_nullable_to_non_nullable
          : jsCode as String,
    );
  }
}

extension $CreateCustomerWechatSessionRequestCopyWith
    on CreateCustomerWechatSessionRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateCustomerWechatSessionRequest.copyWith(...)` or like so:`instanceOfCreateCustomerWechatSessionRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateCustomerWechatSessionRequestCWProxy get copyWith =>
      _$CreateCustomerWechatSessionRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCustomerWechatSessionRequest _$CreateCustomerWechatSessionRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CreateCustomerWechatSessionRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['js_code']);
    final val = CreateCustomerWechatSessionRequest(
      jsCode: $checkedConvert('js_code', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {'jsCode': 'js_code'},
);

Map<String, dynamic> _$CreateCustomerWechatSessionRequestToJson(
  CreateCustomerWechatSessionRequest instance,
) => <String, dynamic>{'js_code': instance.jsCode};
