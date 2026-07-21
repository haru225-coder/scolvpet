// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_contract_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateContractRequestCWProxy {
  CreateContractRequest templateId(String templateId);

  CreateContractRequest contactId(String? contactId);

  CreateContractRequest handoverId(String? handoverId);

  CreateContractRequest reservationId(String? reservationId);

  CreateContractRequest title(String? title);

  CreateContractRequest notes(String? notes);

  CreateContractRequest contactName(String? contactName);

  CreateContractRequest hamsterName(String? hamsterName);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateContractRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateContractRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateContractRequest call({
    String templateId,
    String? contactId,
    String? handoverId,
    String? reservationId,
    String? title,
    String? notes,
    String? contactName,
    String? hamsterName,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateContractRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateContractRequest.copyWith.fieldName(...)`
class _$CreateContractRequestCWProxyImpl
    implements _$CreateContractRequestCWProxy {
  const _$CreateContractRequestCWProxyImpl(this._value);

  final CreateContractRequest _value;

  @override
  CreateContractRequest templateId(String templateId) =>
      this(templateId: templateId);

  @override
  CreateContractRequest contactId(String? contactId) =>
      this(contactId: contactId);

  @override
  CreateContractRequest handoverId(String? handoverId) =>
      this(handoverId: handoverId);

  @override
  CreateContractRequest reservationId(String? reservationId) =>
      this(reservationId: reservationId);

  @override
  CreateContractRequest title(String? title) => this(title: title);

  @override
  CreateContractRequest notes(String? notes) => this(notes: notes);

  @override
  CreateContractRequest contactName(String? contactName) =>
      this(contactName: contactName);

  @override
  CreateContractRequest hamsterName(String? hamsterName) =>
      this(hamsterName: hamsterName);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateContractRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateContractRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateContractRequest call({
    Object? templateId = const $CopyWithPlaceholder(),
    Object? contactId = const $CopyWithPlaceholder(),
    Object? handoverId = const $CopyWithPlaceholder(),
    Object? reservationId = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? contactName = const $CopyWithPlaceholder(),
    Object? hamsterName = const $CopyWithPlaceholder(),
  }) {
    return CreateContractRequest(
      templateId: templateId == const $CopyWithPlaceholder()
          ? _value.templateId
          // ignore: cast_nullable_to_non_nullable
          : templateId as String,
      contactId: contactId == const $CopyWithPlaceholder()
          ? _value.contactId
          // ignore: cast_nullable_to_non_nullable
          : contactId as String?,
      handoverId: handoverId == const $CopyWithPlaceholder()
          ? _value.handoverId
          // ignore: cast_nullable_to_non_nullable
          : handoverId as String?,
      reservationId: reservationId == const $CopyWithPlaceholder()
          ? _value.reservationId
          // ignore: cast_nullable_to_non_nullable
          : reservationId as String?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
      contactName: contactName == const $CopyWithPlaceholder()
          ? _value.contactName
          // ignore: cast_nullable_to_non_nullable
          : contactName as String?,
      hamsterName: hamsterName == const $CopyWithPlaceholder()
          ? _value.hamsterName
          // ignore: cast_nullable_to_non_nullable
          : hamsterName as String?,
    );
  }
}

extension $CreateContractRequestCopyWith on CreateContractRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateContractRequest.copyWith(...)` or like so:`instanceOfCreateContractRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateContractRequestCWProxy get copyWith =>
      _$CreateContractRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateContractRequest _$CreateContractRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CreateContractRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['template_id']);
    final val = CreateContractRequest(
      templateId: $checkedConvert('template_id', (v) => v as String),
      contactId: $checkedConvert('contact_id', (v) => v as String?),
      handoverId: $checkedConvert('handover_id', (v) => v as String?),
      reservationId: $checkedConvert('reservation_id', (v) => v as String?),
      title: $checkedConvert('title', (v) => v as String?),
      notes: $checkedConvert('notes', (v) => v as String?),
      contactName: $checkedConvert('contact_name', (v) => v as String?),
      hamsterName: $checkedConvert('hamster_name', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'templateId': 'template_id',
    'contactId': 'contact_id',
    'handoverId': 'handover_id',
    'reservationId': 'reservation_id',
    'contactName': 'contact_name',
    'hamsterName': 'hamster_name',
  },
);

Map<String, dynamic> _$CreateContractRequestToJson(
  CreateContractRequest instance,
) => <String, dynamic>{
  'template_id': instance.templateId,
  'contact_id': ?instance.contactId,
  'handover_id': ?instance.handoverId,
  'reservation_id': ?instance.reservationId,
  'title': ?instance.title,
  'notes': ?instance.notes,
  'contact_name': ?instance.contactName,
  'hamster_name': ?instance.hamsterName,
};
