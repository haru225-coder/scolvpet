// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hamster_update_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HamsterUpdateRequestCWProxy {
  HamsterUpdateRequest internalCode(String? internalCode);

  HamsterUpdateRequest name(String? name);

  HamsterUpdateRequest varietyCode(String? varietyCode);

  HamsterUpdateRequest sex(Sex? sex);

  HamsterUpdateRequest sexConfidence(num? sexConfidence);

  HamsterUpdateRequest birthDate(DateTime? birthDate);

  HamsterUpdateRequest coverMediaId(String? coverMediaId);

  HamsterUpdateRequest notes(String? notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HamsterUpdateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HamsterUpdateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  HamsterUpdateRequest call({
    String? internalCode,
    String? name,
    String? varietyCode,
    Sex? sex,
    num? sexConfidence,
    DateTime? birthDate,
    String? coverMediaId,
    String? notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHamsterUpdateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHamsterUpdateRequest.copyWith.fieldName(...)`
class _$HamsterUpdateRequestCWProxyImpl
    implements _$HamsterUpdateRequestCWProxy {
  const _$HamsterUpdateRequestCWProxyImpl(this._value);

  final HamsterUpdateRequest _value;

  @override
  HamsterUpdateRequest internalCode(String? internalCode) =>
      this(internalCode: internalCode);

  @override
  HamsterUpdateRequest name(String? name) => this(name: name);

  @override
  HamsterUpdateRequest varietyCode(String? varietyCode) =>
      this(varietyCode: varietyCode);

  @override
  HamsterUpdateRequest sex(Sex? sex) => this(sex: sex);

  @override
  HamsterUpdateRequest sexConfidence(num? sexConfidence) =>
      this(sexConfidence: sexConfidence);

  @override
  HamsterUpdateRequest birthDate(DateTime? birthDate) =>
      this(birthDate: birthDate);

  @override
  HamsterUpdateRequest coverMediaId(String? coverMediaId) =>
      this(coverMediaId: coverMediaId);

  @override
  HamsterUpdateRequest notes(String? notes) => this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HamsterUpdateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HamsterUpdateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  HamsterUpdateRequest call({
    Object? internalCode = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? varietyCode = const $CopyWithPlaceholder(),
    Object? sex = const $CopyWithPlaceholder(),
    Object? sexConfidence = const $CopyWithPlaceholder(),
    Object? birthDate = const $CopyWithPlaceholder(),
    Object? coverMediaId = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return HamsterUpdateRequest(
      internalCode: internalCode == const $CopyWithPlaceholder()
          ? _value.internalCode
          // ignore: cast_nullable_to_non_nullable
          : internalCode as String?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      varietyCode: varietyCode == const $CopyWithPlaceholder()
          ? _value.varietyCode
          // ignore: cast_nullable_to_non_nullable
          : varietyCode as String?,
      sex: sex == const $CopyWithPlaceholder()
          ? _value.sex
          // ignore: cast_nullable_to_non_nullable
          : sex as Sex?,
      sexConfidence: sexConfidence == const $CopyWithPlaceholder()
          ? _value.sexConfidence
          // ignore: cast_nullable_to_non_nullable
          : sexConfidence as num?,
      birthDate: birthDate == const $CopyWithPlaceholder()
          ? _value.birthDate
          // ignore: cast_nullable_to_non_nullable
          : birthDate as DateTime?,
      coverMediaId: coverMediaId == const $CopyWithPlaceholder()
          ? _value.coverMediaId
          // ignore: cast_nullable_to_non_nullable
          : coverMediaId as String?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
    );
  }
}

extension $HamsterUpdateRequestCopyWith on HamsterUpdateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfHamsterUpdateRequest.copyWith(...)` or like so:`instanceOfHamsterUpdateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HamsterUpdateRequestCWProxy get copyWith =>
      _$HamsterUpdateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HamsterUpdateRequest _$HamsterUpdateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'HamsterUpdateRequest',
  json,
  ($checkedConvert) {
    final val = HamsterUpdateRequest(
      internalCode: $checkedConvert('internal_code', (v) => v as String?),
      name: $checkedConvert('name', (v) => v as String?),
      varietyCode: $checkedConvert('variety_code', (v) => v as String?),
      sex: $checkedConvert('sex', (v) => $enumDecodeNullable(_$SexEnumMap, v)),
      sexConfidence: $checkedConvert('sex_confidence', (v) => v as num?),
      birthDate: $checkedConvert(
        'birth_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      coverMediaId: $checkedConvert('cover_media_id', (v) => v as String?),
      notes: $checkedConvert('notes', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'internalCode': 'internal_code',
    'varietyCode': 'variety_code',
    'sexConfidence': 'sex_confidence',
    'birthDate': 'birth_date',
    'coverMediaId': 'cover_media_id',
  },
);

Map<String, dynamic> _$HamsterUpdateRequestToJson(
  HamsterUpdateRequest instance,
) => <String, dynamic>{
  'internal_code': ?instance.internalCode,
  'name': ?instance.name,
  'variety_code': ?instance.varietyCode,
  'sex': ?_$SexEnumMap[instance.sex],
  'sex_confidence': ?instance.sexConfidence,
  'birth_date': ?instance.birthDate?.toIso8601String(),
  'cover_media_id': ?instance.coverMediaId,
  'notes': ?instance.notes,
};

const _$SexEnumMap = {
  Sex.male: 'male',
  Sex.female: 'female',
  Sex.unknown: 'unknown',
};
