// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_pairing_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StartPairingRequestCWProxy {
  StartPairingRequest enclosureId(String enclosureId);

  StartPairingRequest startedAt(DateTime startedAt);

  StartPairingRequest timezone(String timezone);

  StartPairingRequest notes(String? notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StartPairingRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StartPairingRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  StartPairingRequest call({
    String enclosureId,
    DateTime startedAt,
    String timezone,
    String? notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStartPairingRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStartPairingRequest.copyWith.fieldName(...)`
class _$StartPairingRequestCWProxyImpl implements _$StartPairingRequestCWProxy {
  const _$StartPairingRequestCWProxyImpl(this._value);

  final StartPairingRequest _value;

  @override
  StartPairingRequest enclosureId(String enclosureId) =>
      this(enclosureId: enclosureId);

  @override
  StartPairingRequest startedAt(DateTime startedAt) =>
      this(startedAt: startedAt);

  @override
  StartPairingRequest timezone(String timezone) => this(timezone: timezone);

  @override
  StartPairingRequest notes(String? notes) => this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StartPairingRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StartPairingRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  StartPairingRequest call({
    Object? enclosureId = const $CopyWithPlaceholder(),
    Object? startedAt = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return StartPairingRequest(
      enclosureId: enclosureId == const $CopyWithPlaceholder()
          ? _value.enclosureId
          // ignore: cast_nullable_to_non_nullable
          : enclosureId as String,
      startedAt: startedAt == const $CopyWithPlaceholder()
          ? _value.startedAt
          // ignore: cast_nullable_to_non_nullable
          : startedAt as DateTime,
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

extension $StartPairingRequestCopyWith on StartPairingRequest {
  /// Returns a callable class that can be used as follows: `instanceOfStartPairingRequest.copyWith(...)` or like so:`instanceOfStartPairingRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StartPairingRequestCWProxy get copyWith =>
      _$StartPairingRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartPairingRequest _$StartPairingRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'StartPairingRequest',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['enclosure_id', 'started_at', 'timezone'],
        );
        final val = StartPairingRequest(
          enclosureId: $checkedConvert('enclosure_id', (v) => v as String),
          startedAt: $checkedConvert(
            'started_at',
            (v) => DateTime.parse(v as String),
          ),
          timezone: $checkedConvert('timezone', (v) => v as String),
          notes: $checkedConvert('notes', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'enclosureId': 'enclosure_id',
        'startedAt': 'started_at',
      },
    );

Map<String, dynamic> _$StartPairingRequestToJson(
  StartPairingRequest instance,
) => <String, dynamic>{
  'enclosure_id': instance.enclosureId,
  'started_at': instance.startedAt.toIso8601String(),
  'timezone': instance.timezone,
  'notes': ?instance.notes,
};
