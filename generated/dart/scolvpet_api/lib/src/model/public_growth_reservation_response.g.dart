// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_growth_reservation_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublicGrowthReservationResponseCWProxy {
  PublicGrowthReservationResponse data(
    PublicGrowthReservationResponseData data,
  );

  PublicGrowthReservationResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicGrowthReservationResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicGrowthReservationResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicGrowthReservationResponse call({
    PublicGrowthReservationResponseData data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublicGrowthReservationResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublicGrowthReservationResponse.copyWith.fieldName(...)`
class _$PublicGrowthReservationResponseCWProxyImpl
    implements _$PublicGrowthReservationResponseCWProxy {
  const _$PublicGrowthReservationResponseCWProxyImpl(this._value);

  final PublicGrowthReservationResponse _value;

  @override
  PublicGrowthReservationResponse data(
    PublicGrowthReservationResponseData data,
  ) => this(data: data);

  @override
  PublicGrowthReservationResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicGrowthReservationResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicGrowthReservationResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicGrowthReservationResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return PublicGrowthReservationResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as PublicGrowthReservationResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $PublicGrowthReservationResponseCopyWith
    on PublicGrowthReservationResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPublicGrowthReservationResponse.copyWith(...)` or like so:`instanceOfPublicGrowthReservationResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublicGrowthReservationResponseCWProxy get copyWith =>
      _$PublicGrowthReservationResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicGrowthReservationResponse _$PublicGrowthReservationResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PublicGrowthReservationResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = PublicGrowthReservationResponse(
    data: $checkedConvert(
      'data',
      (v) => PublicGrowthReservationResponseData.fromJson(
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

Map<String, dynamic> _$PublicGrowthReservationResponseToJson(
  PublicGrowthReservationResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
