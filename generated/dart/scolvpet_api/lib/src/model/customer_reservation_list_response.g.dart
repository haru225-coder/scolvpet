// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_reservation_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CustomerReservationListResponseCWProxy {
  CustomerReservationListResponse data(List<CustomerReservation>? data);

  CustomerReservationListResponse meta(Map<String, Object>? meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CustomerReservationListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CustomerReservationListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CustomerReservationListResponse call({
    List<CustomerReservation>? data,
    Map<String, Object>? meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCustomerReservationListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCustomerReservationListResponse.copyWith.fieldName(...)`
class _$CustomerReservationListResponseCWProxyImpl
    implements _$CustomerReservationListResponseCWProxy {
  const _$CustomerReservationListResponseCWProxyImpl(this._value);

  final CustomerReservationListResponse _value;

  @override
  CustomerReservationListResponse data(List<CustomerReservation>? data) =>
      this(data: data);

  @override
  CustomerReservationListResponse meta(Map<String, Object>? meta) =>
      this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CustomerReservationListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CustomerReservationListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CustomerReservationListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return CustomerReservationListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<CustomerReservation>?,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Map<String, Object>?,
    );
  }
}

extension $CustomerReservationListResponseCopyWith
    on CustomerReservationListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfCustomerReservationListResponse.copyWith(...)` or like so:`instanceOfCustomerReservationListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CustomerReservationListResponseCWProxy get copyWith =>
      _$CustomerReservationListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerReservationListResponse _$CustomerReservationListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CustomerReservationListResponse', json, ($checkedConvert) {
  final val = CustomerReservationListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>?)
          ?.map((e) => CustomerReservation.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    meta: $checkedConvert(
      'meta',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
  );
  return val;
});

Map<String, dynamic> _$CustomerReservationListResponseToJson(
  CustomerReservationListResponse instance,
) => <String, dynamic>{
  'data': ?instance.data?.map((e) => e.toJson()).toList(),
  'meta': ?instance.meta,
};
