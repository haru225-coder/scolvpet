// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mating_observation.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MatingObservationCWProxy {
  MatingObservation id(String id);

  MatingObservation pairingAttemptId(String pairingAttemptId);

  MatingObservation observedAt(DateTime observedAt);

  MatingObservation type(ObservationType type);

  MatingObservation durationSeconds(int? durationSeconds);

  MatingObservation severity(Severity? severity);

  MatingObservation confidence(num? confidence);

  MatingObservation mediaIds(List<String>? mediaIds);

  MatingObservation notes(String? notes);

  MatingObservation createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MatingObservation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MatingObservation(...).copyWith(id: 12, name: "My name")
  /// ````
  MatingObservation call({
    String id,
    String pairingAttemptId,
    DateTime observedAt,
    ObservationType type,
    int? durationSeconds,
    Severity? severity,
    num? confidence,
    List<String>? mediaIds,
    String? notes,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMatingObservation.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMatingObservation.copyWith.fieldName(...)`
class _$MatingObservationCWProxyImpl implements _$MatingObservationCWProxy {
  const _$MatingObservationCWProxyImpl(this._value);

  final MatingObservation _value;

  @override
  MatingObservation id(String id) => this(id: id);

  @override
  MatingObservation pairingAttemptId(String pairingAttemptId) =>
      this(pairingAttemptId: pairingAttemptId);

  @override
  MatingObservation observedAt(DateTime observedAt) =>
      this(observedAt: observedAt);

  @override
  MatingObservation type(ObservationType type) => this(type: type);

  @override
  MatingObservation durationSeconds(int? durationSeconds) =>
      this(durationSeconds: durationSeconds);

  @override
  MatingObservation severity(Severity? severity) => this(severity: severity);

  @override
  MatingObservation confidence(num? confidence) => this(confidence: confidence);

  @override
  MatingObservation mediaIds(List<String>? mediaIds) =>
      this(mediaIds: mediaIds);

  @override
  MatingObservation notes(String? notes) => this(notes: notes);

  @override
  MatingObservation createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MatingObservation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MatingObservation(...).copyWith(id: 12, name: "My name")
  /// ````
  MatingObservation call({
    Object? id = const $CopyWithPlaceholder(),
    Object? pairingAttemptId = const $CopyWithPlaceholder(),
    Object? observedAt = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? durationSeconds = const $CopyWithPlaceholder(),
    Object? severity = const $CopyWithPlaceholder(),
    Object? confidence = const $CopyWithPlaceholder(),
    Object? mediaIds = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return MatingObservation(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      pairingAttemptId: pairingAttemptId == const $CopyWithPlaceholder()
          ? _value.pairingAttemptId
          // ignore: cast_nullable_to_non_nullable
          : pairingAttemptId as String,
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
          : mediaIds as List<String>?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $MatingObservationCopyWith on MatingObservation {
  /// Returns a callable class that can be used as follows: `instanceOfMatingObservation.copyWith(...)` or like so:`instanceOfMatingObservation.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MatingObservationCWProxy get copyWith =>
      _$MatingObservationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatingObservation _$MatingObservationFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'MatingObservation',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'pairing_attempt_id',
            'observed_at',
            'type',
            'created_at',
          ],
        );
        final val = MatingObservation(
          id: $checkedConvert('id', (v) => v as String),
          pairingAttemptId: $checkedConvert(
            'pairing_attempt_id',
            (v) => v as String,
          ),
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
            (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
          ),
          notes: $checkedConvert('notes', (v) => v as String?),
          createdAt: $checkedConvert(
            'created_at',
            (v) => DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'pairingAttemptId': 'pairing_attempt_id',
        'observedAt': 'observed_at',
        'durationSeconds': 'duration_seconds',
        'mediaIds': 'media_ids',
        'createdAt': 'created_at',
      },
    );

Map<String, dynamic> _$MatingObservationToJson(MatingObservation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pairing_attempt_id': instance.pairingAttemptId,
      'observed_at': instance.observedAt.toIso8601String(),
      'type': _$ObservationTypeEnumMap[instance.type]!,
      'duration_seconds': ?instance.durationSeconds,
      'severity': ?_$SeverityEnumMap[instance.severity],
      'confidence': ?instance.confidence,
      'media_ids': ?instance.mediaIds,
      'notes': ?instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
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
