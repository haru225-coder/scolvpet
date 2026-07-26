// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_reservation_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CustomerReservationResponseCWProxy {
  CustomerReservationResponse data(CustomerReservation? data);

  CustomerReservationResponse meta(Map<String, Object>? meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CustomerReservationResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CustomerReservationResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CustomerReservationResponse call({
    CustomerReservation? data,
    Map<String, Object>? meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCustomerReservationResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCustomerReservationResponse.copyWith.fieldName(...)`
class _$CustomerReservationResponseCWProxyImpl
    implements _$CustomerReservationResponseCWProxy {
  const _$CustomerReservationResponseCWProxyImpl(this._value);

  final CustomerReservationResponse _value;

  @override
  CustomerReservationResponse data(CustomerReservation? data) =>
      this(data: data);

  @override
  CustomerReservationResponse meta(Map<String, Object>? meta) =>
      this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CustomerReservationResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CustomerReservationResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CustomerReservationResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return CustomerReservationResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as CustomerReservation?,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Map<String, Object>?,
    );
  }
}

extension $CustomerReservationResponseCopyWith on CustomerReservationResponse {
  /// Returns a callable class that can be used as follows: `instanceOfCustomerReservationResponse.copyWith(...)` or like so:`instanceOfCustomerReservationResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CustomerReservationResponseCWProxy get copyWith =>
      _$CustomerReservationResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerReservationResponse _$CustomerReservationResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CustomerReservationResponse', json, ($checkedConvert) {
  final val = CustomerReservationResponse(
    data: $checkedConvert(
      'data',
      (v) => v == null
          ? null
          : CustomerReservation.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
  );
  return val;
});

Map<String, dynamic> _$CustomerReservationResponseToJson(
  CustomerReservationResponse instance,
) => <String, dynamic>{
  'data': ?instance.data?.toJson(),
  'meta': ?instance.meta,
};
