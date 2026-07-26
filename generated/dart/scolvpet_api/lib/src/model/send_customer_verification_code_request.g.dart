// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_customer_verification_code_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SendCustomerVerificationCodeRequestCWProxy {
  SendCustomerVerificationCodeRequest phone(String phone);

  SendCustomerVerificationCodeRequest purpose(
    SendCustomerVerificationCodeRequestPurposeEnum? purpose,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SendCustomerVerificationCodeRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SendCustomerVerificationCodeRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SendCustomerVerificationCodeRequest call({
    String phone,
    SendCustomerVerificationCodeRequestPurposeEnum? purpose,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSendCustomerVerificationCodeRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSendCustomerVerificationCodeRequest.copyWith.fieldName(...)`
class _$SendCustomerVerificationCodeRequestCWProxyImpl
    implements _$SendCustomerVerificationCodeRequestCWProxy {
  const _$SendCustomerVerificationCodeRequestCWProxyImpl(this._value);

  final SendCustomerVerificationCodeRequest _value;

  @override
  SendCustomerVerificationCodeRequest phone(String phone) => this(phone: phone);

  @override
  SendCustomerVerificationCodeRequest purpose(
    SendCustomerVerificationCodeRequestPurposeEnum? purpose,
  ) => this(purpose: purpose);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SendCustomerVerificationCodeRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SendCustomerVerificationCodeRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SendCustomerVerificationCodeRequest call({
    Object? phone = const $CopyWithPlaceholder(),
    Object? purpose = const $CopyWithPlaceholder(),
  }) {
    return SendCustomerVerificationCodeRequest(
      phone: phone == const $CopyWithPlaceholder()
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String,
      purpose: purpose == const $CopyWithPlaceholder()
          ? _value.purpose
          // ignore: cast_nullable_to_non_nullable
          : purpose as SendCustomerVerificationCodeRequestPurposeEnum?,
    );
  }
}

extension $SendCustomerVerificationCodeRequestCopyWith
    on SendCustomerVerificationCodeRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSendCustomerVerificationCodeRequest.copyWith(...)` or like so:`instanceOfSendCustomerVerificationCodeRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SendCustomerVerificationCodeRequestCWProxy get copyWith =>
      _$SendCustomerVerificationCodeRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendCustomerVerificationCodeRequest
_$SendCustomerVerificationCodeRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SendCustomerVerificationCodeRequest', json, (
      $checkedConvert,
    ) {
      $checkKeys(json, requiredKeys: const ['phone']);
      final val = SendCustomerVerificationCodeRequest(
        phone: $checkedConvert('phone', (v) => v as String),
        purpose: $checkedConvert(
          'purpose',
          (v) =>
              $enumDecodeNullable(
                _$SendCustomerVerificationCodeRequestPurposeEnumEnumMap,
                v,
              ) ??
              SendCustomerVerificationCodeRequestPurposeEnum.login,
        ),
      );
      return val;
    });

Map<String, dynamic> _$SendCustomerVerificationCodeRequestToJson(
  SendCustomerVerificationCodeRequest instance,
) => <String, dynamic>{
  'phone': instance.phone,
  'purpose':
      ?_$SendCustomerVerificationCodeRequestPurposeEnumEnumMap[instance
          .purpose],
};

const _$SendCustomerVerificationCodeRequestPurposeEnumEnumMap = {
  SendCustomerVerificationCodeRequestPurposeEnum.login: 'login',
};
