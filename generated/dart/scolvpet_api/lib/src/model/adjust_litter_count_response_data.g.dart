// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adjust_litter_count_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdjustLitterCountResponseDataCWProxy {
  AdjustLitterCountResponseData litter(Litter litter);

  AdjustLitterCountResponseData countEvent(LitterCountEvent countEvent);

  AdjustLitterCountResponseData createdPupIdentities(
    List<PupIdentity> createdPupIdentities,
  );

  AdjustLitterCountResponseData closedPupIdentityIds(
    List<String> closedPupIdentityIds,
  );

  AdjustLitterCountResponseData reconciliation(Reconciliation reconciliation);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdjustLitterCountResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdjustLitterCountResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  AdjustLitterCountResponseData call({
    Litter litter,
    LitterCountEvent countEvent,
    List<PupIdentity> createdPupIdentities,
    List<String> closedPupIdentityIds,
    Reconciliation reconciliation,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAdjustLitterCountResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAdjustLitterCountResponseData.copyWith.fieldName(...)`
class _$AdjustLitterCountResponseDataCWProxyImpl
    implements _$AdjustLitterCountResponseDataCWProxy {
  const _$AdjustLitterCountResponseDataCWProxyImpl(this._value);

  final AdjustLitterCountResponseData _value;

  @override
  AdjustLitterCountResponseData litter(Litter litter) => this(litter: litter);

  @override
  AdjustLitterCountResponseData countEvent(LitterCountEvent countEvent) =>
      this(countEvent: countEvent);

  @override
  AdjustLitterCountResponseData createdPupIdentities(
    List<PupIdentity> createdPupIdentities,
  ) => this(createdPupIdentities: createdPupIdentities);

  @override
  AdjustLitterCountResponseData closedPupIdentityIds(
    List<String> closedPupIdentityIds,
  ) => this(closedPupIdentityIds: closedPupIdentityIds);

  @override
  AdjustLitterCountResponseData reconciliation(Reconciliation reconciliation) =>
      this(reconciliation: reconciliation);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdjustLitterCountResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdjustLitterCountResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  AdjustLitterCountResponseData call({
    Object? litter = const $CopyWithPlaceholder(),
    Object? countEvent = const $CopyWithPlaceholder(),
    Object? createdPupIdentities = const $CopyWithPlaceholder(),
    Object? closedPupIdentityIds = const $CopyWithPlaceholder(),
    Object? reconciliation = const $CopyWithPlaceholder(),
  }) {
    return AdjustLitterCountResponseData(
      litter: litter == const $CopyWithPlaceholder()
          ? _value.litter
          // ignore: cast_nullable_to_non_nullable
          : litter as Litter,
      countEvent: countEvent == const $CopyWithPlaceholder()
          ? _value.countEvent
          // ignore: cast_nullable_to_non_nullable
          : countEvent as LitterCountEvent,
      createdPupIdentities: createdPupIdentities == const $CopyWithPlaceholder()
          ? _value.createdPupIdentities
          // ignore: cast_nullable_to_non_nullable
          : createdPupIdentities as List<PupIdentity>,
      closedPupIdentityIds: closedPupIdentityIds == const $CopyWithPlaceholder()
          ? _value.closedPupIdentityIds
          // ignore: cast_nullable_to_non_nullable
          : closedPupIdentityIds as List<String>,
      reconciliation: reconciliation == const $CopyWithPlaceholder()
          ? _value.reconciliation
          // ignore: cast_nullable_to_non_nullable
          : reconciliation as Reconciliation,
    );
  }
}

extension $AdjustLitterCountResponseDataCopyWith
    on AdjustLitterCountResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfAdjustLitterCountResponseData.copyWith(...)` or like so:`instanceOfAdjustLitterCountResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AdjustLitterCountResponseDataCWProxy get copyWith =>
      _$AdjustLitterCountResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdjustLitterCountResponseData _$AdjustLitterCountResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AdjustLitterCountResponseData',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'litter',
        'count_event',
        'created_pup_identities',
        'closed_pup_identity_ids',
        'reconciliation',
      ],
    );
    final val = AdjustLitterCountResponseData(
      litter: $checkedConvert(
        'litter',
        (v) => Litter.fromJson(v as Map<String, dynamic>),
      ),
      countEvent: $checkedConvert(
        'count_event',
        (v) => LitterCountEvent.fromJson(v as Map<String, dynamic>),
      ),
      createdPupIdentities: $checkedConvert(
        'created_pup_identities',
        (v) => (v as List<dynamic>)
            .map((e) => PupIdentity.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      closedPupIdentityIds: $checkedConvert(
        'closed_pup_identity_ids',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      reconciliation: $checkedConvert(
        'reconciliation',
        (v) => Reconciliation.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'countEvent': 'count_event',
    'createdPupIdentities': 'created_pup_identities',
    'closedPupIdentityIds': 'closed_pup_identity_ids',
  },
);

Map<String, dynamic> _$AdjustLitterCountResponseDataToJson(
  AdjustLitterCountResponseData instance,
) => <String, dynamic>{
  'litter': instance.litter.toJson(),
  'count_event': instance.countEvent.toJson(),
  'created_pup_identities': instance.createdPupIdentities
      .map((e) => e.toJson())
      .toList(),
  'closed_pup_identity_ids': instance.closedPupIdentityIds,
  'reconciliation': instance.reconciliation.toJson(),
};
