// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'separate_pairing_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SeparatePairingResponseDataCWProxy {
  SeparatePairingResponseData pairingAttempt(PairingAttempt pairingAttempt);

  SeparatePairingResponseData breedingPlan(BreedingPlan breedingPlan);

  SeparatePairingResponseData createdStays(List<EnclosureStay> createdStays);

  SeparatePairingResponseData createdTaskIds(List<String> createdTaskIds);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SeparatePairingResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SeparatePairingResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  SeparatePairingResponseData call({
    PairingAttempt pairingAttempt,
    BreedingPlan breedingPlan,
    List<EnclosureStay> createdStays,
    List<String> createdTaskIds,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSeparatePairingResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSeparatePairingResponseData.copyWith.fieldName(...)`
class _$SeparatePairingResponseDataCWProxyImpl
    implements _$SeparatePairingResponseDataCWProxy {
  const _$SeparatePairingResponseDataCWProxyImpl(this._value);

  final SeparatePairingResponseData _value;

  @override
  SeparatePairingResponseData pairingAttempt(PairingAttempt pairingAttempt) =>
      this(pairingAttempt: pairingAttempt);

  @override
  SeparatePairingResponseData breedingPlan(BreedingPlan breedingPlan) =>
      this(breedingPlan: breedingPlan);

  @override
  SeparatePairingResponseData createdStays(List<EnclosureStay> createdStays) =>
      this(createdStays: createdStays);

  @override
  SeparatePairingResponseData createdTaskIds(List<String> createdTaskIds) =>
      this(createdTaskIds: createdTaskIds);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SeparatePairingResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SeparatePairingResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  SeparatePairingResponseData call({
    Object? pairingAttempt = const $CopyWithPlaceholder(),
    Object? breedingPlan = const $CopyWithPlaceholder(),
    Object? createdStays = const $CopyWithPlaceholder(),
    Object? createdTaskIds = const $CopyWithPlaceholder(),
  }) {
    return SeparatePairingResponseData(
      pairingAttempt: pairingAttempt == const $CopyWithPlaceholder()
          ? _value.pairingAttempt
          // ignore: cast_nullable_to_non_nullable
          : pairingAttempt as PairingAttempt,
      breedingPlan: breedingPlan == const $CopyWithPlaceholder()
          ? _value.breedingPlan
          // ignore: cast_nullable_to_non_nullable
          : breedingPlan as BreedingPlan,
      createdStays: createdStays == const $CopyWithPlaceholder()
          ? _value.createdStays
          // ignore: cast_nullable_to_non_nullable
          : createdStays as List<EnclosureStay>,
      createdTaskIds: createdTaskIds == const $CopyWithPlaceholder()
          ? _value.createdTaskIds
          // ignore: cast_nullable_to_non_nullable
          : createdTaskIds as List<String>,
    );
  }
}

extension $SeparatePairingResponseDataCopyWith on SeparatePairingResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfSeparatePairingResponseData.copyWith(...)` or like so:`instanceOfSeparatePairingResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SeparatePairingResponseDataCWProxy get copyWith =>
      _$SeparatePairingResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SeparatePairingResponseData _$SeparatePairingResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'SeparatePairingResponseData',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'pairing_attempt',
        'breeding_plan',
        'created_stays',
        'created_task_ids',
      ],
    );
    final val = SeparatePairingResponseData(
      pairingAttempt: $checkedConvert(
        'pairing_attempt',
        (v) => PairingAttempt.fromJson(v as Map<String, dynamic>),
      ),
      breedingPlan: $checkedConvert(
        'breeding_plan',
        (v) => BreedingPlan.fromJson(v as Map<String, dynamic>),
      ),
      createdStays: $checkedConvert(
        'created_stays',
        (v) => (v as List<dynamic>)
            .map((e) => EnclosureStay.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      createdTaskIds: $checkedConvert(
        'created_task_ids',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'pairingAttempt': 'pairing_attempt',
    'breedingPlan': 'breeding_plan',
    'createdStays': 'created_stays',
    'createdTaskIds': 'created_task_ids',
  },
);

Map<String, dynamic> _$SeparatePairingResponseDataToJson(
  SeparatePairingResponseData instance,
) => <String, dynamic>{
  'pairing_attempt': instance.pairingAttempt.toJson(),
  'breeding_plan': instance.breedingPlan.toJson(),
  'created_stays': instance.createdStays.map((e) => e.toJson()).toList(),
  'created_task_ids': instance.createdTaskIds,
};
