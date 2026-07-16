// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_code_challenge_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$VerificationCodeChallengeResponseDataCWProxy {
  VerificationCodeChallengeResponseData verificationId(String verificationId);

  VerificationCodeChallengeResponseData expiresInSeconds(int expiresInSeconds);

  VerificationCodeChallengeResponseData retryAfterSeconds(
    int retryAfterSeconds,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VerificationCodeChallengeResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VerificationCodeChallengeResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  VerificationCodeChallengeResponseData call({
    String verificationId,
    int expiresInSeconds,
    int retryAfterSeconds,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVerificationCodeChallengeResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVerificationCodeChallengeResponseData.copyWith.fieldName(...)`
class _$VerificationCodeChallengeResponseDataCWProxyImpl
    implements _$VerificationCodeChallengeResponseDataCWProxy {
  const _$VerificationCodeChallengeResponseDataCWProxyImpl(this._value);

  final VerificationCodeChallengeResponseData _value;

  @override
  VerificationCodeChallengeResponseData verificationId(String verificationId) =>
      this(verificationId: verificationId);

  @override
  VerificationCodeChallengeResponseData expiresInSeconds(
    int expiresInSeconds,
  ) => this(expiresInSeconds: expiresInSeconds);

  @override
  VerificationCodeChallengeResponseData retryAfterSeconds(
    int retryAfterSeconds,
  ) => this(retryAfterSeconds: retryAfterSeconds);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VerificationCodeChallengeResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VerificationCodeChallengeResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  VerificationCodeChallengeResponseData call({
    Object? verificationId = const $CopyWithPlaceholder(),
    Object? expiresInSeconds = const $CopyWithPlaceholder(),
    Object? retryAfterSeconds = const $CopyWithPlaceholder(),
  }) {
    return VerificationCodeChallengeResponseData(
      verificationId: verificationId == const $CopyWithPlaceholder()
          ? _value.verificationId
          // ignore: cast_nullable_to_non_nullable
          : verificationId as String,
      expiresInSeconds: expiresInSeconds == const $CopyWithPlaceholder()
          ? _value.expiresInSeconds
          // ignore: cast_nullable_to_non_nullable
          : expiresInSeconds as int,
      retryAfterSeconds: retryAfterSeconds == const $CopyWithPlaceholder()
          ? _value.retryAfterSeconds
          // ignore: cast_nullable_to_non_nullable
          : retryAfterSeconds as int,
    );
  }
}

extension $VerificationCodeChallengeResponseDataCopyWith
    on VerificationCodeChallengeResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfVerificationCodeChallengeResponseData.copyWith(...)` or like so:`instanceOfVerificationCodeChallengeResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VerificationCodeChallengeResponseDataCWProxy get copyWith =>
      _$VerificationCodeChallengeResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerificationCodeChallengeResponseData
_$VerificationCodeChallengeResponseDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'VerificationCodeChallengeResponseData',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'verification_id',
            'expires_in_seconds',
            'retry_after_seconds',
          ],
        );
        final val = VerificationCodeChallengeResponseData(
          verificationId: $checkedConvert(
            'verification_id',
            (v) => v as String,
          ),
          expiresInSeconds: $checkedConvert(
            'expires_in_seconds',
            (v) => (v as num).toInt(),
          ),
          retryAfterSeconds: $checkedConvert(
            'retry_after_seconds',
            (v) => (v as num).toInt(),
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

Map<String, dynamic> _$VerificationCodeChallengeResponseDataToJson(
  VerificationCodeChallengeResponseData instance,
) => <String, dynamic>{
  'verification_id': instance.verificationId,
  'expires_in_seconds': instance.expiresInSeconds,
  'retry_after_seconds': instance.retryAfterSeconds,
};
