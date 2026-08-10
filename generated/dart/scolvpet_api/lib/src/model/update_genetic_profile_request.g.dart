// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_genetic_profile_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpdateGeneticProfileRequestCWProxy {
  UpdateGeneticProfileRequest name(String? name);

  UpdateGeneticProfileRequest notes(String? notes);

  UpdateGeneticProfileRequest confidence(
    UpdateGeneticProfileRequestConfidenceEnum? confidence,
  );

  UpdateGeneticProfileRequest phenotype(Map<String, Object>? phenotype);

  UpdateGeneticProfileRequest genotype(Map<String, String>? genotype);

  UpdateGeneticProfileRequest version(int version);

  UpdateGeneticProfileRequest hamsterId(String? hamsterId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateGeneticProfileRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateGeneticProfileRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateGeneticProfileRequest call({
    String? name,
    String? notes,
    UpdateGeneticProfileRequestConfidenceEnum? confidence,
    Map<String, Object>? phenotype,
    Map<String, String>? genotype,
    int version,
    String? hamsterId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpdateGeneticProfileRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpdateGeneticProfileRequest.copyWith.fieldName(...)`
class _$UpdateGeneticProfileRequestCWProxyImpl
    implements _$UpdateGeneticProfileRequestCWProxy {
  const _$UpdateGeneticProfileRequestCWProxyImpl(this._value);

  final UpdateGeneticProfileRequest _value;

  @override
  UpdateGeneticProfileRequest name(String? name) => this(name: name);

  @override
  UpdateGeneticProfileRequest notes(String? notes) => this(notes: notes);

  @override
  UpdateGeneticProfileRequest confidence(
    UpdateGeneticProfileRequestConfidenceEnum? confidence,
  ) => this(confidence: confidence);

  @override
  UpdateGeneticProfileRequest phenotype(Map<String, Object>? phenotype) =>
      this(phenotype: phenotype);

  @override
  UpdateGeneticProfileRequest genotype(Map<String, String>? genotype) =>
      this(genotype: genotype);

  @override
  UpdateGeneticProfileRequest version(int version) => this(version: version);

  @override
  UpdateGeneticProfileRequest hamsterId(String? hamsterId) =>
      this(hamsterId: hamsterId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateGeneticProfileRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateGeneticProfileRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateGeneticProfileRequest call({
    Object? name = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? confidence = const $CopyWithPlaceholder(),
    Object? phenotype = const $CopyWithPlaceholder(),
    Object? genotype = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? hamsterId = const $CopyWithPlaceholder(),
  }) {
    return UpdateGeneticProfileRequest(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
      confidence: confidence == const $CopyWithPlaceholder()
          ? _value.confidence
          // ignore: cast_nullable_to_non_nullable
          : confidence as UpdateGeneticProfileRequestConfidenceEnum?,
      phenotype: phenotype == const $CopyWithPlaceholder()
          ? _value.phenotype
          // ignore: cast_nullable_to_non_nullable
          : phenotype as Map<String, Object>?,
      genotype: genotype == const $CopyWithPlaceholder()
          ? _value.genotype
          // ignore: cast_nullable_to_non_nullable
          : genotype as Map<String, String>?,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
      hamsterId: hamsterId == const $CopyWithPlaceholder()
          ? _value.hamsterId
          // ignore: cast_nullable_to_non_nullable
          : hamsterId as String?,
    );
  }
}

extension $UpdateGeneticProfileRequestCopyWith on UpdateGeneticProfileRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUpdateGeneticProfileRequest.copyWith(...)` or like so:`instanceOfUpdateGeneticProfileRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpdateGeneticProfileRequestCWProxy get copyWith =>
      _$UpdateGeneticProfileRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateGeneticProfileRequest _$UpdateGeneticProfileRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UpdateGeneticProfileRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['version']);
  final val = UpdateGeneticProfileRequest(
    name: $checkedConvert('name', (v) => v as String?),
    notes: $checkedConvert('notes', (v) => v as String?),
    confidence: $checkedConvert(
      'confidence',
      (v) => $enumDecodeNullable(
        _$UpdateGeneticProfileRequestConfidenceEnumEnumMap,
        v,
      ),
    ),
    phenotype: $checkedConvert(
      'phenotype',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
    genotype: $checkedConvert(
      'genotype',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as String)),
    ),
    version: $checkedConvert('version', (v) => (v as num).toInt()),
    hamsterId: $checkedConvert('hamster_id', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {'hamsterId': 'hamster_id'});

Map<String, dynamic> _$UpdateGeneticProfileRequestToJson(
  UpdateGeneticProfileRequest instance,
) => <String, dynamic>{
  'name': ?instance.name,
  'notes': ?instance.notes,
  'confidence':
      ?_$UpdateGeneticProfileRequestConfidenceEnumEnumMap[instance.confidence],
  'phenotype': ?instance.phenotype,
  'genotype': ?instance.genotype,
  'version': instance.version,
  'hamster_id': ?instance.hamsterId,
};

const _$UpdateGeneticProfileRequestConfidenceEnumEnumMap = {
  UpdateGeneticProfileRequestConfidenceEnum.observed: 'observed',
  UpdateGeneticProfileRequestConfidenceEnum.inferred: 'inferred',
  UpdateGeneticProfileRequestConfidenceEnum.unknown: 'unknown',
};
