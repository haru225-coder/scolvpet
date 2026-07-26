// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_session_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CustomerSessionResponseDataCWProxy {
  CustomerSessionResponseData tokenType(String? tokenType);

  CustomerSessionResponseData accessToken(String accessToken);

  CustomerSessionResponseData expiresInSeconds(int? expiresInSeconds);

  CustomerSessionResponseData phone(String phone);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CustomerSessionResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CustomerSessionResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  CustomerSessionResponseData call({
    String? tokenType,
    String accessToken,
    int? expiresInSeconds,
    String phone,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCustomerSessionResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCustomerSessionResponseData.copyWith.fieldName(...)`
class _$CustomerSessionResponseDataCWProxyImpl
    implements _$CustomerSessionResponseDataCWProxy {
  const _$CustomerSessionResponseDataCWProxyImpl(this._value);

  final CustomerSessionResponseData _value;

  @override
  CustomerSessionResponseData tokenType(String? tokenType) =>
      this(tokenType: tokenType);

  @override
  CustomerSessionResponseData accessToken(String accessToken) =>
      this(accessToken: accessToken);

  @override
  CustomerSessionResponseData expiresInSeconds(int? expiresInSeconds) =>
      this(expiresInSeconds: expiresInSeconds);

  @override
  CustomerSessionResponseData phone(String phone) => this(phone: phone);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CustomerSessionResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CustomerSessionResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  CustomerSessionResponseData call({
    Object? tokenType = const $CopyWithPlaceholder(),
    Object? accessToken = const $CopyWithPlaceholder(),
    Object? expiresInSeconds = const $CopyWithPlaceholder(),
    Object? phone = const $CopyWithPlaceholder(),
  }) {
    return CustomerSessionResponseData(
      tokenType: tokenType == const $CopyWithPlaceholder()
          ? _value.tokenType
          // ignore: cast_nullable_to_non_nullable
          : tokenType as String?,
      accessToken: accessToken == const $CopyWithPlaceholder()
          ? _value.accessToken
          // ignore: cast_nullable_to_non_nullable
          : accessToken as String,
      expiresInSeconds: expiresInSeconds == const $CopyWithPlaceholder()
          ? _value.expiresInSeconds
          // ignore: cast_nullable_to_non_nullable
          : expiresInSeconds as int?,
      phone: phone == const $CopyWithPlaceholder()
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String,
    );
  }
}

extension $CustomerSessionResponseDataCopyWith on CustomerSessionResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfCustomerSessionResponseData.copyWith(...)` or like so:`instanceOfCustomerSessionResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CustomerSessionResponseDataCWProxy get copyWith =>
      _$CustomerSessionResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerSessionResponseData _$CustomerSessionResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CustomerSessionResponseData',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['access_token', 'phone']);
    final val = CustomerSessionResponseData(
      tokenType: $checkedConvert('token_type', (v) => v as String?),
      accessToken: $checkedConvert('access_token', (v) => v as String),
      expiresInSeconds: $checkedConvert(
        'expires_in_seconds',
        (v) => (v as num?)?.toInt(),
      ),
      phone: $checkedConvert('phone', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'tokenType': 'token_type',
    'accessToken': 'access_token',
    'expiresInSeconds': 'expires_in_seconds',
  },
);

Map<String, dynamic> _$CustomerSessionResponseDataToJson(
  CustomerSessionResponseData instance,
) => <String, dynamic>{
  'token_type': ?instance.tokenType,
  'access_token': instance.accessToken,
  'expires_in_seconds': ?instance.expiresInSeconds,
  'phone': instance.phone,
};
