// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_verification_code_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CustomerVerificationCodeResponseCWProxy {
  CustomerVerificationCodeResponse data(
    CustomerVerificationCodeResponseData? data,
  );

  CustomerVerificationCodeResponse meta(Map<String, Object>? meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CustomerVerificationCodeResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CustomerVerificationCodeResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CustomerVerificationCodeResponse call({
    CustomerVerificationCodeResponseData? data,
    Map<String, Object>? meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCustomerVerificationCodeResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCustomerVerificationCodeResponse.copyWith.fieldName(...)`
class _$CustomerVerificationCodeResponseCWProxyImpl
    implements _$CustomerVerificationCodeResponseCWProxy {
  const _$CustomerVerificationCodeResponseCWProxyImpl(this._value);

  final CustomerVerificationCodeResponse _value;

  @override
  CustomerVerificationCodeResponse data(
    CustomerVerificationCodeResponseData? data,
  ) => this(data: data);

  @override
  CustomerVerificationCodeResponse meta(Map<String, Object>? meta) =>
      this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CustomerVerificationCodeResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CustomerVerificationCodeResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CustomerVerificationCodeResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return CustomerVerificationCodeResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as CustomerVerificationCodeResponseData?,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Map<String, Object>?,
    );
  }
}

extension $CustomerVerificationCodeResponseCopyWith
    on CustomerVerificationCodeResponse {
  /// Returns a callable class that can be used as follows: `instanceOfCustomerVerificationCodeResponse.copyWith(...)` or like so:`instanceOfCustomerVerificationCodeResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CustomerVerificationCodeResponseCWProxy get copyWith =>
      _$CustomerVerificationCodeResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerVerificationCodeResponse _$CustomerVerificationCodeResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CustomerVerificationCodeResponse', json, (
  $checkedConvert,
) {
  final val = CustomerVerificationCodeResponse(
    data: $checkedConvert(
      'data',
      (v) => v == null
          ? null
          : CustomerVerificationCodeResponseData.fromJson(
              v as Map<String, dynamic>,
            ),
    ),
    meta: $checkedConvert(
      'meta',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
  );
  return val;
});

Map<String, dynamic> _$CustomerVerificationCodeResponseToJson(
  CustomerVerificationCodeResponse instance,
) => <String, dynamic>{
  'data': ?instance.data?.toJson(),
  'meta': ?instance.meta,
};
