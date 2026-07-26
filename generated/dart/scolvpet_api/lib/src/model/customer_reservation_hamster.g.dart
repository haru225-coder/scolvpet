// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_reservation_hamster.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CustomerReservationHamsterCWProxy {
  CustomerReservationHamster hamsterId(String? hamsterId);

  CustomerReservationHamster publicName(String? publicName);

  CustomerReservationHamster summary(String? summary);

  CustomerReservationHamster priceLabel(String? priceLabel);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CustomerReservationHamster(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CustomerReservationHamster(...).copyWith(id: 12, name: "My name")
  /// ````
  CustomerReservationHamster call({
    String? hamsterId,
    String? publicName,
    String? summary,
    String? priceLabel,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCustomerReservationHamster.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCustomerReservationHamster.copyWith.fieldName(...)`
class _$CustomerReservationHamsterCWProxyImpl
    implements _$CustomerReservationHamsterCWProxy {
  const _$CustomerReservationHamsterCWProxyImpl(this._value);

  final CustomerReservationHamster _value;

  @override
  CustomerReservationHamster hamsterId(String? hamsterId) =>
      this(hamsterId: hamsterId);

  @override
  CustomerReservationHamster publicName(String? publicName) =>
      this(publicName: publicName);

  @override
  CustomerReservationHamster summary(String? summary) => this(summary: summary);

  @override
  CustomerReservationHamster priceLabel(String? priceLabel) =>
      this(priceLabel: priceLabel);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CustomerReservationHamster(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CustomerReservationHamster(...).copyWith(id: 12, name: "My name")
  /// ````
  CustomerReservationHamster call({
    Object? hamsterId = const $CopyWithPlaceholder(),
    Object? publicName = const $CopyWithPlaceholder(),
    Object? summary = const $CopyWithPlaceholder(),
    Object? priceLabel = const $CopyWithPlaceholder(),
  }) {
    return CustomerReservationHamster(
      hamsterId: hamsterId == const $CopyWithPlaceholder()
          ? _value.hamsterId
          // ignore: cast_nullable_to_non_nullable
          : hamsterId as String?,
      publicName: publicName == const $CopyWithPlaceholder()
          ? _value.publicName
          // ignore: cast_nullable_to_non_nullable
          : publicName as String?,
      summary: summary == const $CopyWithPlaceholder()
          ? _value.summary
          // ignore: cast_nullable_to_non_nullable
          : summary as String?,
      priceLabel: priceLabel == const $CopyWithPlaceholder()
          ? _value.priceLabel
          // ignore: cast_nullable_to_non_nullable
          : priceLabel as String?,
    );
  }
}

extension $CustomerReservationHamsterCopyWith on CustomerReservationHamster {
  /// Returns a callable class that can be used as follows: `instanceOfCustomerReservationHamster.copyWith(...)` or like so:`instanceOfCustomerReservationHamster.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CustomerReservationHamsterCWProxy get copyWith =>
      _$CustomerReservationHamsterCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerReservationHamster _$CustomerReservationHamsterFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CustomerReservationHamster',
  json,
  ($checkedConvert) {
    final val = CustomerReservationHamster(
      hamsterId: $checkedConvert('hamster_id', (v) => v as String?),
      publicName: $checkedConvert('public_name', (v) => v as String?),
      summary: $checkedConvert('summary', (v) => v as String?),
      priceLabel: $checkedConvert('price_label', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'hamsterId': 'hamster_id',
    'publicName': 'public_name',
    'priceLabel': 'price_label',
  },
);

Map<String, dynamic> _$CustomerReservationHamsterToJson(
  CustomerReservationHamster instance,
) => <String, dynamic>{
  'hamster_id': ?instance.hamsterId,
  'public_name': ?instance.publicName,
  'summary': ?instance.summary,
  'price_label': ?instance.priceLabel,
};
