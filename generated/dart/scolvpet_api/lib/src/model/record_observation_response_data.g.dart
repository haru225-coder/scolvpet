// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_observation_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RecordObservationResponseDataCWProxy {
  RecordObservationResponseData observation(MatingObservation observation);

  RecordObservationResponseData pairingAttemptVersion(
    int pairingAttemptVersion,
  );

  RecordObservationResponseData baselineCandidateAt(
    DateTime? baselineCandidateAt,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RecordObservationResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RecordObservationResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  RecordObservationResponseData call({
    MatingObservation observation,
    int pairingAttemptVersion,
    DateTime? baselineCandidateAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRecordObservationResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRecordObservationResponseData.copyWith.fieldName(...)`
class _$RecordObservationResponseDataCWProxyImpl
    implements _$RecordObservationResponseDataCWProxy {
  const _$RecordObservationResponseDataCWProxyImpl(this._value);

  final RecordObservationResponseData _value;

  @override
  RecordObservationResponseData observation(MatingObservation observation) =>
      this(observation: observation);

  @override
  RecordObservationResponseData pairingAttemptVersion(
    int pairingAttemptVersion,
  ) => this(pairingAttemptVersion: pairingAttemptVersion);

  @override
  RecordObservationResponseData baselineCandidateAt(
    DateTime? baselineCandidateAt,
  ) => this(baselineCandidateAt: baselineCandidateAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RecordObservationResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RecordObservationResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  RecordObservationResponseData call({
    Object? observation = const $CopyWithPlaceholder(),
    Object? pairingAttemptVersion = const $CopyWithPlaceholder(),
    Object? baselineCandidateAt = const $CopyWithPlaceholder(),
  }) {
    return RecordObservationResponseData(
      observation: observation == const $CopyWithPlaceholder()
          ? _value.observation
          // ignore: cast_nullable_to_non_nullable
          : observation as MatingObservation,
      pairingAttemptVersion:
          pairingAttemptVersion == const $CopyWithPlaceholder()
          ? _value.pairingAttemptVersion
          // ignore: cast_nullable_to_non_nullable
          : pairingAttemptVersion as int,
      baselineCandidateAt: baselineCandidateAt == const $CopyWithPlaceholder()
          ? _value.baselineCandidateAt
          // ignore: cast_nullable_to_non_nullable
          : baselineCandidateAt as DateTime?,
    );
  }
}

extension $RecordObservationResponseDataCopyWith
    on RecordObservationResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfRecordObservationResponseData.copyWith(...)` or like so:`instanceOfRecordObservationResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RecordObservationResponseDataCWProxy get copyWith =>
      _$RecordObservationResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecordObservationResponseData _$RecordObservationResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'RecordObservationResponseData',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['observation', 'pairing_attempt_version'],
    );
    final val = RecordObservationResponseData(
      observation: $checkedConvert(
        'observation',
        (v) => MatingObservation.fromJson(v as Map<String, dynamic>),
      ),
      pairingAttemptVersion: $checkedConvert(
        'pairing_attempt_version',
        (v) => (v as num).toInt(),
      ),
      baselineCandidateAt: $checkedConvert(
        'baseline_candidate_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'pairingAttemptVersion': 'pairing_attempt_version',
    'baselineCandidateAt': 'baseline_candidate_at',
  },
);

Map<String, dynamic> _$RecordObservationResponseDataToJson(
  RecordObservationResponseData instance,
) => <String, dynamic>{
  'observation': instance.observation.toJson(),
  'pairing_attempt_version': instance.pairingAttemptVersion,
  'baseline_candidate_at': ?instance.baselineCandidateAt?.toIso8601String(),
};
