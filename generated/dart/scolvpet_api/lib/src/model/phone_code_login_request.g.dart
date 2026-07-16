// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_code_login_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PhoneCodeLoginRequestCWProxy {
  PhoneCodeLoginRequest phone(String phone);

  PhoneCodeLoginRequest verificationId(String verificationId);

  PhoneCodeLoginRequest code(String code);

  PhoneCodeLoginRequest device(DeviceInfo device);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PhoneCodeLoginRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PhoneCodeLoginRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PhoneCodeLoginRequest call({
    String phone,
    String verificationId,
    String code,
    DeviceInfo device,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPhoneCodeLoginRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPhoneCodeLoginRequest.copyWith.fieldName(...)`
class _$PhoneCodeLoginRequestCWProxyImpl
    implements _$PhoneCodeLoginRequestCWProxy {
  const _$PhoneCodeLoginRequestCWProxyImpl(this._value);

  final PhoneCodeLoginRequest _value;

  @override
  PhoneCodeLoginRequest phone(String phone) => this(phone: phone);

  @override
  PhoneCodeLoginRequest verificationId(String verificationId) =>
      this(verificationId: verificationId);

  @override
  PhoneCodeLoginRequest code(String code) => this(code: code);

  @override
  PhoneCodeLoginRequest device(DeviceInfo device) => this(device: device);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PhoneCodeLoginRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PhoneCodeLoginRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PhoneCodeLoginRequest call({
    Object? phone = const $CopyWithPlaceholder(),
    Object? verificationId = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? device = const $CopyWithPlaceholder(),
  }) {
    return PhoneCodeLoginRequest(
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
      device: device == const $CopyWithPlaceholder()
          ? _value.device
          // ignore: cast_nullable_to_non_nullable
          : device as DeviceInfo,
    );
  }
}

extension $PhoneCodeLoginRequestCopyWith on PhoneCodeLoginRequest {
  /// Returns a callable class that can be used as follows: `instanceOfPhoneCodeLoginRequest.copyWith(...)` or like so:`instanceOfPhoneCodeLoginRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PhoneCodeLoginRequestCWProxy get copyWith =>
      _$PhoneCodeLoginRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhoneCodeLoginRequest _$PhoneCodeLoginRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PhoneCodeLoginRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['phone', 'verification_id', 'code', 'device'],
    );
    final val = PhoneCodeLoginRequest(
      phone: $checkedConvert('phone', (v) => v as String),
      verificationId: $checkedConvert('verification_id', (v) => v as String),
      code: $checkedConvert('code', (v) => v as String),
      device: $checkedConvert(
        'device',
        (v) => DeviceInfo.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
  fieldKeyMap: const {'verificationId': 'verification_id'},
);

Map<String, dynamic> _$PhoneCodeLoginRequestToJson(
  PhoneCodeLoginRequest instance,
) => <String, dynamic>{
  'phone': instance.phone,
  'verification_id': instance.verificationId,
  'code': instance.code,
  'device': instance.device.toJson(),
};
