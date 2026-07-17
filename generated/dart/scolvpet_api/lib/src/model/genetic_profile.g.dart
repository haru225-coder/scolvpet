// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genetic_profile.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GeneticProfileCWProxy {
  GeneticProfile id(String id);

  GeneticProfile hamsterId(String? hamsterId);

  GeneticProfile name(String name);

  GeneticProfile phenotype(Map<String, Object> phenotype);

  GeneticProfile genotype(Map<String, String> genotype);

  GeneticProfile confidence(GeneticProfileConfidenceEnum confidence);

  GeneticProfile notes(String? notes);

  GeneticProfile version(int version);

  GeneticProfile updatedAt(DateTime updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeneticProfile(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeneticProfile(...).copyWith(id: 12, name: "My name")
  /// ````
  GeneticProfile call({
    String id,
    String? hamsterId,
    String name,
    Map<String, Object> phenotype,
    Map<String, String> genotype,
    GeneticProfileConfidenceEnum confidence,
    String? notes,
    int version,
    DateTime updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGeneticProfile.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGeneticProfile.copyWith.fieldName(...)`
class _$GeneticProfileCWProxyImpl implements _$GeneticProfileCWProxy {
  const _$GeneticProfileCWProxyImpl(this._value);

  final GeneticProfile _value;

  @override
  GeneticProfile id(String id) => this(id: id);

  @override
  GeneticProfile hamsterId(String? hamsterId) => this(hamsterId: hamsterId);

  @override
  GeneticProfile name(String name) => this(name: name);

  @override
  GeneticProfile phenotype(Map<String, Object> phenotype) =>
      this(phenotype: phenotype);

  @override
  GeneticProfile genotype(Map<String, String> genotype) =>
      this(genotype: genotype);

  @override
  GeneticProfile confidence(GeneticProfileConfidenceEnum confidence) =>
      this(confidence: confidence);

  @override
  GeneticProfile notes(String? notes) => this(notes: notes);

  @override
  GeneticProfile version(int version) => this(version: version);

  @override
  GeneticProfile updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeneticProfile(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeneticProfile(...).copyWith(id: 12, name: "My name")
  /// ````
  GeneticProfile call({
    Object? id = const $CopyWithPlaceholder(),
    Object? hamsterId = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? phenotype = const $CopyWithPlaceholder(),
    Object? genotype = const $CopyWithPlaceholder(),
    Object? confidence = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return GeneticProfile(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
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
          : phenotype as Map<String, Object>,
      genotype: genotype == const $CopyWithPlaceholder()
          ? _value.genotype
          // ignore: cast_nullable_to_non_nullable
          : genotype as Map<String, String>,
      confidence: confidence == const $CopyWithPlaceholder()
          ? _value.confidence
          // ignore: cast_nullable_to_non_nullable
          : confidence as GeneticProfileConfidenceEnum,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
    );
  }
}

extension $GeneticProfileCopyWith on GeneticProfile {
  /// Returns a callable class that can be used as follows: `instanceOfGeneticProfile.copyWith(...)` or like so:`instanceOfGeneticProfile.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GeneticProfileCWProxy get copyWith => _$GeneticProfileCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneticProfile _$GeneticProfileFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'GeneticProfile',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'name',
            'phenotype',
            'genotype',
            'confidence',
            'version',
            'updated_at',
          ],
        );
        final val = GeneticProfile(
          id: $checkedConvert('id', (v) => v as String),
          hamsterId: $checkedConvert('hamster_id', (v) => v as String?),
          name: $checkedConvert('name', (v) => v as String),
          phenotype: $checkedConvert(
            'phenotype',
            (v) => (v as Map<String, dynamic>).map(
              (k, e) => MapEntry(k, e as Object),
            ),
          ),
          genotype: $checkedConvert(
            'genotype',
            (v) => Map<String, String>.from(v as Map),
          ),
          confidence: $checkedConvert(
            'confidence',
            (v) => $enumDecode(_$GeneticProfileConfidenceEnumEnumMap, v),
          ),
          notes: $checkedConvert('notes', (v) => v as String?),
          version: $checkedConvert('version', (v) => (v as num).toInt()),
          updatedAt: $checkedConvert(
            'updated_at',
            (v) => DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {'hamsterId': 'hamster_id', 'updatedAt': 'updated_at'},
    );

Map<String, dynamic> _$GeneticProfileToJson(GeneticProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hamster_id': ?instance.hamsterId,
      'name': instance.name,
      'phenotype': instance.phenotype,
      'genotype': instance.genotype,
      'confidence': _$GeneticProfileConfidenceEnumEnumMap[instance.confidence]!,
      'notes': ?instance.notes,
      'version': instance.version,
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$GeneticProfileConfidenceEnumEnumMap = {
  GeneticProfileConfidenceEnum.observed: 'observed',
  GeneticProfileConfidenceEnum.inferred: 'inferred',
  GeneticProfileConfidenceEnum.unknown: 'unknown',
};
