// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_genetic_profile_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateGeneticProfileRequestCWProxy {
  CreateGeneticProfileRequest hamsterId(String? hamsterId);

  CreateGeneticProfileRequest name(String name);

  CreateGeneticProfileRequest phenotype(Map<String, Object>? phenotype);

  CreateGeneticProfileRequest genotype(Map<String, String>? genotype);

  CreateGeneticProfileRequest confidence(
    CreateGeneticProfileRequestConfidenceEnum? confidence,
  );

  CreateGeneticProfileRequest notes(String? notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateGeneticProfileRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateGeneticProfileRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateGeneticProfileRequest call({
    String? hamsterId,
    String name,
    Map<String, Object>? phenotype,
    Map<String, String>? genotype,
    CreateGeneticProfileRequestConfidenceEnum? confidence,
    String? notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateGeneticProfileRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateGeneticProfileRequest.copyWith.fieldName(...)`
class _$CreateGeneticProfileRequestCWProxyImpl
    implements _$CreateGeneticProfileRequestCWProxy {
  const _$CreateGeneticProfileRequestCWProxyImpl(this._value);

  final CreateGeneticProfileRequest _value;

  @override
  CreateGeneticProfileRequest hamsterId(String? hamsterId) =>
      this(hamsterId: hamsterId);

  @override
  CreateGeneticProfileRequest name(String name) => this(name: name);

  @override
  CreateGeneticProfileRequest phenotype(Map<String, Object>? phenotype) =>
      this(phenotype: phenotype);

  @override
  CreateGeneticProfileRequest genotype(Map<String, String>? genotype) =>
      this(genotype: genotype);

  @override
  CreateGeneticProfileRequest confidence(
    CreateGeneticProfileRequestConfidenceEnum? confidence,
  ) => this(confidence: confidence);

  @override
  CreateGeneticProfileRequest notes(String? notes) => this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateGeneticProfileRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateGeneticProfileRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateGeneticProfileRequest call({
    Object? hamsterId = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? phenotype = const $CopyWithPlaceholder(),
    Object? genotype = const $CopyWithPlaceholder(),
    Object? confidence = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return CreateGeneticProfileRequest(
      hamsterId: hamsterId == const $CopyWithPlaceholder()
          ? _value.hamsterId
          // ignore: cast_nullable_to_non_nullable
          : hamsterId as String?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      phenotype: phenotype == const $CopyWithPlaceholder()
          ? _value.phenotype
          // ignore: cast_nullable_to_non_nullable
          : phenotype as Map<String, Object>?,
      genotype: genotype == const $CopyWithPlaceholder()
          ? _value.genotype
          // ignore: cast_nullable_to_non_nullable
          : genotype as Map<String, String>?,
      confidence: confidence == const $CopyWithPlaceholder()
          ? _value.confidence
          // ignore: cast_nullable_to_non_nullable
          : confidence as CreateGeneticProfileRequestConfidenceEnum?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
    );
  }
}

extension $CreateGeneticProfileRequestCopyWith on CreateGeneticProfileRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateGeneticProfileRequest.copyWith(...)` or like so:`instanceOfCreateGeneticProfileRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateGeneticProfileRequestCWProxy get copyWith =>
      _$CreateGeneticProfileRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateGeneticProfileRequest _$CreateGeneticProfileRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateGeneticProfileRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['name']);
  final val = CreateGeneticProfileRequest(
    hamsterId: $checkedConvert('hamster_id', (v) => v as String?),
    name: $checkedConvert('name', (v) => v as String),
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
    confidence: $checkedConvert(
      'confidence',
      (v) =>
          $enumDecodeNullable(
            _$CreateGeneticProfileRequestConfidenceEnumEnumMap,
            v,
          ) ??
          CreateGeneticProfileRequestConfidenceEnum.unknown,
    ),
    notes: $checkedConvert('notes', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {'hamsterId': 'hamster_id'});

Map<String, dynamic> _$CreateGeneticProfileRequestToJson(
  CreateGeneticProfileRequest instance,
) => <String, dynamic>{
  'hamster_id': ?instance.hamsterId,
  'name': instance.name,
  'phenotype': ?instance.phenotype,
  'genotype': ?instance.genotype,
  'confidence':
      ?_$CreateGeneticProfileRequestConfidenceEnumEnumMap[instance.confidence],
  'notes': ?instance.notes,
};

const _$CreateGeneticProfileRequestConfidenceEnumEnumMap = {
  CreateGeneticProfileRequestConfidenceEnum.observed: 'observed',
  CreateGeneticProfileRequestConfidenceEnum.inferred: 'inferred',
  CreateGeneticProfileRequestConfidenceEnum.unknown: 'unknown',
};
