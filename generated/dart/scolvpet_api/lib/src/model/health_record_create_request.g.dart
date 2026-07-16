// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_record_create_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HealthRecordCreateRequestCWProxy {
  HealthRecordCreateRequest hamsterId(String? hamsterId);

  HealthRecordCreateRequest litterId(String? litterId);

  HealthRecordCreateRequest type(HealthRecordType type);

  HealthRecordCreateRequest observedAt(DateTime observedAt);

  HealthRecordCreateRequest structuredChecks(
    Map<String, Object>? structuredChecks,
  );

  HealthRecordCreateRequest severity(Severity? severity);

  HealthRecordCreateRequest medication(Map<String, Object>? medication);

  HealthRecordCreateRequest mediaIds(List<String>? mediaIds);

  HealthRecordCreateRequest followUpAt(DateTime? followUpAt);

  HealthRecordCreateRequest notes(String? notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HealthRecordCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HealthRecordCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  HealthRecordCreateRequest call({
    String? hamsterId,
    String? litterId,
    HealthRecordType type,
    DateTime observedAt,
    Map<String, Object>? structuredChecks,
    Severity? severity,
    Map<String, Object>? medication,
    List<String>? mediaIds,
    DateTime? followUpAt,
    String? notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHealthRecordCreateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHealthRecordCreateRequest.copyWith.fieldName(...)`
class _$HealthRecordCreateRequestCWProxyImpl
    implements _$HealthRecordCreateRequestCWProxy {
  const _$HealthRecordCreateRequestCWProxyImpl(this._value);

  final HealthRecordCreateRequest _value;

  @override
  HealthRecordCreateRequest hamsterId(String? hamsterId) =>
      this(hamsterId: hamsterId);

  @override
  HealthRecordCreateRequest litterId(String? litterId) =>
      this(litterId: litterId);

  @override
  HealthRecordCreateRequest type(HealthRecordType type) => this(type: type);

  @override
  HealthRecordCreateRequest observedAt(DateTime observedAt) =>
      this(observedAt: observedAt);

  @override
  HealthRecordCreateRequest structuredChecks(
    Map<String, Object>? structuredChecks,
  ) => this(structuredChecks: structuredChecks);

  @override
  HealthRecordCreateRequest severity(Severity? severity) =>
      this(severity: severity);

  @override
  HealthRecordCreateRequest medication(Map<String, Object>? medication) =>
      this(medication: medication);

  @override
  HealthRecordCreateRequest mediaIds(List<String>? mediaIds) =>
      this(mediaIds: mediaIds);

  @override
  HealthRecordCreateRequest followUpAt(DateTime? followUpAt) =>
      this(followUpAt: followUpAt);

  @override
  HealthRecordCreateRequest notes(String? notes) => this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HealthRecordCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HealthRecordCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  HealthRecordCreateRequest call({
    Object? hamsterId = const $CopyWithPlaceholder(),
    Object? litterId = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? observedAt = const $CopyWithPlaceholder(),
    Object? structuredChecks = const $CopyWithPlaceholder(),
    Object? severity = const $CopyWithPlaceholder(),
    Object? medication = const $CopyWithPlaceholder(),
    Object? mediaIds = const $CopyWithPlaceholder(),
    Object? followUpAt = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return HealthRecordCreateRequest(
      hamsterId: hamsterId == const $CopyWithPlaceholder()
          ? _value.hamsterId
          // ignore: cast_nullable_to_non_nullable
          : hamsterId as String?,
      litterId: litterId == const $CopyWithPlaceholder()
          ? _value.litterId
          // ignore: cast_nullable_to_non_nullable
          : litterId as String?,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as HealthRecordType,
      observedAt: observedAt == const $CopyWithPlaceholder()
          ? _value.observedAt
          // ignore: cast_nullable_to_non_nullable
          : observedAt as DateTime,
      structuredChecks: structuredChecks == const $CopyWithPlaceholder()
          ? _value.structuredChecks
          // ignore: cast_nullable_to_non_nullable
          : structuredChecks as Map<String, Object>?,
      severity: severity == const $CopyWithPlaceholder()
          ? _value.severity
          // ignore: cast_nullable_to_non_nullable
          : severity as Severity?,
      medication: medication == const $CopyWithPlaceholder()
          ? _value.medication
          // ignore: cast_nullable_to_non_nullable
          : medication as Map<String, Object>?,
      mediaIds: mediaIds == const $CopyWithPlaceholder()
          ? _value.mediaIds
          // ignore: cast_nullable_to_non_nullable
          : mediaIds as List<String>?,
      followUpAt: followUpAt == const $CopyWithPlaceholder()
          ? _value.followUpAt
          // ignore: cast_nullable_to_non_nullable
          : followUpAt as DateTime?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
    );
  }
}

extension $HealthRecordCreateRequestCopyWith on HealthRecordCreateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfHealthRecordCreateRequest.copyWith(...)` or like so:`instanceOfHealthRecordCreateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HealthRecordCreateRequestCWProxy get copyWith =>
      _$HealthRecordCreateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthRecordCreateRequest _$HealthRecordCreateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'HealthRecordCreateRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['type', 'observed_at']);
    final val = HealthRecordCreateRequest(
      hamsterId: $checkedConvert('hamster_id', (v) => v as String?),
      litterId: $checkedConvert('litter_id', (v) => v as String?),
      type: $checkedConvert(
        'type',
        (v) => $enumDecode(_$HealthRecordTypeEnumMap, v),
      ),
      observedAt: $checkedConvert(
        'observed_at',
        (v) => DateTime.parse(v as String),
      ),
      structuredChecks: $checkedConvert(
        'structured_checks',
        (v) => (v as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, e as Object),
        ),
      ),
      severity: $checkedConvert(
        'severity',
        (v) => $enumDecodeNullable(_$SeverityEnumMap, v),
      ),
      medication: $checkedConvert(
        'medication',
        (v) => (v as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, e as Object),
        ),
      ),
      mediaIds: $checkedConvert(
        'media_ids',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      followUpAt: $checkedConvert(
        'follow_up_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      notes: $checkedConvert('notes', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'hamsterId': 'hamster_id',
    'litterId': 'litter_id',
    'observedAt': 'observed_at',
    'structuredChecks': 'structured_checks',
    'mediaIds': 'media_ids',
    'followUpAt': 'follow_up_at',
  },
);

Map<String, dynamic> _$HealthRecordCreateRequestToJson(
  HealthRecordCreateRequest instance,
) => <String, dynamic>{
  'hamster_id': ?instance.hamsterId,
  'litter_id': ?instance.litterId,
  'type': _$HealthRecordTypeEnumMap[instance.type]!,
  'observed_at': instance.observedAt.toIso8601String(),
  'structured_checks': ?instance.structuredChecks,
  'severity': ?_$SeverityEnumMap[instance.severity],
  'medication': ?instance.medication,
  'media_ids': ?instance.mediaIds,
  'follow_up_at': ?instance.followUpAt?.toIso8601String(),
  'notes': ?instance.notes,
};

const _$HealthRecordTypeEnumMap = {
  HealthRecordType.dailyCheck: 'daily_check',
  HealthRecordType.anomaly: 'anomaly',
  HealthRecordType.medication: 'medication',
  HealthRecordType.followUp: 'follow_up',
  HealthRecordType.isolation: 'isolation',
  HealthRecordType.death: 'death',
};

const _$SeverityEnumMap = {
  Severity.info: 'info',
  Severity.low: 'low',
  Severity.medium: 'medium',
  Severity.high: 'high',
  Severity.critical: 'critical',
};
