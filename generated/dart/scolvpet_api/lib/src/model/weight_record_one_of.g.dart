// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_record_one_of.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeightRecordOneOfCWProxy {
  WeightRecordOneOf pupIdentityId(Object? pupIdentityId);

  WeightRecordOneOf litterId(Object? litterId);

  WeightRecordOneOf measurementKind(
    WeightRecordOneOfMeasurementKindEnum? measurementKind,
  );

  WeightRecordOneOf subjectCount(Object? subjectCount);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightRecordOneOf(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightRecordOneOf(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightRecordOneOf call({
    Object? pupIdentityId,
    Object? litterId,
    WeightRecordOneOfMeasurementKindEnum? measurementKind,
    Object? subjectCount,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeightRecordOneOf.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeightRecordOneOf.copyWith.fieldName(...)`
class _$WeightRecordOneOfCWProxyImpl implements _$WeightRecordOneOfCWProxy {
  const _$WeightRecordOneOfCWProxyImpl(this._value);

  final WeightRecordOneOf _value;

  @override
  WeightRecordOneOf pupIdentityId(Object? pupIdentityId) =>
      this(pupIdentityId: pupIdentityId);

  @override
  WeightRecordOneOf litterId(Object? litterId) => this(litterId: litterId);

  @override
  WeightRecordOneOf measurementKind(
    WeightRecordOneOfMeasurementKindEnum? measurementKind,
  ) => this(measurementKind: measurementKind);

  @override
  WeightRecordOneOf subjectCount(Object? subjectCount) =>
      this(subjectCount: subjectCount);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightRecordOneOf(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightRecordOneOf(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightRecordOneOf call({
    Object? pupIdentityId = const $CopyWithPlaceholder(),
    Object? litterId = const $CopyWithPlaceholder(),
    Object? measurementKind = const $CopyWithPlaceholder(),
    Object? subjectCount = const $CopyWithPlaceholder(),
  }) {
    return WeightRecordOneOf(
      pupIdentityId: pupIdentityId == const $CopyWithPlaceholder()
          ? _value.pupIdentityId
          // ignore: cast_nullable_to_non_nullable
          : pupIdentityId as Object?,
      litterId: litterId == const $CopyWithPlaceholder()
          ? _value.litterId
          // ignore: cast_nullable_to_non_nullable
          : litterId as Object?,
      measurementKind: measurementKind == const $CopyWithPlaceholder()
          ? _value.measurementKind
          // ignore: cast_nullable_to_non_nullable
          : measurementKind as WeightRecordOneOfMeasurementKindEnum?,
      subjectCount: subjectCount == const $CopyWithPlaceholder()
          ? _value.subjectCount
          // ignore: cast_nullable_to_non_nullable
          : subjectCount as Object?,
    );
  }
}

extension $WeightRecordOneOfCopyWith on WeightRecordOneOf {
  /// Returns a callable class that can be used as follows: `instanceOfWeightRecordOneOf.copyWith(...)` or like so:`instanceOfWeightRecordOneOf.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeightRecordOneOfCWProxy get copyWith =>
      _$WeightRecordOneOfCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightRecordOneOf _$WeightRecordOneOfFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WeightRecordOneOf',
      json,
      ($checkedConvert) {
        final val = WeightRecordOneOf(
          pupIdentityId: $checkedConvert('pup_identity_id', (v) => v),
          litterId: $checkedConvert('litter_id', (v) => v),
          measurementKind: $checkedConvert(
            'measurement_kind',
            (v) => $enumDecodeNullable(
              _$WeightRecordOneOfMeasurementKindEnumEnumMap,
              v,
            ),
          ),
          subjectCount: $checkedConvert('subject_count', (v) => v),
        );
        return val;
      },
      fieldKeyMap: const {
        'pupIdentityId': 'pup_identity_id',
        'litterId': 'litter_id',
        'measurementKind': 'measurement_kind',
        'subjectCount': 'subject_count',
      },
    );

Map<String, dynamic> _$WeightRecordOneOfToJson(
  WeightRecordOneOf instance,
) => <String, dynamic>{
  'pup_identity_id': ?instance.pupIdentityId,
  'litter_id': ?instance.litterId,
  'measurement_kind':
      ?_$WeightRecordOneOfMeasurementKindEnumEnumMap[instance.measurementKind],
  'subject_count': ?instance.subjectCount,
};

const _$WeightRecordOneOfMeasurementKindEnumEnumMap = {
  WeightRecordOneOfMeasurementKindEnum.individual: 'individual',
};
