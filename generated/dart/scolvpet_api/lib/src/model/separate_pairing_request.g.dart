// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'separate_pairing_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SeparatePairingRequestCWProxy {
  SeparatePairingRequest endedAt(DateTime endedAt);

  SeparatePairingRequest separatedAt(DateTime separatedAt);

  SeparatePairingRequest result(PairingResult result);

  SeparatePairingRequest sireDestinationEnclosureId(
    String sireDestinationEnclosureId,
  );

  SeparatePairingRequest damDestinationEnclosureId(
    String damDestinationEnclosureId,
  );

  SeparatePairingRequest safetyStop(bool safetyStop);

  SeparatePairingRequest timezone(String timezone);

  SeparatePairingRequest notes(String? notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SeparatePairingRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SeparatePairingRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SeparatePairingRequest call({
    DateTime endedAt,
    DateTime separatedAt,
    PairingResult result,
    String sireDestinationEnclosureId,
    String damDestinationEnclosureId,
    bool safetyStop,
    String timezone,
    String? notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSeparatePairingRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSeparatePairingRequest.copyWith.fieldName(...)`
class _$SeparatePairingRequestCWProxyImpl
    implements _$SeparatePairingRequestCWProxy {
  const _$SeparatePairingRequestCWProxyImpl(this._value);

  final SeparatePairingRequest _value;

  @override
  SeparatePairingRequest endedAt(DateTime endedAt) => this(endedAt: endedAt);

  @override
  SeparatePairingRequest separatedAt(DateTime separatedAt) =>
      this(separatedAt: separatedAt);

  @override
  SeparatePairingRequest result(PairingResult result) => this(result: result);

  @override
  SeparatePairingRequest sireDestinationEnclosureId(
    String sireDestinationEnclosureId,
  ) => this(sireDestinationEnclosureId: sireDestinationEnclosureId);

  @override
  SeparatePairingRequest damDestinationEnclosureId(
    String damDestinationEnclosureId,
  ) => this(damDestinationEnclosureId: damDestinationEnclosureId);

  @override
  SeparatePairingRequest safetyStop(bool safetyStop) =>
      this(safetyStop: safetyStop);

  @override
  SeparatePairingRequest timezone(String timezone) => this(timezone: timezone);

  @override
  SeparatePairingRequest notes(String? notes) => this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SeparatePairingRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SeparatePairingRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SeparatePairingRequest call({
    Object? endedAt = const $CopyWithPlaceholder(),
    Object? separatedAt = const $CopyWithPlaceholder(),
    Object? result = const $CopyWithPlaceholder(),
    Object? sireDestinationEnclosureId = const $CopyWithPlaceholder(),
    Object? damDestinationEnclosureId = const $CopyWithPlaceholder(),
    Object? safetyStop = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return SeparatePairingRequest(
      endedAt: endedAt == const $CopyWithPlaceholder()
          ? _value.endedAt
          // ignore: cast_nullable_to_non_nullable
          : endedAt as DateTime,
      separatedAt: separatedAt == const $CopyWithPlaceholder()
          ? _value.separatedAt
          // ignore: cast_nullable_to_non_nullable
          : separatedAt as DateTime,
      result: result == const $CopyWithPlaceholder()
          ? _value.result
          // ignore: cast_nullable_to_non_nullable
          : result as PairingResult,
      sireDestinationEnclosureId:
          sireDestinationEnclosureId == const $CopyWithPlaceholder()
          ? _value.sireDestinationEnclosureId
          // ignore: cast_nullable_to_non_nullable
          : sireDestinationEnclosureId as String,
      damDestinationEnclosureId:
          damDestinationEnclosureId == const $CopyWithPlaceholder()
          ? _value.damDestinationEnclosureId
          // ignore: cast_nullable_to_non_nullable
          : damDestinationEnclosureId as String,
      safetyStop: safetyStop == const $CopyWithPlaceholder()
          ? _value.safetyStop
          // ignore: cast_nullable_to_non_nullable
          : safetyStop as bool,
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

extension $SeparatePairingRequestCopyWith on SeparatePairingRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSeparatePairingRequest.copyWith(...)` or like so:`instanceOfSeparatePairingRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SeparatePairingRequestCWProxy get copyWith =>
      _$SeparatePairingRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SeparatePairingRequest _$SeparatePairingRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'SeparatePairingRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'ended_at',
        'separated_at',
        'result',
        'sire_destination_enclosure_id',
        'dam_destination_enclosure_id',
        'safety_stop',
        'timezone',
      ],
    );
    final val = SeparatePairingRequest(
      endedAt: $checkedConvert('ended_at', (v) => DateTime.parse(v as String)),
      separatedAt: $checkedConvert(
        'separated_at',
        (v) => DateTime.parse(v as String),
      ),
      result: $checkedConvert(
        'result',
        (v) => $enumDecode(_$PairingResultEnumMap, v),
      ),
      sireDestinationEnclosureId: $checkedConvert(
        'sire_destination_enclosure_id',
        (v) => v as String,
      ),
      damDestinationEnclosureId: $checkedConvert(
        'dam_destination_enclosure_id',
        (v) => v as String,
      ),
      safetyStop: $checkedConvert('safety_stop', (v) => v as bool),
      timezone: $checkedConvert('timezone', (v) => v as String),
      notes: $checkedConvert('notes', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'endedAt': 'ended_at',
    'separatedAt': 'separated_at',
    'sireDestinationEnclosureId': 'sire_destination_enclosure_id',
    'damDestinationEnclosureId': 'dam_destination_enclosure_id',
    'safetyStop': 'safety_stop',
  },
);

Map<String, dynamic> _$SeparatePairingRequestToJson(
  SeparatePairingRequest instance,
) => <String, dynamic>{
  'ended_at': instance.endedAt.toIso8601String(),
  'separated_at': instance.separatedAt.toIso8601String(),
  'result': _$PairingResultEnumMap[instance.result]!,
  'sire_destination_enclosure_id': instance.sireDestinationEnclosureId,
  'dam_destination_enclosure_id': instance.damDestinationEnclosureId,
  'safety_stop': instance.safetyStop,
  'timezone': instance.timezone,
  'notes': ?instance.notes,
};

const _$PairingResultEnumMap = {
  PairingResult.effective: 'effective',
  PairingResult.uncertain: 'uncertain',
  PairingResult.ineffective: 'ineffective',
  PairingResult.safetyStop: 'safety_stop',
};
