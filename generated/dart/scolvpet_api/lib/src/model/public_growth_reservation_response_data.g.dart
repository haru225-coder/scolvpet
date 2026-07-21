// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_growth_reservation_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublicGrowthReservationResponseDataCWProxy {
  PublicGrowthReservationResponseData reservationId(String reservationId);

  PublicGrowthReservationResponseData contactId(String contactId);

  PublicGrowthReservationResponseData contactReused(bool? contactReused);

  PublicGrowthReservationResponseData hamsterId(String hamsterId);

  PublicGrowthReservationResponseData status(
    PublicGrowthReservationResponseDataStatusEnum status,
  );

  PublicGrowthReservationResponseData title(String? title);

  PublicGrowthReservationResponseData siteId(String? siteId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicGrowthReservationResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicGrowthReservationResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicGrowthReservationResponseData call({
    String reservationId,
    String contactId,
    bool? contactReused,
    String hamsterId,
    PublicGrowthReservationResponseDataStatusEnum status,
    String? title,
    String? siteId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublicGrowthReservationResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublicGrowthReservationResponseData.copyWith.fieldName(...)`
class _$PublicGrowthReservationResponseDataCWProxyImpl
    implements _$PublicGrowthReservationResponseDataCWProxy {
  const _$PublicGrowthReservationResponseDataCWProxyImpl(this._value);

  final PublicGrowthReservationResponseData _value;

  @override
  PublicGrowthReservationResponseData reservationId(String reservationId) =>
      this(reservationId: reservationId);

  @override
  PublicGrowthReservationResponseData contactId(String contactId) =>
      this(contactId: contactId);

  @override
  PublicGrowthReservationResponseData contactReused(bool? contactReused) =>
      this(contactReused: contactReused);

  @override
  PublicGrowthReservationResponseData hamsterId(String hamsterId) =>
      this(hamsterId: hamsterId);

  @override
  PublicGrowthReservationResponseData status(
    PublicGrowthReservationResponseDataStatusEnum status,
  ) => this(status: status);

  @override
  PublicGrowthReservationResponseData title(String? title) =>
      this(title: title);

  @override
  PublicGrowthReservationResponseData siteId(String? siteId) =>
      this(siteId: siteId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicGrowthReservationResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicGrowthReservationResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicGrowthReservationResponseData call({
    Object? reservationId = const $CopyWithPlaceholder(),
    Object? contactId = const $CopyWithPlaceholder(),
    Object? contactReused = const $CopyWithPlaceholder(),
    Object? hamsterId = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? siteId = const $CopyWithPlaceholder(),
  }) {
    return PublicGrowthReservationResponseData(
      reservationId: reservationId == const $CopyWithPlaceholder()
          ? _value.reservationId
          // ignore: cast_nullable_to_non_nullable
          : reservationId as String,
      contactId: contactId == const $CopyWithPlaceholder()
          ? _value.contactId
          // ignore: cast_nullable_to_non_nullable
          : contactId as String,
      contactReused: contactReused == const $CopyWithPlaceholder()
          ? _value.contactReused
          // ignore: cast_nullable_to_non_nullable
          : contactReused as bool?,
      hamsterId: hamsterId == const $CopyWithPlaceholder()
          ? _value.hamsterId
          // ignore: cast_nullable_to_non_nullable
          : hamsterId as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as PublicGrowthReservationResponseDataStatusEnum,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      siteId: siteId == const $CopyWithPlaceholder()
          ? _value.siteId
          // ignore: cast_nullable_to_non_nullable
          : siteId as String?,
    );
  }
}

extension $PublicGrowthReservationResponseDataCopyWith
    on PublicGrowthReservationResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfPublicGrowthReservationResponseData.copyWith(...)` or like so:`instanceOfPublicGrowthReservationResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublicGrowthReservationResponseDataCWProxy get copyWith =>
      _$PublicGrowthReservationResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicGrowthReservationResponseData
_$PublicGrowthReservationResponseDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PublicGrowthReservationResponseData',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'reservation_id',
            'contact_id',
            'hamster_id',
            'status',
          ],
        );
        final val = PublicGrowthReservationResponseData(
          reservationId: $checkedConvert('reservation_id', (v) => v as String),
          contactId: $checkedConvert('contact_id', (v) => v as String),
          contactReused: $checkedConvert('contact_reused', (v) => v as bool?),
          hamsterId: $checkedConvert('hamster_id', (v) => v as String),
          status: $checkedConvert(
            'status',
            (v) => $enumDecode(
              _$PublicGrowthReservationResponseDataStatusEnumEnumMap,
              v,
            ),
          ),
          title: $checkedConvert('title', (v) => v as String?),
          siteId: $checkedConvert('site_id', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'reservationId': 'reservation_id',
        'contactId': 'contact_id',
        'contactReused': 'contact_reused',
        'hamsterId': 'hamster_id',
        'siteId': 'site_id',
      },
    );

Map<String, dynamic> _$PublicGrowthReservationResponseDataToJson(
  PublicGrowthReservationResponseData instance,
) => <String, dynamic>{
  'reservation_id': instance.reservationId,
  'contact_id': instance.contactId,
  'contact_reused': ?instance.contactReused,
  'hamster_id': instance.hamsterId,
  'status':
      _$PublicGrowthReservationResponseDataStatusEnumEnumMap[instance.status]!,
  'title': ?instance.title,
  'site_id': ?instance.siteId,
};

const _$PublicGrowthReservationResponseDataStatusEnumEnumMap = {
  PublicGrowthReservationResponseDataStatusEnum.held: 'held',
};
