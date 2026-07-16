// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enclosure_stay.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EnclosureStayCWProxy {
  EnclosureStay id(String id);

  EnclosureStay enclosureId(String enclosureId);

  EnclosureStay hamsterId(String hamsterId);

  EnclosureStay purpose(EnclosureStayPurposeEnum purpose);

  EnclosureStay pairingAttemptId(String? pairingAttemptId);

  EnclosureStay startedAt(DateTime startedAt);

  EnclosureStay endedAt(DateTime? endedAt);

  EnclosureStay reason(String? reason);

  EnclosureStay version(int version);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureStay(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureStay(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureStay call({
    String id,
    String enclosureId,
    String hamsterId,
    EnclosureStayPurposeEnum purpose,
    String? pairingAttemptId,
    DateTime startedAt,
    DateTime? endedAt,
    String? reason,
    int version,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEnclosureStay.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEnclosureStay.copyWith.fieldName(...)`
class _$EnclosureStayCWProxyImpl implements _$EnclosureStayCWProxy {
  const _$EnclosureStayCWProxyImpl(this._value);

  final EnclosureStay _value;

  @override
  EnclosureStay id(String id) => this(id: id);

  @override
  EnclosureStay enclosureId(String enclosureId) =>
      this(enclosureId: enclosureId);

  @override
  EnclosureStay hamsterId(String hamsterId) => this(hamsterId: hamsterId);

  @override
  EnclosureStay purpose(EnclosureStayPurposeEnum purpose) =>
      this(purpose: purpose);

  @override
  EnclosureStay pairingAttemptId(String? pairingAttemptId) =>
      this(pairingAttemptId: pairingAttemptId);

  @override
  EnclosureStay startedAt(DateTime startedAt) => this(startedAt: startedAt);

  @override
  EnclosureStay endedAt(DateTime? endedAt) => this(endedAt: endedAt);

  @override
  EnclosureStay reason(String? reason) => this(reason: reason);

  @override
  EnclosureStay version(int version) => this(version: version);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureStay(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureStay(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureStay call({
    Object? id = const $CopyWithPlaceholder(),
    Object? enclosureId = const $CopyWithPlaceholder(),
    Object? hamsterId = const $CopyWithPlaceholder(),
    Object? purpose = const $CopyWithPlaceholder(),
    Object? pairingAttemptId = const $CopyWithPlaceholder(),
    Object? startedAt = const $CopyWithPlaceholder(),
    Object? endedAt = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
  }) {
    return EnclosureStay(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      enclosureId: enclosureId == const $CopyWithPlaceholder()
          ? _value.enclosureId
          // ignore: cast_nullable_to_non_nullable
          : enclosureId as String,
      hamsterId: hamsterId == const $CopyWithPlaceholder()
          ? _value.hamsterId
          // ignore: cast_nullable_to_non_nullable
          : hamsterId as String,
      purpose: purpose == const $CopyWithPlaceholder()
          ? _value.purpose
          // ignore: cast_nullable_to_non_nullable
          : purpose as EnclosureStayPurposeEnum,
      pairingAttemptId: pairingAttemptId == const $CopyWithPlaceholder()
          ? _value.pairingAttemptId
          // ignore: cast_nullable_to_non_nullable
          : pairingAttemptId as String?,
      startedAt: startedAt == const $CopyWithPlaceholder()
          ? _value.startedAt
          // ignore: cast_nullable_to_non_nullable
          : startedAt as DateTime,
      endedAt: endedAt == const $CopyWithPlaceholder()
          ? _value.endedAt
          // ignore: cast_nullable_to_non_nullable
          : endedAt as DateTime?,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String?,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
    );
  }
}

extension $EnclosureStayCopyWith on EnclosureStay {
  /// Returns a callable class that can be used as follows: `instanceOfEnclosureStay.copyWith(...)` or like so:`instanceOfEnclosureStay.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EnclosureStayCWProxy get copyWith => _$EnclosureStayCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnclosureStay _$EnclosureStayFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'EnclosureStay',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'enclosure_id',
            'hamster_id',
            'purpose',
            'started_at',
            'version',
          ],
        );
        final val = EnclosureStay(
          id: $checkedConvert('id', (v) => v as String),
          enclosureId: $checkedConvert('enclosure_id', (v) => v as String),
          hamsterId: $checkedConvert('hamster_id', (v) => v as String),
          purpose: $checkedConvert(
            'purpose',
            (v) => $enumDecode(_$EnclosureStayPurposeEnumEnumMap, v),
          ),
          pairingAttemptId: $checkedConvert(
            'pairing_attempt_id',
            (v) => v as String?,
          ),
          startedAt: $checkedConvert(
            'started_at',
            (v) => DateTime.parse(v as String),
          ),
          endedAt: $checkedConvert(
            'ended_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          reason: $checkedConvert('reason', (v) => v as String?),
          version: $checkedConvert('version', (v) => (v as num).toInt()),
        );
        return val;
      },
      fieldKeyMap: const {
        'enclosureId': 'enclosure_id',
        'hamsterId': 'hamster_id',
        'pairingAttemptId': 'pairing_attempt_id',
        'startedAt': 'started_at',
        'endedAt': 'ended_at',
      },
    );

Map<String, dynamic> _$EnclosureStayToJson(EnclosureStay instance) =>
    <String, dynamic>{
      'id': instance.id,
      'enclosure_id': instance.enclosureId,
      'hamster_id': instance.hamsterId,
      'purpose': _$EnclosureStayPurposeEnumEnumMap[instance.purpose]!,
      'pairing_attempt_id': ?instance.pairingAttemptId,
      'started_at': instance.startedAt.toIso8601String(),
      'ended_at': ?instance.endedAt?.toIso8601String(),
      'reason': ?instance.reason,
      'version': instance.version,
    };

const _$EnclosureStayPurposeEnumEnumMap = {
  EnclosureStayPurposeEnum.single: 'single',
  EnclosureStayPurposeEnum.pairingTemp: 'pairing_temp',
  EnclosureStayPurposeEnum.gestation: 'gestation',
  EnclosureStayPurposeEnum.isolation: 'isolation',
  EnclosureStayPurposeEnum.damWithLitter: 'dam_with_litter',
};
