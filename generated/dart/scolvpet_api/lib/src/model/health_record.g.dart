// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_record.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HealthRecordCWProxy {
  HealthRecord id(String id);

  HealthRecord hamsterId(String? hamsterId);

  HealthRecord litterId(String? litterId);

  HealthRecord type(HealthRecordType type);

  HealthRecord observedAt(DateTime observedAt);

  HealthRecord structuredChecks(Map<String, Object>? structuredChecks);

  HealthRecord severity(Severity? severity);

  HealthRecord medication(Map<String, Object>? medication);

  HealthRecord mediaIds(List<String>? mediaIds);

  HealthRecord followUpAt(DateTime? followUpAt);

  HealthRecord notes(String? notes);

  HealthRecord version(int version);

  HealthRecord createdAt(DateTime createdAt);

  HealthRecord updatedAt(DateTime updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HealthRecord(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HealthRecord(...).copyWith(id: 12, name: "My name")
  /// ````
  HealthRecord call({
    String id,
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
    int version,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHealthRecord.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHealthRecord.copyWith.fieldName(...)`
class _$HealthRecordCWProxyImpl implements _$HealthRecordCWProxy {
  const _$HealthRecordCWProxyImpl(this._value);

  final HealthRecord _value;

  @override
  HealthRecord id(String id) => this(id: id);

  @override
  HealthRecord hamsterId(String? hamsterId) => this(hamsterId: hamsterId);

  @override
  HealthRecord litterId(String? litterId) => this(litterId: litterId);

  @override
  HealthRecord type(HealthRecordType type) => this(type: type);

  @override
  HealthRecord observedAt(DateTime observedAt) => this(observedAt: observedAt);

  @override
  HealthRecord structuredChecks(Map<String, Object>? structuredChecks) =>
      this(structuredChecks: structuredChecks);

  @override
  HealthRecord severity(Severity? severity) => this(severity: severity);

  @override
  HealthRecord medication(Map<String, Object>? medication) =>
      this(medication: medication);

  @override
  HealthRecord mediaIds(List<String>? mediaIds) => this(mediaIds: mediaIds);

  @override
  HealthRecord followUpAt(DateTime? followUpAt) => this(followUpAt: followUpAt);

  @override
  HealthRecord notes(String? notes) => this(notes: notes);

  @override
  HealthRecord version(int version) => this(version: version);

  @override
  HealthRecord createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  HealthRecord updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HealthRecord(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HealthRecord(...).copyWith(id: 12, name: "My name")
  /// ````
  HealthRecord call({
    Object? id = const $CopyWithPlaceholder(),
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
    Object? version = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return HealthRecord(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
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
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
    );
  }
}

extension $HealthRecordCopyWith on HealthRecord {
  /// Returns a callable class that can be used as follows: `instanceOfHealthRecord.copyWith(...)` or like so:`instanceOfHealthRecord.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HealthRecordCWProxy get copyWith => _$HealthRecordCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthRecord _$HealthRecordFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'HealthRecord',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'type',
            'observed_at',
            'version',
            'created_at',
            'updated_at',
          ],
        );
        final val = HealthRecord(
          id: $checkedConvert('id', (v) => v as String),
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
          version: $checkedConvert('version', (v) => (v as num).toInt()),
          createdAt: $checkedConvert(
            'created_at',
            (v) => DateTime.parse(v as String),
          ),
          updatedAt: $checkedConvert(
            'updated_at',
            (v) => DateTime.parse(v as String),
          ),
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
        'createdAt': 'created_at',
        'updatedAt': 'updated_at',
      },
    );

Map<String, dynamic> _$HealthRecordToJson(HealthRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
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
      'version': instance.version,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
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
