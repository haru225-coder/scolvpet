// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_customer_session_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateCustomerSessionRequestCWProxy {
  CreateCustomerSessionRequest phone(String phone);

  CreateCustomerSessionRequest verificationId(String verificationId);

  CreateCustomerSessionRequest code(String code);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateCustomerSessionRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateCustomerSessionRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateCustomerSessionRequest call({
    String phone,
    String verificationId,
    String code,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateCustomerSessionRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateCustomerSessionRequest.copyWith.fieldName(...)`
class _$CreateCustomerSessionRequestCWProxyImpl
    implements _$CreateCustomerSessionRequestCWProxy {
  const _$CreateCustomerSessionRequestCWProxyImpl(this._value);

  final CreateCustomerSessionRequest _value;

  @override
  CreateCustomerSessionRequest phone(String phone) => this(phone: phone);

  @override
  CreateCustomerSessionRequest verificationId(String verificationId) =>
      this(verificationId: verificationId);

  @override
  CreateCustomerSessionRequest code(String code) => this(code: code);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateCustomerSessionRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateCustomerSessionRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateCustomerSessionRequest call({
    Object? phone = const $CopyWithPlaceholder(),
    Object? verificationId = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
  }) {
    return CreateCustomerSessionRequest(
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

extension $CreateCustomerSessionRequestCopyWith
    on CreateCustomerSessionRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateCustomerSessionRequest.copyWith(...)` or like so:`instanceOfCreateCustomerSessionRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateCustomerSessionRequestCWProxy get copyWith =>
      _$CreateCustomerSessionRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCustomerSessionRequest _$CreateCustomerSessionRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CreateCustomerSessionRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['phone', 'verification_id', 'code']);
    final val = CreateCustomerSessionRequest(
      phone: $checkedConvert('phone', (v) => v as String),
      verificationId: $checkedConvert('verification_id', (v) => v as String),
      code: $checkedConvert('code', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {'verificationId': 'verification_id'},
);

Map<String, dynamic> _$CreateCustomerSessionRequestToJson(
  CreateCustomerSessionRequest instance,
) => <String, dynamic>{
  'phone': instance.phone,
  'verification_id': instance.verificationId,
  'code': instance.code,
};
