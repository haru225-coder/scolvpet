// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_growth_reservation_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublicGrowthReservationRequestCWProxy {
  PublicGrowthReservationRequest hamsterId(String hamsterId);

  PublicGrowthReservationRequest name(String name);

  PublicGrowthReservationRequest phone(String? phone);

  PublicGrowthReservationRequest wechat(String? wechat);

  PublicGrowthReservationRequest notes(String? notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicGrowthReservationRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicGrowthReservationRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicGrowthReservationRequest call({
    String hamsterId,
    String name,
    String? phone,
    String? wechat,
    String? notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublicGrowthReservationRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublicGrowthReservationRequest.copyWith.fieldName(...)`
class _$PublicGrowthReservationRequestCWProxyImpl
    implements _$PublicGrowthReservationRequestCWProxy {
  const _$PublicGrowthReservationRequestCWProxyImpl(this._value);

  final PublicGrowthReservationRequest _value;

  @override
  PublicGrowthReservationRequest hamsterId(String hamsterId) =>
      this(hamsterId: hamsterId);

  @override
  PublicGrowthReservationRequest name(String name) => this(name: name);

  @override
  PublicGrowthReservationRequest phone(String? phone) => this(phone: phone);

  @override
  PublicGrowthReservationRequest wechat(String? wechat) => this(wechat: wechat);

  @override
  PublicGrowthReservationRequest notes(String? notes) => this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicGrowthReservationRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicGrowthReservationRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicGrowthReservationRequest call({
    Object? hamsterId = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? phone = const $CopyWithPlaceholder(),
    Object? wechat = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return PublicGrowthReservationRequest(
      hamsterId: hamsterId == const $CopyWithPlaceholder()
          ? _value.hamsterId
          // ignore: cast_nullable_to_non_nullable
          : hamsterId as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      phone: phone == const $CopyWithPlaceholder()
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String?,
      wechat: wechat == const $CopyWithPlaceholder()
          ? _value.wechat
          // ignore: cast_nullable_to_non_nullable
          : wechat as String?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
    );
  }
}

extension $PublicGrowthReservationRequestCopyWith
    on PublicGrowthReservationRequest {
  /// Returns a callable class that can be used as follows: `instanceOfPublicGrowthReservationRequest.copyWith(...)` or like so:`instanceOfPublicGrowthReservationRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublicGrowthReservationRequestCWProxy get copyWith =>
      _$PublicGrowthReservationRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicGrowthReservationRequest _$PublicGrowthReservationRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PublicGrowthReservationRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['hamster_id', 'name']);
    final val = PublicGrowthReservationRequest(
      hamsterId: $checkedConvert('hamster_id', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      phone: $checkedConvert('phone', (v) => v as String?),
      wechat: $checkedConvert('wechat', (v) => v as String?),
      notes: $checkedConvert('notes', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {'hamsterId': 'hamster_id'},
);

Map<String, dynamic> _$PublicGrowthReservationRequestToJson(
  PublicGrowthReservationRequest instance,
) => <String, dynamic>{
  'hamster_id': instance.hamsterId,
  'name': instance.name,
  'phone': ?instance.phone,
  'wechat': ?instance.wechat,
  'notes': ?instance.notes,
};
