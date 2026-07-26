// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_session_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CustomerSessionResponseCWProxy {
  CustomerSessionResponse data(CustomerSessionResponseData? data);

  CustomerSessionResponse meta(Map<String, Object>? meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CustomerSessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CustomerSessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CustomerSessionResponse call({
    CustomerSessionResponseData? data,
    Map<String, Object>? meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCustomerSessionResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCustomerSessionResponse.copyWith.fieldName(...)`
class _$CustomerSessionResponseCWProxyImpl
    implements _$CustomerSessionResponseCWProxy {
  const _$CustomerSessionResponseCWProxyImpl(this._value);

  final CustomerSessionResponse _value;

  @override
  CustomerSessionResponse data(CustomerSessionResponseData? data) =>
      this(data: data);

  @override
  CustomerSessionResponse meta(Map<String, Object>? meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CustomerSessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CustomerSessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CustomerSessionResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return CustomerSessionResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as CustomerSessionResponseData?,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Map<String, Object>?,
    );
  }
}

extension $CustomerSessionResponseCopyWith on CustomerSessionResponse {
  /// Returns a callable class that can be used as follows: `instanceOfCustomerSessionResponse.copyWith(...)` or like so:`instanceOfCustomerSessionResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CustomerSessionResponseCWProxy get copyWith =>
      _$CustomerSessionResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerSessionResponse _$CustomerSessionResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CustomerSessionResponse', json, ($checkedConvert) {
  final val = CustomerSessionResponse(
    data: $checkedConvert(
      'data',
      (v) => v == null
          ? null
          : CustomerSessionResponseData.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
  );
  return val;
});

Map<String, dynamic> _$CustomerSessionResponseToJson(
  CustomerSessionResponse instance,
) => <String, dynamic>{
  'data': ?instance.data?.toJson(),
  'meta': ?instance.meta,
};
