// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_record_one_of1.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeightRecordOneOf1CWProxy {
  WeightRecordOneOf1 hamsterId(Object? hamsterId);

  WeightRecordOneOf1 litterId(Object? litterId);

  WeightRecordOneOf1 measurementKind(
    WeightRecordOneOf1MeasurementKindEnum? measurementKind,
  );

  WeightRecordOneOf1 subjectCount(Object? subjectCount);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightRecordOneOf1(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightRecordOneOf1(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightRecordOneOf1 call({
    Object? hamsterId,
    Object? litterId,
    WeightRecordOneOf1MeasurementKindEnum? measurementKind,
    Object? subjectCount,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeightRecordOneOf1.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeightRecordOneOf1.copyWith.fieldName(...)`
class _$WeightRecordOneOf1CWProxyImpl implements _$WeightRecordOneOf1CWProxy {
  const _$WeightRecordOneOf1CWProxyImpl(this._value);

  final WeightRecordOneOf1 _value;

  @override
  WeightRecordOneOf1 hamsterId(Object? hamsterId) => this(hamsterId: hamsterId);

  @override
  WeightRecordOneOf1 litterId(Object? litterId) => this(litterId: litterId);

  @override
  WeightRecordOneOf1 measurementKind(
    WeightRecordOneOf1MeasurementKindEnum? measurementKind,
  ) => this(measurementKind: measurementKind);

  @override
  WeightRecordOneOf1 subjectCount(Object? subjectCount) =>
      this(subjectCount: subjectCount);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightRecordOneOf1(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightRecordOneOf1(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightRecordOneOf1 call({
    Object? hamsterId = const $CopyWithPlaceholder(),
    Object? litterId = const $CopyWithPlaceholder(),
    Object? measurementKind = const $CopyWithPlaceholder(),
    Object? subjectCount = const $CopyWithPlaceholder(),
  }) {
    return WeightRecordOneOf1(
      hamsterId: hamsterId == const $CopyWithPlaceholder()
          ? _value.hamsterId
          // ignore: cast_nullable_to_non_nullable
          : hamsterId as Object?,
      litterId: litterId == const $CopyWithPlaceholder()
          ? _value.litterId
          // ignore: cast_nullable_to_non_nullable
          : litterId as Object?,
      measurementKind: measurementKind == const $CopyWithPlaceholder()
          ? _value.measurementKind
          // ignore: cast_nullable_to_non_nullable
          : measurementKind as WeightRecordOneOf1MeasurementKindEnum?,
      subjectCount: subjectCount == const $CopyWithPlaceholder()
          ? _value.subjectCount
          // ignore: cast_nullable_to_non_nullable
          : subjectCount as Object?,
    );
  }
}

extension $WeightRecordOneOf1CopyWith on WeightRecordOneOf1 {
  /// Returns a callable class that can be used as follows: `instanceOfWeightRecordOneOf1.copyWith(...)` or like so:`instanceOfWeightRecordOneOf1.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeightRecordOneOf1CWProxy get copyWith =>
      _$WeightRecordOneOf1CWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightRecordOneOf1 _$WeightRecordOneOf1FromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WeightRecordOneOf1',
      json,
      ($checkedConvert) {
        final val = WeightRecordOneOf1(
          hamsterId: $checkedConvert('hamster_id', (v) => v),
          litterId: $checkedConvert('litter_id', (v) => v),
          measurementKind: $checkedConvert(
            'measurement_kind',
            (v) => $enumDecodeNullable(
              _$WeightRecordOneOf1MeasurementKindEnumEnumMap,
              v,
            ),
          ),
          subjectCount: $checkedConvert('subject_count', (v) => v),
        );
        return val;
      },
      fieldKeyMap: const {
        'hamsterId': 'hamster_id',
        'litterId': 'litter_id',
        'measurementKind': 'measurement_kind',
        'subjectCount': 'subject_count',
      },
    );

Map<String, dynamic> _$WeightRecordOneOf1ToJson(
  WeightRecordOneOf1 instance,
) => <String, dynamic>{
  'hamster_id': ?instance.hamsterId,
  'litter_id': ?instance.litterId,
  'measurement_kind':
      ?_$WeightRecordOneOf1MeasurementKindEnumEnumMap[instance.measurementKind],
  'subject_count': ?instance.subjectCount,
};

const _$WeightRecordOneOf1MeasurementKindEnumEnumMap = {
  WeightRecordOneOf1MeasurementKindEnum.individual: 'individual',
};
