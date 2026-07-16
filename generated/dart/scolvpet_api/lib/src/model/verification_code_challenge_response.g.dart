// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_code_challenge_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$VerificationCodeChallengeResponseCWProxy {
  VerificationCodeChallengeResponse data(
    VerificationCodeChallengeResponseData data,
  );

  VerificationCodeChallengeResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VerificationCodeChallengeResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VerificationCodeChallengeResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  VerificationCodeChallengeResponse call({
    VerificationCodeChallengeResponseData data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVerificationCodeChallengeResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVerificationCodeChallengeResponse.copyWith.fieldName(...)`
class _$VerificationCodeChallengeResponseCWProxyImpl
    implements _$VerificationCodeChallengeResponseCWProxy {
  const _$VerificationCodeChallengeResponseCWProxyImpl(this._value);

  final VerificationCodeChallengeResponse _value;

  @override
  VerificationCodeChallengeResponse data(
    VerificationCodeChallengeResponseData data,
  ) => this(data: data);

  @override
  VerificationCodeChallengeResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VerificationCodeChallengeResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VerificationCodeChallengeResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  VerificationCodeChallengeResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return VerificationCodeChallengeResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as VerificationCodeChallengeResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $VerificationCodeChallengeResponseCopyWith
    on VerificationCodeChallengeResponse {
  /// Returns a callable class that can be used as follows: `instanceOfVerificationCodeChallengeResponse.copyWith(...)` or like so:`instanceOfVerificationCodeChallengeResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VerificationCodeChallengeResponseCWProxy get copyWith =>
      _$VerificationCodeChallengeResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerificationCodeChallengeResponse _$VerificationCodeChallengeResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('VerificationCodeChallengeResponse', json, (
  $checkedConvert,
) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = VerificationCodeChallengeResponse(
    data: $checkedConvert(
      'data',
      (v) => VerificationCodeChallengeResponseData.fromJson(
        v as Map<String, dynamic>,
      ),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$VerificationCodeChallengeResponseToJson(
  VerificationCodeChallengeResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
