// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wean_litter_request_items_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeanLitterRequestItemsInnerCWProxy {
  WeanLitterRequestItemsInner pupIdentityId(String pupIdentityId);

  WeanLitterRequestItemsInner outcomeStatus(PupOutcomeStatus outcomeStatus);

  WeanLitterRequestItemsInner destinationEnclosureId(
    String? destinationEnclosureId,
  );

  WeanLitterRequestItemsInner notes(String? notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeanLitterRequestItemsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeanLitterRequestItemsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  WeanLitterRequestItemsInner call({
    String pupIdentityId,
    PupOutcomeStatus outcomeStatus,
    String? destinationEnclosureId,
    String? notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeanLitterRequestItemsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeanLitterRequestItemsInner.copyWith.fieldName(...)`
class _$WeanLitterRequestItemsInnerCWProxyImpl
    implements _$WeanLitterRequestItemsInnerCWProxy {
  const _$WeanLitterRequestItemsInnerCWProxyImpl(this._value);

  final WeanLitterRequestItemsInner _value;

  @override
  WeanLitterRequestItemsInner pupIdentityId(String pupIdentityId) =>
      this(pupIdentityId: pupIdentityId);

  @override
  WeanLitterRequestItemsInner outcomeStatus(PupOutcomeStatus outcomeStatus) =>
      this(outcomeStatus: outcomeStatus);

  @override
  WeanLitterRequestItemsInner destinationEnclosureId(
    String? destinationEnclosureId,
  ) => this(destinationEnclosureId: destinationEnclosureId);

  @override
  WeanLitterRequestItemsInner notes(String? notes) => this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeanLitterRequestItemsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeanLitterRequestItemsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  WeanLitterRequestItemsInner call({
    Object? pupIdentityId = const $CopyWithPlaceholder(),
    Object? outcomeStatus = const $CopyWithPlaceholder(),
    Object? destinationEnclosureId = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return WeanLitterRequestItemsInner(
      pupIdentityId: pupIdentityId == const $CopyWithPlaceholder()
          ? _value.pupIdentityId
          // ignore: cast_nullable_to_non_nullable
          : pupIdentityId as String,
      outcomeStatus: outcomeStatus == const $CopyWithPlaceholder()
          ? _value.outcomeStatus
          // ignore: cast_nullable_to_non_nullable
          : outcomeStatus as PupOutcomeStatus,
      destinationEnclosureId:
          destinationEnclosureId == const $CopyWithPlaceholder()
          ? _value.destinationEnclosureId
          // ignore: cast_nullable_to_non_nullable
          : destinationEnclosureId as String?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
    );
  }
}

extension $WeanLitterRequestItemsInnerCopyWith on WeanLitterRequestItemsInner {
  /// Returns a callable class that can be used as follows: `instanceOfWeanLitterRequestItemsInner.copyWith(...)` or like so:`instanceOfWeanLitterRequestItemsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeanLitterRequestItemsInnerCWProxy get copyWith =>
      _$WeanLitterRequestItemsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeanLitterRequestItemsInner _$WeanLitterRequestItemsInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'WeanLitterRequestItemsInner',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['pup_identity_id', 'outcome_status']);
    final val = WeanLitterRequestItemsInner(
      pupIdentityId: $checkedConvert('pup_identity_id', (v) => v as String),
      outcomeStatus: $checkedConvert(
        'outcome_status',
        (v) => $enumDecode(_$PupOutcomeStatusEnumMap, v),
      ),
      destinationEnclosureId: $checkedConvert(
        'destination_enclosure_id',
        (v) => v as String?,
      ),
      notes: $checkedConvert('notes', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'pupIdentityId': 'pup_identity_id',
    'outcomeStatus': 'outcome_status',
    'destinationEnclosureId': 'destination_enclosure_id',
  },
);

Map<String, dynamic> _$WeanLitterRequestItemsInnerToJson(
  WeanLitterRequestItemsInner instance,
) => <String, dynamic>{
  'pup_identity_id': instance.pupIdentityId,
  'outcome_status': _$PupOutcomeStatusEnumMap[instance.outcomeStatus]!,
  'destination_enclosure_id': ?instance.destinationEnclosureId,
  'notes': ?instance.notes,
};

const _$PupOutcomeStatusEnumMap = {
  PupOutcomeStatus.alive: 'alive',
  PupOutcomeStatus.deceased: 'deceased',
  PupOutcomeStatus.transferredOut: 'transferred_out',
};
