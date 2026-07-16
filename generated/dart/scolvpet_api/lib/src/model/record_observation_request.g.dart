// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_observation_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RecordObservationRequestCWProxy {
  RecordObservationRequest observedAt(DateTime observedAt);

  RecordObservationRequest type(ObservationType type);

  RecordObservationRequest durationSeconds(int? durationSeconds);

  RecordObservationRequest severity(Severity? severity);

  RecordObservationRequest confidence(num? confidence);

  RecordObservationRequest mediaIds(Set<String>? mediaIds);

  RecordObservationRequest notes(String? notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RecordObservationRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RecordObservationRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RecordObservationRequest call({
    DateTime observedAt,
    ObservationType type,
    int? durationSeconds,
    Severity? severity,
    num? confidence,
    Set<String>? mediaIds,
    String? notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRecordObservationRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRecordObservationRequest.copyWith.fieldName(...)`
class _$RecordObservationRequestCWProxyImpl
    implements _$RecordObservationRequestCWProxy {
  const _$RecordObservationRequestCWProxyImpl(this._value);

  final RecordObservationRequest _value;

  @override
  RecordObservationRequest observedAt(DateTime observedAt) =>
      this(observedAt: observedAt);

  @override
  RecordObservationRequest type(ObservationType type) => this(type: type);

  @override
  RecordObservationRequest durationSeconds(int? durationSeconds) =>
      this(durationSeconds: durationSeconds);

  @override
  RecordObservationRequest severity(Severity? severity) =>
      this(severity: severity);

  @override
  RecordObservationRequest confidence(num? confidence) =>
      this(confidence: confidence);

  @override
  RecordObservationRequest mediaIds(Set<String>? mediaIds) =>
      this(mediaIds: mediaIds);

  @override
  RecordObservationRequest notes(String? notes) => this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RecordObservationRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RecordObservationRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RecordObservationRequest call({
    Object? observedAt = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? durationSeconds = const $CopyWithPlaceholder(),
    Object? severity = const $CopyWithPlaceholder(),
    Object? confidence = const $CopyWithPlaceholder(),
    Object? mediaIds = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return RecordObservationRequest(
      observedAt: observedAt == const $CopyWithPlaceholder()
          ? _value.observedAt
          // ignore: cast_nullable_to_non_nullable
          : observedAt as DateTime,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as ObservationType,
      durationSeconds: durationSeconds == const $CopyWithPlaceholder()
          ? _value.durationSeconds
          // ignore: cast_nullable_to_non_nullable
          : durationSeconds as int?,
      severity: severity == const $CopyWithPlaceholder()
          ? _value.severity
          // ignore: cast_nullable_to_non_nullable
          : severity as Severity?,
      confidence: confidence == const $CopyWithPlaceholder()
          ? _value.confidence
          // ignore: cast_nullable_to_non_nullable
          : confidence as num?,
      mediaIds: mediaIds == const $CopyWithPlaceholder()
          ? _value.mediaIds
          // ignore: cast_nullable_to_non_nullable
          : mediaIds as Set<String>?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
    );
  }
}

extension $RecordObservationRequestCopyWith on RecordObservationRequest {
  /// Returns a callable class that can be used as follows: `instanceOfRecordObservationRequest.copyWith(...)` or like so:`instanceOfRecordObservationRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RecordObservationRequestCWProxy get copyWith =>
      _$RecordObservationRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecordObservationRequest _$RecordObservationRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'RecordObservationRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['observed_at', 'type']);
    final val = RecordObservationRequest(
      observedAt: $checkedConvert(
        'observed_at',
        (v) => DateTime.parse(v as String),
      ),
      type: $checkedConvert(
        'type',
        (v) => $enumDecode(_$ObservationTypeEnumMap, v),
      ),
      durationSeconds: $checkedConvert(
        'duration_seconds',
        (v) => (v as num?)?.toInt(),
      ),
      severity: $checkedConvert(
        'severity',
        (v) => $enumDecodeNullable(_$SeverityEnumMap, v),
      ),
      confidence: $checkedConvert('confidence', (v) => v as num?),
      mediaIds: $checkedConvert(
        'media_ids',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet(),
      ),
      notes: $checkedConvert('notes', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'observedAt': 'observed_at',
    'durationSeconds': 'duration_seconds',
    'mediaIds': 'media_ids',
  },
);

Map<String, dynamic> _$RecordObservationRequestToJson(
  RecordObservationRequest instance,
) => <String, dynamic>{
  'observed_at': instance.observedAt.toIso8601String(),
  'type': _$ObservationTypeEnumMap[instance.type]!,
  'duration_seconds': ?instance.durationSeconds,
  'severity': ?_$SeverityEnumMap[instance.severity],
  'confidence': ?instance.confidence,
  'media_ids': ?instance.mediaIds?.toList(),
  'notes': ?instance.notes,
};

const _$ObservationTypeEnumMap = {
  ObservationType.contact: 'contact',
  ObservationType.chase: 'chase',
  ObservationType.conflict: 'conflict',
  ObservationType.mating: 'mating',
  ObservationType.separated: 'separated',
  ObservationType.other: 'other',
};

const _$SeverityEnumMap = {
  Severity.info: 'info',
  Severity.low: 'low',
  Severity.medium: 'medium',
  Severity.high: 'high',
  Severity.critical: 'critical',
};
