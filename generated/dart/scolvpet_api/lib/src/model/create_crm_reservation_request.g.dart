// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_crm_reservation_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateCrmReservationRequestCWProxy {
  CreateCrmReservationRequest contactId(String contactId);

  CreateCrmReservationRequest hamsterId(String? hamsterId);

  CreateCrmReservationRequest title(String? title);

  CreateCrmReservationRequest notes(String? notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateCrmReservationRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateCrmReservationRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateCrmReservationRequest call({
    String contactId,
    String? hamsterId,
    String? title,
    String? notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateCrmReservationRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateCrmReservationRequest.copyWith.fieldName(...)`
class _$CreateCrmReservationRequestCWProxyImpl
    implements _$CreateCrmReservationRequestCWProxy {
  const _$CreateCrmReservationRequestCWProxyImpl(this._value);

  final CreateCrmReservationRequest _value;

  @override
  CreateCrmReservationRequest contactId(String contactId) =>
      this(contactId: contactId);

  @override
  CreateCrmReservationRequest hamsterId(String? hamsterId) =>
      this(hamsterId: hamsterId);

  @override
  CreateCrmReservationRequest title(String? title) => this(title: title);

  @override
  CreateCrmReservationRequest notes(String? notes) => this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateCrmReservationRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateCrmReservationRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateCrmReservationRequest call({
    Object? contactId = const $CopyWithPlaceholder(),
    Object? hamsterId = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return CreateCrmReservationRequest(
      contactId: contactId == const $CopyWithPlaceholder()
          ? _value.contactId
          // ignore: cast_nullable_to_non_nullable
          : contactId as String,
      hamsterId: hamsterId == const $CopyWithPlaceholder()
          ? _value.hamsterId
          // ignore: cast_nullable_to_non_nullable
          : hamsterId as String?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
    );
  }
}

extension $CreateCrmReservationRequestCopyWith on CreateCrmReservationRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateCrmReservationRequest.copyWith(...)` or like so:`instanceOfCreateCrmReservationRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateCrmReservationRequestCWProxy get copyWith =>
      _$CreateCrmReservationRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCrmReservationRequest _$CreateCrmReservationRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CreateCrmReservationRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['contact_id']);
    final val = CreateCrmReservationRequest(
      contactId: $checkedConvert('contact_id', (v) => v as String),
      hamsterId: $checkedConvert('hamster_id', (v) => v as String?),
      title: $checkedConvert('title', (v) => v as String?),
      notes: $checkedConvert('notes', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {'contactId': 'contact_id', 'hamsterId': 'hamster_id'},
);

Map<String, dynamic> _$CreateCrmReservationRequestToJson(
  CreateCrmReservationRequest instance,
) => <String, dynamic>{
  'contact_id': instance.contactId,
  'hamster_id': ?instance.hamsterId,
  'title': ?instance.title,
  'notes': ?instance.notes,
};
