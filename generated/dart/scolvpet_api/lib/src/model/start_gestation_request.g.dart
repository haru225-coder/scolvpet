// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_gestation_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StartGestationRequestCWProxy {
  StartGestationRequest pairingAttemptId(String pairingAttemptId);

  StartGestationRequest result(StartGestationRequestResultEnum result);

  StartGestationRequest baselineAt(DateTime baselineAt);

  StartGestationRequest timezone(String timezone);

  StartGestationRequest notes(String? notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StartGestationRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StartGestationRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  StartGestationRequest call({
    String pairingAttemptId,
    StartGestationRequestResultEnum result,
    DateTime baselineAt,
    String timezone,
    String? notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStartGestationRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStartGestationRequest.copyWith.fieldName(...)`
class _$StartGestationRequestCWProxyImpl
    implements _$StartGestationRequestCWProxy {
  const _$StartGestationRequestCWProxyImpl(this._value);

  final StartGestationRequest _value;

  @override
  StartGestationRequest pairingAttemptId(String pairingAttemptId) =>
      this(pairingAttemptId: pairingAttemptId);

  @override
  StartGestationRequest result(StartGestationRequestResultEnum result) =>
      this(result: result);

  @override
  StartGestationRequest baselineAt(DateTime baselineAt) =>
      this(baselineAt: baselineAt);

  @override
  StartGestationRequest timezone(String timezone) => this(timezone: timezone);

  @override
  StartGestationRequest notes(String? notes) => this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StartGestationRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StartGestationRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  StartGestationRequest call({
    Object? pairingAttemptId = const $CopyWithPlaceholder(),
    Object? result = const $CopyWithPlaceholder(),
    Object? baselineAt = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return StartGestationRequest(
      pairingAttemptId: pairingAttemptId == const $CopyWithPlaceholder()
          ? _value.pairingAttemptId
          // ignore: cast_nullable_to_non_nullable
          : pairingAttemptId as String,
      result: result == const $CopyWithPlaceholder()
          ? _value.result
          // ignore: cast_nullable_to_non_nullable
          : result as StartGestationRequestResultEnum,
      baselineAt: baselineAt == const $CopyWithPlaceholder()
          ? _value.baselineAt
          // ignore: cast_nullable_to_non_nullable
          : baselineAt as DateTime,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
    );
  }
}

extension $StartGestationRequestCopyWith on StartGestationRequest {
  /// Returns a callable class that can be used as follows: `instanceOfStartGestationRequest.copyWith(...)` or like so:`instanceOfStartGestationRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StartGestationRequestCWProxy get copyWith =>
      _$StartGestationRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartGestationRequest _$StartGestationRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'StartGestationRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'pairing_attempt_id',
        'result',
        'baseline_at',
        'timezone',
      ],
    );
    final val = StartGestationRequest(
      pairingAttemptId: $checkedConvert(
        'pairing_attempt_id',
        (v) => v as String,
      ),
      result: $checkedConvert(
        'result',
        (v) => $enumDecode(_$StartGestationRequestResultEnumEnumMap, v),
      ),
      baselineAt: $checkedConvert(
        'baseline_at',
        (v) => DateTime.parse(v as String),
      ),
      timezone: $checkedConvert('timezone', (v) => v as String),
      notes: $checkedConvert('notes', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'pairingAttemptId': 'pairing_attempt_id',
    'baselineAt': 'baseline_at',
  },
);

Map<String, dynamic> _$StartGestationRequestToJson(
  StartGestationRequest instance,
) => <String, dynamic>{
  'pairing_attempt_id': instance.pairingAttemptId,
  'result': _$StartGestationRequestResultEnumEnumMap[instance.result]!,
  'baseline_at': instance.baselineAt.toIso8601String(),
  'timezone': instance.timezone,
  'notes': ?instance.notes,
};

const _$StartGestationRequestResultEnumEnumMap = {
  StartGestationRequestResultEnum.effective: 'effective',
  StartGestationRequestResultEnum.uncertain: 'uncertain',
};
