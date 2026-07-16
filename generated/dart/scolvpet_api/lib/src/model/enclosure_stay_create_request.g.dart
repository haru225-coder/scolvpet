// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enclosure_stay_create_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EnclosureStayCreateRequestCWProxy {
  EnclosureStayCreateRequest hamsterId(String hamsterId);

  EnclosureStayCreateRequest purpose(
    EnclosureStayCreateRequestPurposeEnum purpose,
  );

  EnclosureStayCreateRequest pairingAttemptId(String? pairingAttemptId);

  EnclosureStayCreateRequest startedAt(DateTime startedAt);

  EnclosureStayCreateRequest previousStayId(String? previousStayId);

  EnclosureStayCreateRequest reason(String? reason);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureStayCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureStayCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureStayCreateRequest call({
    String hamsterId,
    EnclosureStayCreateRequestPurposeEnum purpose,
    String? pairingAttemptId,
    DateTime startedAt,
    String? previousStayId,
    String? reason,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEnclosureStayCreateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEnclosureStayCreateRequest.copyWith.fieldName(...)`
class _$EnclosureStayCreateRequestCWProxyImpl
    implements _$EnclosureStayCreateRequestCWProxy {
  const _$EnclosureStayCreateRequestCWProxyImpl(this._value);

  final EnclosureStayCreateRequest _value;

  @override
  EnclosureStayCreateRequest hamsterId(String hamsterId) =>
      this(hamsterId: hamsterId);

  @override
  EnclosureStayCreateRequest purpose(
    EnclosureStayCreateRequestPurposeEnum purpose,
  ) => this(purpose: purpose);

  @override
  EnclosureStayCreateRequest pairingAttemptId(String? pairingAttemptId) =>
      this(pairingAttemptId: pairingAttemptId);

  @override
  EnclosureStayCreateRequest startedAt(DateTime startedAt) =>
      this(startedAt: startedAt);

  @override
  EnclosureStayCreateRequest previousStayId(String? previousStayId) =>
      this(previousStayId: previousStayId);

  @override
  EnclosureStayCreateRequest reason(String? reason) => this(reason: reason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureStayCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureStayCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureStayCreateRequest call({
    Object? hamsterId = const $CopyWithPlaceholder(),
    Object? purpose = const $CopyWithPlaceholder(),
    Object? pairingAttemptId = const $CopyWithPlaceholder(),
    Object? startedAt = const $CopyWithPlaceholder(),
    Object? previousStayId = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
  }) {
    return EnclosureStayCreateRequest(
      hamsterId: hamsterId == const $CopyWithPlaceholder()
          ? _value.hamsterId
          // ignore: cast_nullable_to_non_nullable
          : hamsterId as String,
      purpose: purpose == const $CopyWithPlaceholder()
          ? _value.purpose
          // ignore: cast_nullable_to_non_nullable
          : purpose as EnclosureStayCreateRequestPurposeEnum,
      pairingAttemptId: pairingAttemptId == const $CopyWithPlaceholder()
          ? _value.pairingAttemptId
          // ignore: cast_nullable_to_non_nullable
          : pairingAttemptId as String?,
      startedAt: startedAt == const $CopyWithPlaceholder()
          ? _value.startedAt
          // ignore: cast_nullable_to_non_nullable
          : startedAt as DateTime,
      previousStayId: previousStayId == const $CopyWithPlaceholder()
          ? _value.previousStayId
          // ignore: cast_nullable_to_non_nullable
          : previousStayId as String?,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String?,
    );
  }
}

extension $EnclosureStayCreateRequestCopyWith on EnclosureStayCreateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfEnclosureStayCreateRequest.copyWith(...)` or like so:`instanceOfEnclosureStayCreateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EnclosureStayCreateRequestCWProxy get copyWith =>
      _$EnclosureStayCreateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnclosureStayCreateRequest _$EnclosureStayCreateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'EnclosureStayCreateRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['hamster_id', 'purpose', 'started_at'],
    );
    final val = EnclosureStayCreateRequest(
      hamsterId: $checkedConvert('hamster_id', (v) => v as String),
      purpose: $checkedConvert(
        'purpose',
        (v) => $enumDecode(_$EnclosureStayCreateRequestPurposeEnumEnumMap, v),
      ),
      pairingAttemptId: $checkedConvert(
        'pairing_attempt_id',
        (v) => v as String?,
      ),
      startedAt: $checkedConvert(
        'started_at',
        (v) => DateTime.parse(v as String),
      ),
      previousStayId: $checkedConvert('previous_stay_id', (v) => v as String?),
      reason: $checkedConvert('reason', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'hamsterId': 'hamster_id',
    'pairingAttemptId': 'pairing_attempt_id',
    'startedAt': 'started_at',
    'previousStayId': 'previous_stay_id',
  },
);

Map<String, dynamic> _$EnclosureStayCreateRequestToJson(
  EnclosureStayCreateRequest instance,
) => <String, dynamic>{
  'hamster_id': instance.hamsterId,
  'purpose': _$EnclosureStayCreateRequestPurposeEnumEnumMap[instance.purpose]!,
  'pairing_attempt_id': ?instance.pairingAttemptId,
  'started_at': instance.startedAt.toIso8601String(),
  'previous_stay_id': ?instance.previousStayId,
  'reason': ?instance.reason,
};

const _$EnclosureStayCreateRequestPurposeEnumEnumMap = {
  EnclosureStayCreateRequestPurposeEnum.single: 'single',
  EnclosureStayCreateRequestPurposeEnum.pairingTemp: 'pairing_temp',
  EnclosureStayCreateRequestPurposeEnum.gestation: 'gestation',
  EnclosureStayCreateRequestPurposeEnum.isolation: 'isolation',
  EnclosureStayCreateRequestPurposeEnum.damWithLitter: 'dam_with_litter',
};
