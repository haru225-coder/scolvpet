// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_crm_handover_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateCrmHandoverRequestCWProxy {
  CreateCrmHandoverRequest contactId(String contactId);

  CreateCrmHandoverRequest reservationId(String? reservationId);

  CreateCrmHandoverRequest hamsterId(String? hamsterId);

  CreateCrmHandoverRequest notes(String? notes);

  CreateCrmHandoverRequest scheduledAt(DateTime? scheduledAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateCrmHandoverRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateCrmHandoverRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateCrmHandoverRequest call({
    String contactId,
    String? reservationId,
    String? hamsterId,
    String? notes,
    DateTime? scheduledAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateCrmHandoverRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateCrmHandoverRequest.copyWith.fieldName(...)`
class _$CreateCrmHandoverRequestCWProxyImpl
    implements _$CreateCrmHandoverRequestCWProxy {
  const _$CreateCrmHandoverRequestCWProxyImpl(this._value);

  final CreateCrmHandoverRequest _value;

  @override
  CreateCrmHandoverRequest contactId(String contactId) =>
      this(contactId: contactId);

  @override
  CreateCrmHandoverRequest reservationId(String? reservationId) =>
      this(reservationId: reservationId);

  @override
  CreateCrmHandoverRequest hamsterId(String? hamsterId) =>
      this(hamsterId: hamsterId);

  @override
  CreateCrmHandoverRequest notes(String? notes) => this(notes: notes);

  @override
  CreateCrmHandoverRequest scheduledAt(DateTime? scheduledAt) =>
      this(scheduledAt: scheduledAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateCrmHandoverRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateCrmHandoverRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateCrmHandoverRequest call({
    Object? contactId = const $CopyWithPlaceholder(),
    Object? reservationId = const $CopyWithPlaceholder(),
    Object? hamsterId = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? scheduledAt = const $CopyWithPlaceholder(),
  }) {
    return CreateCrmHandoverRequest(
      contactId: contactId == const $CopyWithPlaceholder()
          ? _value.contactId
          // ignore: cast_nullable_to_non_nullable
          : contactId as String,
      reservationId: reservationId == const $CopyWithPlaceholder()
          ? _value.reservationId
          // ignore: cast_nullable_to_non_nullable
          : reservationId as String?,
      hamsterId: hamsterId == const $CopyWithPlaceholder()
          ? _value.hamsterId
          // ignore: cast_nullable_to_non_nullable
          : hamsterId as String?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
      scheduledAt: scheduledAt == const $CopyWithPlaceholder()
          ? _value.scheduledAt
          // ignore: cast_nullable_to_non_nullable
          : scheduledAt as DateTime?,
    );
  }
}

extension $CreateCrmHandoverRequestCopyWith on CreateCrmHandoverRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateCrmHandoverRequest.copyWith(...)` or like so:`instanceOfCreateCrmHandoverRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateCrmHandoverRequestCWProxy get copyWith =>
      _$CreateCrmHandoverRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCrmHandoverRequest _$CreateCrmHandoverRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CreateCrmHandoverRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['contact_id']);
    final val = CreateCrmHandoverRequest(
      contactId: $checkedConvert('contact_id', (v) => v as String),
      reservationId: $checkedConvert('reservation_id', (v) => v as String?),
      hamsterId: $checkedConvert('hamster_id', (v) => v as String?),
      notes: $checkedConvert('notes', (v) => v as String?),
      scheduledAt: $checkedConvert(
        'scheduled_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'contactId': 'contact_id',
    'reservationId': 'reservation_id',
    'hamsterId': 'hamster_id',
    'scheduledAt': 'scheduled_at',
  },
);

Map<String, dynamic> _$CreateCrmHandoverRequestToJson(
  CreateCrmHandoverRequest instance,
) => <String, dynamic>{
  'contact_id': instance.contactId,
  'reservation_id': ?instance.reservationId,
  'hamster_id': ?instance.hamsterId,
  'notes': ?instance.notes,
  'scheduled_at': ?instance.scheduledAt?.toIso8601String(),
};
