// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_record_update_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HealthRecordUpdateRequestCWProxy {
  HealthRecordUpdateRequest structuredChecks(
    Map<String, Object>? structuredChecks,
  );

  HealthRecordUpdateRequest severity(Severity? severity);

  HealthRecordUpdateRequest medication(Map<String, Object>? medication);

  HealthRecordUpdateRequest mediaIds(List<String>? mediaIds);

  HealthRecordUpdateRequest followUpAt(DateTime? followUpAt);

  HealthRecordUpdateRequest notes(String? notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HealthRecordUpdateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HealthRecordUpdateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  HealthRecordUpdateRequest call({
    Map<String, Object>? structuredChecks,
    Severity? severity,
    Map<String, Object>? medication,
    List<String>? mediaIds,
    DateTime? followUpAt,
    String? notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHealthRecordUpdateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHealthRecordUpdateRequest.copyWith.fieldName(...)`
class _$HealthRecordUpdateRequestCWProxyImpl
    implements _$HealthRecordUpdateRequestCWProxy {
  const _$HealthRecordUpdateRequestCWProxyImpl(this._value);

  final HealthRecordUpdateRequest _value;

  @override
  HealthRecordUpdateRequest structuredChecks(
    Map<String, Object>? structuredChecks,
  ) => this(structuredChecks: structuredChecks);

  @override
  HealthRecordUpdateRequest severity(Severity? severity) =>
      this(severity: severity);

  @override
  HealthRecordUpdateRequest medication(Map<String, Object>? medication) =>
      this(medication: medication);

  @override
  HealthRecordUpdateRequest mediaIds(List<String>? mediaIds) =>
      this(mediaIds: mediaIds);

  @override
  HealthRecordUpdateRequest followUpAt(DateTime? followUpAt) =>
      this(followUpAt: followUpAt);

  @override
  HealthRecordUpdateRequest notes(String? notes) => this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HealthRecordUpdateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HealthRecordUpdateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  HealthRecordUpdateRequest call({
    Object? structuredChecks = const $CopyWithPlaceholder(),
    Object? severity = const $CopyWithPlaceholder(),
    Object? medication = const $CopyWithPlaceholder(),
    Object? mediaIds = const $CopyWithPlaceholder(),
    Object? followUpAt = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return HealthRecordUpdateRequest(
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

extension $HealthRecordUpdateRequestCopyWith on HealthRecordUpdateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfHealthRecordUpdateRequest.copyWith(...)` or like so:`instanceOfHealthRecordUpdateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HealthRecordUpdateRequestCWProxy get copyWith =>
      _$HealthRecordUpdateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthRecordUpdateRequest _$HealthRecordUpdateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'HealthRecordUpdateRequest',
  json,
  ($checkedConvert) {
    final val = HealthRecordUpdateRequest(
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
    'structuredChecks': 'structured_checks',
    'mediaIds': 'media_ids',
    'followUpAt': 'follow_up_at',
  },
);

Map<String, dynamic> _$HealthRecordUpdateRequestToJson(
  HealthRecordUpdateRequest instance,
) => <String, dynamic>{
  'structured_checks': ?instance.structuredChecks,
  'severity': ?_$SeverityEnumMap[instance.severity],
  'medication': ?instance.medication,
  'media_ids': ?instance.mediaIds,
  'follow_up_at': ?instance.followUpAt?.toIso8601String(),
  'notes': ?instance.notes,
};

const _$SeverityEnumMap = {
  Severity.info: 'info',
  Severity.low: 'low',
  Severity.medium: 'medium',
  Severity.high: 'high',
  Severity.critical: 'critical',
};
