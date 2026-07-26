// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_record_create_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeightRecordCreateRequestCWProxy {
  WeightRecordCreateRequest hamsterId(String? hamsterId);

  WeightRecordCreateRequest pupIdentityId(String? pupIdentityId);

  WeightRecordCreateRequest litterId(String? litterId);

  WeightRecordCreateRequest measurementKind(
    WeightRecordCreateRequestMeasurementKindEnum? measurementKind,
  );

  WeightRecordCreateRequest subjectCount(int? subjectCount);

  WeightRecordCreateRequest weightG(num weightG);

  WeightRecordCreateRequest recordedAt(DateTime recordedAt);

  WeightRecordCreateRequest source_(
    WeightRecordCreateRequestSource_Enum source_,
  );

  WeightRecordCreateRequest deviceReadingId(String? deviceReadingId);

  WeightRecordCreateRequest notes(String? notes);

  WeightRecordCreateRequest correctsWeightRecordId(
    String? correctsWeightRecordId,
  );

  WeightRecordCreateRequest correctionReason(String? correctionReason);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightRecordCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightRecordCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightRecordCreateRequest call({
    String? hamsterId,
    String? pupIdentityId,
    String? litterId,
    WeightRecordCreateRequestMeasurementKindEnum? measurementKind,
    int? subjectCount,
    num weightG,
    DateTime recordedAt,
    WeightRecordCreateRequestSource_Enum source_,
    String? deviceReadingId,
    String? notes,
    String? correctsWeightRecordId,
    String? correctionReason,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeightRecordCreateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeightRecordCreateRequest.copyWith.fieldName(...)`
class _$WeightRecordCreateRequestCWProxyImpl
    implements _$WeightRecordCreateRequestCWProxy {
  const _$WeightRecordCreateRequestCWProxyImpl(this._value);

  final WeightRecordCreateRequest _value;

  @override
  WeightRecordCreateRequest hamsterId(String? hamsterId) =>
      this(hamsterId: hamsterId);

  @override
  WeightRecordCreateRequest pupIdentityId(String? pupIdentityId) =>
      this(pupIdentityId: pupIdentityId);

  @override
  WeightRecordCreateRequest litterId(String? litterId) =>
      this(litterId: litterId);

  @override
  WeightRecordCreateRequest measurementKind(
    WeightRecordCreateRequestMeasurementKindEnum? measurementKind,
  ) => this(measurementKind: measurementKind);

  @override
  WeightRecordCreateRequest subjectCount(int? subjectCount) =>
      this(subjectCount: subjectCount);

  @override
  WeightRecordCreateRequest weightG(num weightG) => this(weightG: weightG);

  @override
  WeightRecordCreateRequest recordedAt(DateTime recordedAt) =>
      this(recordedAt: recordedAt);

  @override
  WeightRecordCreateRequest source_(
    WeightRecordCreateRequestSource_Enum source_,
  ) => this(source_: source_);

  @override
  WeightRecordCreateRequest deviceReadingId(String? deviceReadingId) =>
      this(deviceReadingId: deviceReadingId);

  @override
  WeightRecordCreateRequest notes(String? notes) => this(notes: notes);

  @override
  WeightRecordCreateRequest correctsWeightRecordId(
    String? correctsWeightRecordId,
  ) => this(correctsWeightRecordId: correctsWeightRecordId);

  @override
  WeightRecordCreateRequest correctionReason(String? correctionReason) =>
      this(correctionReason: correctionReason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightRecordCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightRecordCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightRecordCreateRequest call({
    Object? hamsterId = const $CopyWithPlaceholder(),
    Object? pupIdentityId = const $CopyWithPlaceholder(),
    Object? litterId = const $CopyWithPlaceholder(),
    Object? measurementKind = const $CopyWithPlaceholder(),
    Object? subjectCount = const $CopyWithPlaceholder(),
    Object? weightG = const $CopyWithPlaceholder(),
    Object? recordedAt = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
    Object? deviceReadingId = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? correctsWeightRecordId = const $CopyWithPlaceholder(),
    Object? correctionReason = const $CopyWithPlaceholder(),
  }) {
    return WeightRecordCreateRequest(
      hamsterId: hamsterId == const $CopyWithPlaceholder()
          ? _value.hamsterId
          // ignore: cast_nullable_to_non_nullable
          : hamsterId as String?,
      pupIdentityId: pupIdentityId == const $CopyWithPlaceholder()
          ? _value.pupIdentityId
          // ignore: cast_nullable_to_non_nullable
          : pupIdentityId as String?,
      litterId: litterId == const $CopyWithPlaceholder()
          ? _value.litterId
          // ignore: cast_nullable_to_non_nullable
          : litterId as String?,
      measurementKind: measurementKind == const $CopyWithPlaceholder()
          ? _value.measurementKind
          // ignore: cast_nullable_to_non_nullable
          : measurementKind as WeightRecordCreateRequestMeasurementKindEnum?,
      subjectCount: subjectCount == const $CopyWithPlaceholder()
          ? _value.subjectCount
          // ignore: cast_nullable_to_non_nullable
          : subjectCount as int?,
      weightG: weightG == const $CopyWithPlaceholder()
          ? _value.weightG
          // ignore: cast_nullable_to_non_nullable
          : weightG as num,
      recordedAt: recordedAt == const $CopyWithPlaceholder()
          ? _value.recordedAt
          // ignore: cast_nullable_to_non_nullable
          : recordedAt as DateTime,
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as WeightRecordCreateRequestSource_Enum,
      deviceReadingId: deviceReadingId == const $CopyWithPlaceholder()
          ? _value.deviceReadingId
          // ignore: cast_nullable_to_non_nullable
          : deviceReadingId as String?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
      correctsWeightRecordId:
          correctsWeightRecordId == const $CopyWithPlaceholder()
          ? _value.correctsWeightRecordId
          // ignore: cast_nullable_to_non_nullable
          : correctsWeightRecordId as String?,
      correctionReason: correctionReason == const $CopyWithPlaceholder()
          ? _value.correctionReason
          // ignore: cast_nullable_to_non_nullable
          : correctionReason as String?,
    );
  }
}

extension $WeightRecordCreateRequestCopyWith on WeightRecordCreateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfWeightRecordCreateRequest.copyWith(...)` or like so:`instanceOfWeightRecordCreateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeightRecordCreateRequestCWProxy get copyWith =>
      _$WeightRecordCreateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightRecordCreateRequest _$WeightRecordCreateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'WeightRecordCreateRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['weight_g', 'recorded_at', 'source']);
    final val = WeightRecordCreateRequest(
      hamsterId: $checkedConvert('hamster_id', (v) => v as String?),
      pupIdentityId: $checkedConvert('pup_identity_id', (v) => v as String?),
      litterId: $checkedConvert('litter_id', (v) => v as String?),
      measurementKind: $checkedConvert(
        'measurement_kind',
        (v) => $enumDecodeNullable(
          _$WeightRecordCreateRequestMeasurementKindEnumEnumMap,
          v,
        ),
      ),
      subjectCount: $checkedConvert(
        'subject_count',
        (v) => (v as num?)?.toInt(),
      ),
      weightG: $checkedConvert('weight_g', (v) => v as num),
      recordedAt: $checkedConvert(
        'recorded_at',
        (v) => DateTime.parse(v as String),
      ),
      source_: $checkedConvert(
        'source',
        (v) => $enumDecode(_$WeightRecordCreateRequestSource_EnumEnumMap, v),
      ),
      deviceReadingId: $checkedConvert(
        'device_reading_id',
        (v) => v as String?,
      ),
      notes: $checkedConvert('notes', (v) => v as String?),
      correctsWeightRecordId: $checkedConvert(
        'corrects_weight_record_id',
        (v) => v as String?,
      ),
      correctionReason: $checkedConvert(
        'correction_reason',
        (v) => v as String?,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'hamsterId': 'hamster_id',
    'pupIdentityId': 'pup_identity_id',
    'litterId': 'litter_id',
    'measurementKind': 'measurement_kind',
    'subjectCount': 'subject_count',
    'weightG': 'weight_g',
    'recordedAt': 'recorded_at',
    'source_': 'source',
    'deviceReadingId': 'device_reading_id',
    'correctsWeightRecordId': 'corrects_weight_record_id',
    'correctionReason': 'correction_reason',
  },
);

Map<String, dynamic> _$WeightRecordCreateRequestToJson(
  WeightRecordCreateRequest instance,
) => <String, dynamic>{
  'hamster_id': ?instance.hamsterId,
  'pup_identity_id': ?instance.pupIdentityId,
  'litter_id': ?instance.litterId,
  'measurement_kind':
      ?_$WeightRecordCreateRequestMeasurementKindEnumEnumMap[instance
          .measurementKind],
  'subject_count': ?instance.subjectCount,
  'weight_g': instance.weightG,
  'recorded_at': instance.recordedAt.toIso8601String(),
  'source': _$WeightRecordCreateRequestSource_EnumEnumMap[instance.source_]!,
  'device_reading_id': ?instance.deviceReadingId,
  'notes': ?instance.notes,
  'corrects_weight_record_id': ?instance.correctsWeightRecordId,
  'correction_reason': ?instance.correctionReason,
};

const _$WeightRecordCreateRequestMeasurementKindEnumEnumMap = {
  WeightRecordCreateRequestMeasurementKindEnum.individual: 'individual',
  WeightRecordCreateRequestMeasurementKindEnum.litterTotal: 'litter_total',
  WeightRecordCreateRequestMeasurementKindEnum.litterAverage: 'litter_average',
};

const _$WeightRecordCreateRequestSource_EnumEnumMap = {
  WeightRecordCreateRequestSource_Enum.manual: 'manual',
  WeightRecordCreateRequestSource_Enum.bluetoothScale: 'bluetooth_scale',
  WeightRecordCreateRequestSource_Enum.import_: 'import',
};
