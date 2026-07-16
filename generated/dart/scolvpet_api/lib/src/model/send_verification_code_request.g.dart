// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_verification_code_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SendVerificationCodeRequestCWProxy {
  SendVerificationCodeRequest phone(String phone);

  SendVerificationCodeRequest purpose(
    SendVerificationCodeRequestPurposeEnum purpose,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SendVerificationCodeRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SendVerificationCodeRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SendVerificationCodeRequest call({
    String phone,
    SendVerificationCodeRequestPurposeEnum purpose,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSendVerificationCodeRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSendVerificationCodeRequest.copyWith.fieldName(...)`
class _$SendVerificationCodeRequestCWProxyImpl
    implements _$SendVerificationCodeRequestCWProxy {
  const _$SendVerificationCodeRequestCWProxyImpl(this._value);

  final SendVerificationCodeRequest _value;

  @override
  SendVerificationCodeRequest phone(String phone) => this(phone: phone);

  @override
  SendVerificationCodeRequest purpose(
    SendVerificationCodeRequestPurposeEnum purpose,
  ) => this(purpose: purpose);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SendVerificationCodeRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SendVerificationCodeRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SendVerificationCodeRequest call({
    Object? phone = const $CopyWithPlaceholder(),
    Object? purpose = const $CopyWithPlaceholder(),
  }) {
    return SendVerificationCodeRequest(
      phone: phone == const $CopyWithPlaceholder()
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String,
      purpose: purpose == const $CopyWithPlaceholder()
          ? _value.purpose
          // ignore: cast_nullable_to_non_nullable
          : purpose as SendVerificationCodeRequestPurposeEnum,
    );
  }
}

extension $SendVerificationCodeRequestCopyWith on SendVerificationCodeRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSendVerificationCodeRequest.copyWith(...)` or like so:`instanceOfSendVerificationCodeRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SendVerificationCodeRequestCWProxy get copyWith =>
      _$SendVerificationCodeRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendVerificationCodeRequest _$SendVerificationCodeRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SendVerificationCodeRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['phone', 'purpose']);
  final val = SendVerificationCodeRequest(
    phone: $checkedConvert('phone', (v) => v as String),
    purpose: $checkedConvert(
      'purpose',
      (v) => $enumDecode(_$SendVerificationCodeRequestPurposeEnumEnumMap, v),
    ),
  );
  return val;
});

Map<String, dynamic> _$SendVerificationCodeRequestToJson(
  SendVerificationCodeRequest instance,
) => <String, dynamic>{
  'phone': instance.phone,
  'purpose': _$SendVerificationCodeRequestPurposeEnumEnumMap[instance.purpose]!,
};

const _$SendVerificationCodeRequestPurposeEnumEnumMap = {
  SendVerificationCodeRequestPurposeEnum.login: 'login',
};
