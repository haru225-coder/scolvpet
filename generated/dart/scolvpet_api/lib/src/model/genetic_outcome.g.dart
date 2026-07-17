// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genetic_outcome.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GeneticOutcomeCWProxy {
  GeneticOutcome genotypeKey(String genotypeKey);

  GeneticOutcome genotype(Map<String, String> genotype);

  GeneticOutcome phenotypeLabel(String phenotypeLabel);

  GeneticOutcome phenotype(Map<String, String> phenotype);

  GeneticOutcome probability(double probability);

  GeneticOutcome countWeight(int countWeight);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeneticOutcome(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeneticOutcome(...).copyWith(id: 12, name: "My name")
  /// ````
  GeneticOutcome call({
    String genotypeKey,
    Map<String, String> genotype,
    String phenotypeLabel,
    Map<String, String> phenotype,
    double probability,
    int countWeight,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGeneticOutcome.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGeneticOutcome.copyWith.fieldName(...)`
class _$GeneticOutcomeCWProxyImpl implements _$GeneticOutcomeCWProxy {
  const _$GeneticOutcomeCWProxyImpl(this._value);

  final GeneticOutcome _value;

  @override
  GeneticOutcome genotypeKey(String genotypeKey) =>
      this(genotypeKey: genotypeKey);

  @override
  GeneticOutcome genotype(Map<String, String> genotype) =>
      this(genotype: genotype);

  @override
  GeneticOutcome phenotypeLabel(String phenotypeLabel) =>
      this(phenotypeLabel: phenotypeLabel);

  @override
  GeneticOutcome phenotype(Map<String, String> phenotype) =>
      this(phenotype: phenotype);

  @override
  GeneticOutcome probability(double probability) =>
      this(probability: probability);

  @override
  GeneticOutcome countWeight(int countWeight) => this(countWeight: countWeight);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeneticOutcome(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeneticOutcome(...).copyWith(id: 12, name: "My name")
  /// ````
  GeneticOutcome call({
    Object? genotypeKey = const $CopyWithPlaceholder(),
    Object? genotype = const $CopyWithPlaceholder(),
    Object? phenotypeLabel = const $CopyWithPlaceholder(),
    Object? phenotype = const $CopyWithPlaceholder(),
    Object? probability = const $CopyWithPlaceholder(),
    Object? countWeight = const $CopyWithPlaceholder(),
  }) {
    return GeneticOutcome(
      genotypeKey: genotypeKey == const $CopyWithPlaceholder()
          ? _value.genotypeKey
          // ignore: cast_nullable_to_non_nullable
          : genotypeKey as String,
      genotype: genotype == const $CopyWithPlaceholder()
          ? _value.genotype
          // ignore: cast_nullable_to_non_nullable
          : genotype as Map<String, String>,
      phenotypeLabel: phenotypeLabel == const $CopyWithPlaceholder()
          ? _value.phenotypeLabel
          // ignore: cast_nullable_to_non_nullable
          : phenotypeLabel as String,
      phenotype: phenotype == const $CopyWithPlaceholder()
          ? _value.phenotype
          // ignore: cast_nullable_to_non_nullable
          : phenotype as Map<String, String>,
      probability: probability == const $CopyWithPlaceholder()
          ? _value.probability
          // ignore: cast_nullable_to_non_nullable
          : probability as double,
      countWeight: countWeight == const $CopyWithPlaceholder()
          ? _value.countWeight
          // ignore: cast_nullable_to_non_nullable
          : countWeight as int,
    );
  }
}

extension $GeneticOutcomeCopyWith on GeneticOutcome {
  /// Returns a callable class that can be used as follows: `instanceOfGeneticOutcome.copyWith(...)` or like so:`instanceOfGeneticOutcome.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GeneticOutcomeCWProxy get copyWith => _$GeneticOutcomeCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneticOutcome _$GeneticOutcomeFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'GeneticOutcome',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'genotype_key',
        'genotype',
        'phenotype_label',
        'phenotype',
        'probability',
        'count_weight',
      ],
    );
    final val = GeneticOutcome(
      genotypeKey: $checkedConvert('genotype_key', (v) => v as String),
      genotype: $checkedConvert(
        'genotype',
        (v) => Map<String, String>.from(v as Map),
      ),
      phenotypeLabel: $checkedConvert('phenotype_label', (v) => v as String),
      phenotype: $checkedConvert(
        'phenotype',
        (v) => Map<String, String>.from(v as Map),
      ),
      probability: $checkedConvert('probability', (v) => (v as num).toDouble()),
      countWeight: $checkedConvert('count_weight', (v) => (v as num).toInt()),
    );
    return val;
  },
  fieldKeyMap: const {
    'genotypeKey': 'genotype_key',
    'phenotypeLabel': 'phenotype_label',
    'countWeight': 'count_weight',
  },
);

Map<String, dynamic> _$GeneticOutcomeToJson(GeneticOutcome instance) =>
    <String, dynamic>{
      'genotype_key': instance.genotypeKey,
      'genotype': instance.genotype,
      'phenotype_label': instance.phenotypeLabel,
      'phenotype': instance.phenotype,
      'probability': instance.probability,
      'count_weight': instance.countWeight,
    };
