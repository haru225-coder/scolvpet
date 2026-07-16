// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_record_one_of2.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeightRecordOneOf2CWProxy {
  WeightRecordOneOf2 hamsterId(Object? hamsterId);

  WeightRecordOneOf2 pupIdentityId(Object? pupIdentityId);

  WeightRecordOneOf2 measurementKind(
    WeightRecordOneOf2MeasurementKindEnum measurementKind,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightRecordOneOf2(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightRecordOneOf2(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightRecordOneOf2 call({
    Object? hamsterId,
    Object? pupIdentityId,
    WeightRecordOneOf2MeasurementKindEnum measurementKind,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeightRecordOneOf2.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeightRecordOneOf2.copyWith.fieldName(...)`
class _$WeightRecordOneOf2CWProxyImpl implements _$WeightRecordOneOf2CWProxy {
  const _$WeightRecordOneOf2CWProxyImpl(this._value);

  final WeightRecordOneOf2 _value;

  @override
  WeightRecordOneOf2 hamsterId(Object? hamsterId) => this(hamsterId: hamsterId);

  @override
  WeightRecordOneOf2 pupIdentityId(Object? pupIdentityId) =>
      this(pupIdentityId: pupIdentityId);

  @override
  WeightRecordOneOf2 measurementKind(
    WeightRecordOneOf2MeasurementKindEnum measurementKind,
  ) => this(measurementKind: measurementKind);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightRecordOneOf2(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightRecordOneOf2(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightRecordOneOf2 call({
    Object? hamsterId = const $CopyWithPlaceholder(),
    Object? pupIdentityId = const $CopyWithPlaceholder(),
    Object? measurementKind = const $CopyWithPlaceholder(),
  }) {
    return WeightRecordOneOf2(
      hamsterId: hamsterId == const $CopyWithPlaceholder()
          ? _value.hamsterId
          // ignore: cast_nullable_to_non_nullable
          : hamsterId as Object?,
      pupIdentityId: pupIdentityId == const $CopyWithPlaceholder()
          ? _value.pupIdentityId
          // ignore: cast_nullable_to_non_nullable
          : pupIdentityId as Object?,
      measurementKind: measurementKind == const $CopyWithPlaceholder()
          ? _value.measurementKind
          // ignore: cast_nullable_to_non_nullable
          : measurementKind as WeightRecordOneOf2MeasurementKindEnum,
    );
  }
}

extension $WeightRecordOneOf2CopyWith on WeightRecordOneOf2 {
  /// Returns a callable class that can be used as follows: `instanceOfWeightRecordOneOf2.copyWith(...)` or like so:`instanceOfWeightRecordOneOf2.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeightRecordOneOf2CWProxy get copyWith =>
      _$WeightRecordOneOf2CWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightRecordOneOf2 _$WeightRecordOneOf2FromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WeightRecordOneOf2',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['measurement_kind']);
        final val = WeightRecordOneOf2(
          hamsterId: $checkedConvert('hamster_id', (v) => v),
          pupIdentityId: $checkedConvert('pup_identity_id', (v) => v),
          measurementKind: $checkedConvert(
            'measurement_kind',
            (v) =>
                $enumDecode(_$WeightRecordOneOf2MeasurementKindEnumEnumMap, v),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'hamsterId': 'hamster_id',
        'pupIdentityId': 'pup_identity_id',
        'measurementKind': 'measurement_kind',
      },
    );

Map<String, dynamic> _$WeightRecordOneOf2ToJson(
  WeightRecordOneOf2 instance,
) => <String, dynamic>{
  'hamster_id': ?instance.hamsterId,
  'pup_identity_id': ?instance.pupIdentityId,
  'measurement_kind':
      _$WeightRecordOneOf2MeasurementKindEnumEnumMap[instance.measurementKind]!,
};

const _$WeightRecordOneOf2MeasurementKindEnumEnumMap = {
  WeightRecordOneOf2MeasurementKindEnum.litterTotal: 'litter_total',
  WeightRecordOneOf2MeasurementKindEnum.litterAverage: 'litter_average',
};
