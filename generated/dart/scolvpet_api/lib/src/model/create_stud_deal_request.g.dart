// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_stud_deal_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateStudDealRequestCWProxy {
  CreateStudDealRequest listingId(String? listingId);

  CreateStudDealRequest side(CreateStudDealRequestSideEnum side);

  CreateStudDealRequest myHamsterLabel(String? myHamsterLabel);

  CreateStudDealRequest partnerCatteryName(String partnerCatteryName);

  CreateStudDealRequest partnerContact(String? partnerContact);

  CreateStudDealRequest partnerAnimalLabel(String? partnerAnimalLabel);

  CreateStudDealRequest feeCents(int? feeCents);

  CreateStudDealRequest currency(String? currency);

  CreateStudDealRequest notes(String? notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateStudDealRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateStudDealRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateStudDealRequest call({
    String? listingId,
    CreateStudDealRequestSideEnum side,
    String? myHamsterLabel,
    String partnerCatteryName,
    String? partnerContact,
    String? partnerAnimalLabel,
    int? feeCents,
    String? currency,
    String? notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateStudDealRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateStudDealRequest.copyWith.fieldName(...)`
class _$CreateStudDealRequestCWProxyImpl
    implements _$CreateStudDealRequestCWProxy {
  const _$CreateStudDealRequestCWProxyImpl(this._value);

  final CreateStudDealRequest _value;

  @override
  CreateStudDealRequest listingId(String? listingId) =>
      this(listingId: listingId);

  @override
  CreateStudDealRequest side(CreateStudDealRequestSideEnum side) =>
      this(side: side);

  @override
  CreateStudDealRequest myHamsterLabel(String? myHamsterLabel) =>
      this(myHamsterLabel: myHamsterLabel);

  @override
  CreateStudDealRequest partnerCatteryName(String partnerCatteryName) =>
      this(partnerCatteryName: partnerCatteryName);

  @override
  CreateStudDealRequest partnerContact(String? partnerContact) =>
      this(partnerContact: partnerContact);

  @override
  CreateStudDealRequest partnerAnimalLabel(String? partnerAnimalLabel) =>
      this(partnerAnimalLabel: partnerAnimalLabel);

  @override
  CreateStudDealRequest feeCents(int? feeCents) => this(feeCents: feeCents);

  @override
  CreateStudDealRequest currency(String? currency) => this(currency: currency);

  @override
  CreateStudDealRequest notes(String? notes) => this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateStudDealRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateStudDealRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateStudDealRequest call({
    Object? listingId = const $CopyWithPlaceholder(),
    Object? side = const $CopyWithPlaceholder(),
    Object? myHamsterLabel = const $CopyWithPlaceholder(),
    Object? partnerCatteryName = const $CopyWithPlaceholder(),
    Object? partnerContact = const $CopyWithPlaceholder(),
    Object? partnerAnimalLabel = const $CopyWithPlaceholder(),
    Object? feeCents = const $CopyWithPlaceholder(),
    Object? currency = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return CreateStudDealRequest(
      listingId: listingId == const $CopyWithPlaceholder()
          ? _value.listingId
          // ignore: cast_nullable_to_non_nullable
          : listingId as String?,
      side: side == const $CopyWithPlaceholder()
          ? _value.side
          // ignore: cast_nullable_to_non_nullable
          : side as CreateStudDealRequestSideEnum,
      myHamsterLabel: myHamsterLabel == const $CopyWithPlaceholder()
          ? _value.myHamsterLabel
          // ignore: cast_nullable_to_non_nullable
          : myHamsterLabel as String?,
      partnerCatteryName: partnerCatteryName == const $CopyWithPlaceholder()
          ? _value.partnerCatteryName
          // ignore: cast_nullable_to_non_nullable
          : partnerCatteryName as String,
      partnerContact: partnerContact == const $CopyWithPlaceholder()
          ? _value.partnerContact
          // ignore: cast_nullable_to_non_nullable
          : partnerContact as String?,
      partnerAnimalLabel: partnerAnimalLabel == const $CopyWithPlaceholder()
          ? _value.partnerAnimalLabel
          // ignore: cast_nullable_to_non_nullable
          : partnerAnimalLabel as String?,
      feeCents: feeCents == const $CopyWithPlaceholder()
          ? _value.feeCents
          // ignore: cast_nullable_to_non_nullable
          : feeCents as int?,
      currency: currency == const $CopyWithPlaceholder()
          ? _value.currency
          // ignore: cast_nullable_to_non_nullable
          : currency as String?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
    );
  }
}

extension $CreateStudDealRequestCopyWith on CreateStudDealRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateStudDealRequest.copyWith(...)` or like so:`instanceOfCreateStudDealRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateStudDealRequestCWProxy get copyWith =>
      _$CreateStudDealRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateStudDealRequest _$CreateStudDealRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CreateStudDealRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['side', 'partner_cattery_name']);
    final val = CreateStudDealRequest(
      listingId: $checkedConvert('listing_id', (v) => v as String?),
      side: $checkedConvert(
        'side',
        (v) => $enumDecode(_$CreateStudDealRequestSideEnumEnumMap, v),
      ),
      myHamsterLabel: $checkedConvert('my_hamster_label', (v) => v as String?),
      partnerCatteryName: $checkedConvert(
        'partner_cattery_name',
        (v) => v as String,
      ),
      partnerContact: $checkedConvert('partner_contact', (v) => v as String?),
      partnerAnimalLabel: $checkedConvert(
        'partner_animal_label',
        (v) => v as String?,
      ),
      feeCents: $checkedConvert('fee_cents', (v) => (v as num?)?.toInt()),
      currency: $checkedConvert('currency', (v) => v as String? ?? 'CNY'),
      notes: $checkedConvert('notes', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'listingId': 'listing_id',
    'myHamsterLabel': 'my_hamster_label',
    'partnerCatteryName': 'partner_cattery_name',
    'partnerContact': 'partner_contact',
    'partnerAnimalLabel': 'partner_animal_label',
    'feeCents': 'fee_cents',
  },
);

Map<String, dynamic> _$CreateStudDealRequestToJson(
  CreateStudDealRequest instance,
) => <String, dynamic>{
  'listing_id': ?instance.listingId,
  'side': _$CreateStudDealRequestSideEnumEnumMap[instance.side]!,
  'my_hamster_label': ?instance.myHamsterLabel,
  'partner_cattery_name': instance.partnerCatteryName,
  'partner_contact': ?instance.partnerContact,
  'partner_animal_label': ?instance.partnerAnimalLabel,
  'fee_cents': ?instance.feeCents,
  'currency': ?instance.currency,
  'notes': ?instance.notes,
};

const _$CreateStudDealRequestSideEnumEnumMap = {
  CreateStudDealRequestSideEnum.provider: 'provider',
  CreateStudDealRequestSideEnum.requester: 'requester',
};
