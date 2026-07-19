// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crm_reservation.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CrmReservationCWProxy {
  CrmReservation id(String id);

  CrmReservation contactId(String contactId);

  CrmReservation hamsterId(String? hamsterId);

  CrmReservation title(String title);

  CrmReservation status(CrmReservationStatusEnum status);

  CrmReservation reservedAt(DateTime reservedAt);

  CrmReservation notes(String? notes);

  CrmReservation version(int version);

  CrmReservation contactName(String? contactName);

  CrmReservation hamsterName(String? hamsterName);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CrmReservation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CrmReservation(...).copyWith(id: 12, name: "My name")
  /// ````
  CrmReservation call({
    String id,
    String contactId,
    String? hamsterId,
    String title,
    CrmReservationStatusEnum status,
    DateTime reservedAt,
    String? notes,
    int version,
    String? contactName,
    String? hamsterName,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCrmReservation.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCrmReservation.copyWith.fieldName(...)`
class _$CrmReservationCWProxyImpl implements _$CrmReservationCWProxy {
  const _$CrmReservationCWProxyImpl(this._value);

  final CrmReservation _value;

  @override
  CrmReservation id(String id) => this(id: id);

  @override
  CrmReservation contactId(String contactId) => this(contactId: contactId);

  @override
  CrmReservation hamsterId(String? hamsterId) => this(hamsterId: hamsterId);

  @override
  CrmReservation title(String title) => this(title: title);

  @override
  CrmReservation status(CrmReservationStatusEnum status) =>
      this(status: status);

  @override
  CrmReservation reservedAt(DateTime reservedAt) =>
      this(reservedAt: reservedAt);

  @override
  CrmReservation notes(String? notes) => this(notes: notes);

  @override
  CrmReservation version(int version) => this(version: version);

  @override
  CrmReservation contactName(String? contactName) =>
      this(contactName: contactName);

  @override
  CrmReservation hamsterName(String? hamsterName) =>
      this(hamsterName: hamsterName);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CrmReservation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CrmReservation(...).copyWith(id: 12, name: "My name")
  /// ````
  CrmReservation call({
    Object? id = const $CopyWithPlaceholder(),
    Object? contactId = const $CopyWithPlaceholder(),
    Object? hamsterId = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? reservedAt = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? contactName = const $CopyWithPlaceholder(),
    Object? hamsterName = const $CopyWithPlaceholder(),
  }) {
    return CrmReservation(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
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
          : title as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as CrmReservationStatusEnum,
      reservedAt: reservedAt == const $CopyWithPlaceholder()
          ? _value.reservedAt
          // ignore: cast_nullable_to_non_nullable
          : reservedAt as DateTime,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
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

extension $CrmReservationCopyWith on CrmReservation {
  /// Returns a callable class that can be used as follows: `instanceOfCrmReservation.copyWith(...)` or like so:`instanceOfCrmReservation.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CrmReservationCWProxy get copyWith => _$CrmReservationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CrmReservation _$CrmReservationFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CrmReservation',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'contact_id',
            'title',
            'status',
            'reserved_at',
            'version',
          ],
        );
        final val = CrmReservation(
          id: $checkedConvert('id', (v) => v as String),
          contactId: $checkedConvert('contact_id', (v) => v as String),
          hamsterId: $checkedConvert('hamster_id', (v) => v as String?),
          title: $checkedConvert('title', (v) => v as String),
          status: $checkedConvert(
            'status',
            (v) => $enumDecode(_$CrmReservationStatusEnumEnumMap, v),
          ),
          reservedAt: $checkedConvert(
            'reserved_at',
            (v) => DateTime.parse(v as String),
          ),
          notes: $checkedConvert('notes', (v) => v as String?),
          version: $checkedConvert('version', (v) => (v as num).toInt()),
          contactName: $checkedConvert('contact_name', (v) => v as String?),
          hamsterName: $checkedConvert('hamster_name', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'contactId': 'contact_id',
        'hamsterId': 'hamster_id',
        'reservedAt': 'reserved_at',
        'contactName': 'contact_name',
        'hamsterName': 'hamster_name',
      },
    );

Map<String, dynamic> _$CrmReservationToJson(CrmReservation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contact_id': instance.contactId,
      'hamster_id': ?instance.hamsterId,
      'title': instance.title,
      'status': _$CrmReservationStatusEnumEnumMap[instance.status]!,
      'reserved_at': instance.reservedAt.toIso8601String(),
      'notes': ?instance.notes,
      'version': instance.version,
      'contact_name': ?instance.contactName,
      'hamster_name': ?instance.hamsterName,
    };

const _$CrmReservationStatusEnumEnumMap = {
  CrmReservationStatusEnum.held: 'held',
  CrmReservationStatusEnum.confirmed: 'confirmed',
  CrmReservationStatusEnum.handedOver: 'handed_over',
  CrmReservationStatusEnum.cancelled: 'cancelled',
};
