// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crm_reservation_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CrmReservationResponseCWProxy {
  CrmReservationResponse data(CrmReservation data);

  CrmReservationResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CrmReservationResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CrmReservationResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CrmReservationResponse call({CrmReservation data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCrmReservationResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCrmReservationResponse.copyWith.fieldName(...)`
class _$CrmReservationResponseCWProxyImpl
    implements _$CrmReservationResponseCWProxy {
  const _$CrmReservationResponseCWProxyImpl(this._value);

  final CrmReservationResponse _value;

  @override
  CrmReservationResponse data(CrmReservation data) => this(data: data);

  @override
  CrmReservationResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CrmReservationResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CrmReservationResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CrmReservationResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return CrmReservationResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as CrmReservation,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $CrmReservationResponseCopyWith on CrmReservationResponse {
  /// Returns a callable class that can be used as follows: `instanceOfCrmReservationResponse.copyWith(...)` or like so:`instanceOfCrmReservationResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CrmReservationResponseCWProxy get copyWith =>
      _$CrmReservationResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CrmReservationResponse _$CrmReservationResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CrmReservationResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = CrmReservationResponse(
    data: $checkedConvert(
      'data',
      (v) => CrmReservation.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$CrmReservationResponseToJson(
  CrmReservationResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
