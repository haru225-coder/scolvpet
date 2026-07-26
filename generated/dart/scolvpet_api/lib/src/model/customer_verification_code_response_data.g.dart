// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_verification_code_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CustomerVerificationCodeResponseDataCWProxy {
  CustomerVerificationCodeResponseData verificationId(String? verificationId);

  CustomerVerificationCodeResponseData expiresInSeconds(int? expiresInSeconds);

  CustomerVerificationCodeResponseData retryAfterSeconds(
    int? retryAfterSeconds,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CustomerVerificationCodeResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CustomerVerificationCodeResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  CustomerVerificationCodeResponseData call({
    String? verificationId,
    int? expiresInSeconds,
    int? retryAfterSeconds,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCustomerVerificationCodeResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCustomerVerificationCodeResponseData.copyWith.fieldName(...)`
class _$CustomerVerificationCodeResponseDataCWProxyImpl
    implements _$CustomerVerificationCodeResponseDataCWProxy {
  const _$CustomerVerificationCodeResponseDataCWProxyImpl(this._value);

  final CustomerVerificationCodeResponseData _value;

  @override
  CustomerVerificationCodeResponseData verificationId(String? verificationId) =>
      this(verificationId: verificationId);

  @override
  CustomerVerificationCodeResponseData expiresInSeconds(
    int? expiresInSeconds,
  ) => this(expiresInSeconds: expiresInSeconds);

  @override
  CustomerVerificationCodeResponseData retryAfterSeconds(
    int? retryAfterSeconds,
  ) => this(retryAfterSeconds: retryAfterSeconds);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CustomerVerificationCodeResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CustomerVerificationCodeResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  CustomerVerificationCodeResponseData call({
    Object? verificationId = const $CopyWithPlaceholder(),
    Object? expiresInSeconds = const $CopyWithPlaceholder(),
    Object? retryAfterSeconds = const $CopyWithPlaceholder(),
  }) {
    return CustomerVerificationCodeResponseData(
      verificationId: verificationId == const $CopyWithPlaceholder()
          ? _value.verificationId
          // ignore: cast_nullable_to_non_nullable
          : verificationId as String?,
      expiresInSeconds: expiresInSeconds == const $CopyWithPlaceholder()
          ? _value.expiresInSeconds
          // ignore: cast_nullable_to_non_nullable
          : expiresInSeconds as int?,
      retryAfterSeconds: retryAfterSeconds == const $CopyWithPlaceholder()
          ? _value.retryAfterSeconds
          // ignore: cast_nullable_to_non_nullable
          : retryAfterSeconds as int?,
    );
  }
}

extension $CustomerVerificationCodeResponseDataCopyWith
    on CustomerVerificationCodeResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfCustomerVerificationCodeResponseData.copyWith(...)` or like so:`instanceOfCustomerVerificationCodeResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CustomerVerificationCodeResponseDataCWProxy get copyWith =>
      _$CustomerVerificationCodeResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerVerificationCodeResponseData
_$CustomerVerificationCodeResponseDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CustomerVerificationCodeResponseData',
      json,
      ($checkedConvert) {
        final val = CustomerVerificationCodeResponseData(
          verificationId: $checkedConvert(
            'verification_id',
            (v) => v as String?,
          ),
          expiresInSeconds: $checkedConvert(
            'expires_in_seconds',
            (v) => (v as num?)?.toInt(),
          ),
          retryAfterSeconds: $checkedConvert(
            'retry_after_seconds',
            (v) => (v as num?)?.toInt(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'verificationId': 'verification_id',
        'expiresInSeconds': 'expires_in_seconds',
        'retryAfterSeconds': 'retry_after_seconds',
      },
    );

Map<String, dynamic> _$CustomerVerificationCodeResponseDataToJson(
  CustomerVerificationCodeResponseData instance,
) => <String, dynamic>{
  'verification_id': ?instance.verificationId,
  'expires_in_seconds': ?instance.expiresInSeconds,
  'retry_after_seconds': ?instance.retryAfterSeconds,
};
