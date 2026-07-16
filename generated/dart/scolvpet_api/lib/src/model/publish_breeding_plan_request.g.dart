// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publish_breeding_plan_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublishBreedingPlanRequestCWProxy {
  PublishBreedingPlanRequest plannedPairingAt(DateTime plannedPairingAt);

  PublishBreedingPlanRequest pairingEnclosureId(String pairingEnclosureId);

  PublishBreedingPlanRequest timezone(String timezone);

  PublishBreedingPlanRequest kinshipOverrideReason(
    String? kinshipOverrideReason,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublishBreedingPlanRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublishBreedingPlanRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PublishBreedingPlanRequest call({
    DateTime plannedPairingAt,
    String pairingEnclosureId,
    String timezone,
    String? kinshipOverrideReason,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublishBreedingPlanRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublishBreedingPlanRequest.copyWith.fieldName(...)`
class _$PublishBreedingPlanRequestCWProxyImpl
    implements _$PublishBreedingPlanRequestCWProxy {
  const _$PublishBreedingPlanRequestCWProxyImpl(this._value);

  final PublishBreedingPlanRequest _value;

  @override
  PublishBreedingPlanRequest plannedPairingAt(DateTime plannedPairingAt) =>
      this(plannedPairingAt: plannedPairingAt);

  @override
  PublishBreedingPlanRequest pairingEnclosureId(String pairingEnclosureId) =>
      this(pairingEnclosureId: pairingEnclosureId);

  @override
  PublishBreedingPlanRequest timezone(String timezone) =>
      this(timezone: timezone);

  @override
  PublishBreedingPlanRequest kinshipOverrideReason(
    String? kinshipOverrideReason,
  ) => this(kinshipOverrideReason: kinshipOverrideReason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublishBreedingPlanRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublishBreedingPlanRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PublishBreedingPlanRequest call({
    Object? plannedPairingAt = const $CopyWithPlaceholder(),
    Object? pairingEnclosureId = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
    Object? kinshipOverrideReason = const $CopyWithPlaceholder(),
  }) {
    return PublishBreedingPlanRequest(
      plannedPairingAt: plannedPairingAt == const $CopyWithPlaceholder()
          ? _value.plannedPairingAt
          // ignore: cast_nullable_to_non_nullable
          : plannedPairingAt as DateTime,
      pairingEnclosureId: pairingEnclosureId == const $CopyWithPlaceholder()
          ? _value.pairingEnclosureId
          // ignore: cast_nullable_to_non_nullable
          : pairingEnclosureId as String,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String,
      kinshipOverrideReason:
          kinshipOverrideReason == const $CopyWithPlaceholder()
          ? _value.kinshipOverrideReason
          // ignore: cast_nullable_to_non_nullable
          : kinshipOverrideReason as String?,
    );
  }
}

extension $PublishBreedingPlanRequestCopyWith on PublishBreedingPlanRequest {
  /// Returns a callable class that can be used as follows: `instanceOfPublishBreedingPlanRequest.copyWith(...)` or like so:`instanceOfPublishBreedingPlanRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublishBreedingPlanRequestCWProxy get copyWith =>
      _$PublishBreedingPlanRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublishBreedingPlanRequest _$PublishBreedingPlanRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PublishBreedingPlanRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'planned_pairing_at',
        'pairing_enclosure_id',
        'timezone',
      ],
    );
    final val = PublishBreedingPlanRequest(
      plannedPairingAt: $checkedConvert(
        'planned_pairing_at',
        (v) => DateTime.parse(v as String),
      ),
      pairingEnclosureId: $checkedConvert(
        'pairing_enclosure_id',
        (v) => v as String,
      ),
      timezone: $checkedConvert('timezone', (v) => v as String),
      kinshipOverrideReason: $checkedConvert(
        'kinship_override_reason',
        (v) => v as String?,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'plannedPairingAt': 'planned_pairing_at',
    'pairingEnclosureId': 'pairing_enclosure_id',
    'kinshipOverrideReason': 'kinship_override_reason',
  },
);

Map<String, dynamic> _$PublishBreedingPlanRequestToJson(
  PublishBreedingPlanRequest instance,
) => <String, dynamic>{
  'planned_pairing_at': instance.plannedPairingAt.toIso8601String(),
  'pairing_enclosure_id': instance.pairingEnclosureId,
  'timezone': instance.timezone,
  'kinship_override_reason': ?instance.kinshipOverrideReason,
};
