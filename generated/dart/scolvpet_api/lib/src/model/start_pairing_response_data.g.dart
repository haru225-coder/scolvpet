// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_pairing_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StartPairingResponseDataCWProxy {
  StartPairingResponseData breedingPlan(BreedingPlan breedingPlan);

  StartPairingResponseData pairingAttempt(PairingAttempt pairingAttempt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StartPairingResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StartPairingResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  StartPairingResponseData call({
    BreedingPlan breedingPlan,
    PairingAttempt pairingAttempt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStartPairingResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStartPairingResponseData.copyWith.fieldName(...)`
class _$StartPairingResponseDataCWProxyImpl
    implements _$StartPairingResponseDataCWProxy {
  const _$StartPairingResponseDataCWProxyImpl(this._value);

  final StartPairingResponseData _value;

  @override
  StartPairingResponseData breedingPlan(BreedingPlan breedingPlan) =>
      this(breedingPlan: breedingPlan);

  @override
  StartPairingResponseData pairingAttempt(PairingAttempt pairingAttempt) =>
      this(pairingAttempt: pairingAttempt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StartPairingResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StartPairingResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  StartPairingResponseData call({
    Object? breedingPlan = const $CopyWithPlaceholder(),
    Object? pairingAttempt = const $CopyWithPlaceholder(),
  }) {
    return StartPairingResponseData(
      breedingPlan: breedingPlan == const $CopyWithPlaceholder()
          ? _value.breedingPlan
          // ignore: cast_nullable_to_non_nullable
          : breedingPlan as BreedingPlan,
      pairingAttempt: pairingAttempt == const $CopyWithPlaceholder()
          ? _value.pairingAttempt
          // ignore: cast_nullable_to_non_nullable
          : pairingAttempt as PairingAttempt,
    );
  }
}

extension $StartPairingResponseDataCopyWith on StartPairingResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfStartPairingResponseData.copyWith(...)` or like so:`instanceOfStartPairingResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StartPairingResponseDataCWProxy get copyWith =>
      _$StartPairingResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartPairingResponseData _$StartPairingResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'StartPairingResponseData',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['breeding_plan', 'pairing_attempt']);
    final val = StartPairingResponseData(
      breedingPlan: $checkedConvert(
        'breeding_plan',
        (v) => BreedingPlan.fromJson(v as Map<String, dynamic>),
      ),
      pairingAttempt: $checkedConvert(
        'pairing_attempt',
        (v) => PairingAttempt.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'breedingPlan': 'breeding_plan',
    'pairingAttempt': 'pairing_attempt',
  },
);

Map<String, dynamic> _$StartPairingResponseDataToJson(
  StartPairingResponseData instance,
) => <String, dynamic>{
  'breeding_plan': instance.breedingPlan.toJson(),
  'pairing_attempt': instance.pairingAttempt.toJson(),
};
