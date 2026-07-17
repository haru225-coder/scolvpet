// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crm_reservation_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CrmReservationListResponseCWProxy {
  CrmReservationListResponse data(List<CrmReservation> data);

  CrmReservationListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CrmReservationListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CrmReservationListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CrmReservationListResponse call({
    List<CrmReservation> data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCrmReservationListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCrmReservationListResponse.copyWith.fieldName(...)`
class _$CrmReservationListResponseCWProxyImpl
    implements _$CrmReservationListResponseCWProxy {
  const _$CrmReservationListResponseCWProxyImpl(this._value);

  final CrmReservationListResponse _value;

  @override
  CrmReservationListResponse data(List<CrmReservation> data) =>
      this(data: data);

  @override
  CrmReservationListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CrmReservationListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CrmReservationListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CrmReservationListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return CrmReservationListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<CrmReservation>,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $CrmReservationListResponseCopyWith on CrmReservationListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfCrmReservationListResponse.copyWith(...)` or like so:`instanceOfCrmReservationListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CrmReservationListResponseCWProxy get copyWith =>
      _$CrmReservationListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CrmReservationListResponse _$CrmReservationListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CrmReservationListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = CrmReservationListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => CrmReservation.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$CrmReservationListResponseToJson(
  CrmReservationListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'meta': instance.meta.toJson(),
};
