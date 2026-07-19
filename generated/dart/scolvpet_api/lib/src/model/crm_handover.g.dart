// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crm_handover.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CrmHandoverCWProxy {
  CrmHandover id(String id);

  CrmHandover contactId(String contactId);

  CrmHandover reservationId(String? reservationId);

  CrmHandover hamsterId(String? hamsterId);

  CrmHandover status(CrmHandoverStatusEnum status);

  CrmHandover scheduledAt(DateTime scheduledAt);

  CrmHandover completedAt(DateTime? completedAt);

  CrmHandover notes(String? notes);

  CrmHandover version(int version);

  CrmHandover contactName(String? contactName);

  CrmHandover hamsterName(String? hamsterName);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CrmHandover(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CrmHandover(...).copyWith(id: 12, name: "My name")
  /// ````
  CrmHandover call({
    String id,
    String contactId,
    String? reservationId,
    String? hamsterId,
    CrmHandoverStatusEnum status,
    DateTime scheduledAt,
    DateTime? completedAt,
    String? notes,
    int version,
    String? contactName,
    String? hamsterName,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCrmHandover.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCrmHandover.copyWith.fieldName(...)`
class _$CrmHandoverCWProxyImpl implements _$CrmHandoverCWProxy {
  const _$CrmHandoverCWProxyImpl(this._value);

  final CrmHandover _value;

  @override
  CrmHandover id(String id) => this(id: id);

  @override
  CrmHandover contactId(String contactId) => this(contactId: contactId);

  @override
  CrmHandover reservationId(String? reservationId) =>
      this(reservationId: reservationId);

  @override
  CrmHandover hamsterId(String? hamsterId) => this(hamsterId: hamsterId);

  @override
  CrmHandover status(CrmHandoverStatusEnum status) => this(status: status);

  @override
  CrmHandover scheduledAt(DateTime scheduledAt) =>
      this(scheduledAt: scheduledAt);

  @override
  CrmHandover completedAt(DateTime? completedAt) =>
      this(completedAt: completedAt);

  @override
  CrmHandover notes(String? notes) => this(notes: notes);

  @override
  CrmHandover version(int version) => this(version: version);

  @override
  CrmHandover contactName(String? contactName) =>
      this(contactName: contactName);

  @override
  CrmHandover hamsterName(String? hamsterName) =>
      this(hamsterName: hamsterName);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CrmHandover(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CrmHandover(...).copyWith(id: 12, name: "My name")
  /// ````
  CrmHandover call({
    Object? id = const $CopyWithPlaceholder(),
    Object? contactId = const $CopyWithPlaceholder(),
    Object? reservationId = const $CopyWithPlaceholder(),
    Object? hamsterId = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? scheduledAt = const $CopyWithPlaceholder(),
    Object? completedAt = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? contactName = const $CopyWithPlaceholder(),
    Object? hamsterName = const $CopyWithPlaceholder(),
  }) {
    return CrmHandover(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
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
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as CrmHandoverStatusEnum,
      scheduledAt: scheduledAt == const $CopyWithPlaceholder()
          ? _value.scheduledAt
          // ignore: cast_nullable_to_non_nullable
          : scheduledAt as DateTime,
      completedAt: completedAt == const $CopyWithPlaceholder()
          ? _value.completedAt
          // ignore: cast_nullable_to_non_nullable
          : completedAt as DateTime?,
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

extension $CrmHandoverCopyWith on CrmHandover {
  /// Returns a callable class that can be used as follows: `instanceOfCrmHandover.copyWith(...)` or like so:`instanceOfCrmHandover.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CrmHandoverCWProxy get copyWith => _$CrmHandoverCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CrmHandover _$CrmHandoverFromJson(Map<String, dynamic> json) => $checkedCreate(
  'CrmHandover',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'contact_id',
        'status',
        'scheduled_at',
        'version',
      ],
    );
    final val = CrmHandover(
      id: $checkedConvert('id', (v) => v as String),
      contactId: $checkedConvert('contact_id', (v) => v as String),
      reservationId: $checkedConvert('reservation_id', (v) => v as String?),
      hamsterId: $checkedConvert('hamster_id', (v) => v as String?),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$CrmHandoverStatusEnumEnumMap, v),
      ),
      scheduledAt: $checkedConvert(
        'scheduled_at',
        (v) => DateTime.parse(v as String),
      ),
      completedAt: $checkedConvert(
        'completed_at',
        (v) => v == null ? null : DateTime.parse(v as String),
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
    'reservationId': 'reservation_id',
    'hamsterId': 'hamster_id',
    'scheduledAt': 'scheduled_at',
    'completedAt': 'completed_at',
    'contactName': 'contact_name',
    'hamsterName': 'hamster_name',
  },
);

Map<String, dynamic> _$CrmHandoverToJson(CrmHandover instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contact_id': instance.contactId,
      'reservation_id': ?instance.reservationId,
      'hamster_id': ?instance.hamsterId,
      'status': _$CrmHandoverStatusEnumEnumMap[instance.status]!,
      'scheduled_at': instance.scheduledAt.toIso8601String(),
      'completed_at': ?instance.completedAt?.toIso8601String(),
      'notes': ?instance.notes,
      'version': instance.version,
      'contact_name': ?instance.contactName,
      'hamster_name': ?instance.hamsterName,
    };

const _$CrmHandoverStatusEnumEnumMap = {
  CrmHandoverStatusEnum.scheduled: 'scheduled',
  CrmHandoverStatusEnum.completed: 'completed',
  CrmHandoverStatusEnum.cancelled: 'cancelled',
};
