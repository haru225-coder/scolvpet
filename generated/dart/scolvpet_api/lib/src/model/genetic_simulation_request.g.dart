// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genetic_simulation_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GeneticSimulationRequestCWProxy {
  GeneticSimulationRequest mode(GeneticSimulationRequestModeEnum? mode);

  GeneticSimulationRequest series(String? series);

  GeneticSimulationRequest sirePhenotype(String? sirePhenotype);

  GeneticSimulationRequest damPhenotype(String? damPhenotype);

  GeneticSimulationRequest sireGenotypeKey(String? sireGenotypeKey);

  GeneticSimulationRequest damGenotypeKey(String? damGenotypeKey);

  GeneticSimulationRequest sireHamsterId(String? sireHamsterId);

  GeneticSimulationRequest damHamsterId(String? damHamsterId);

  GeneticSimulationRequest targetPhenotype(String? targetPhenotype);

  GeneticSimulationRequest sire(Map<String, String>? sire);

  GeneticSimulationRequest dam(Map<String, String>? dam);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeneticSimulationRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeneticSimulationRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  GeneticSimulationRequest call({
    GeneticSimulationRequestModeEnum? mode,
    String? series,
    String? sirePhenotype,
    String? damPhenotype,
    String? sireGenotypeKey,
    String? damGenotypeKey,
    String? sireHamsterId,
    String? damHamsterId,
    String? targetPhenotype,
    Map<String, String>? sire,
    Map<String, String>? dam,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGeneticSimulationRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGeneticSimulationRequest.copyWith.fieldName(...)`
class _$GeneticSimulationRequestCWProxyImpl
    implements _$GeneticSimulationRequestCWProxy {
  const _$GeneticSimulationRequestCWProxyImpl(this._value);

  final GeneticSimulationRequest _value;

  @override
  GeneticSimulationRequest mode(GeneticSimulationRequestModeEnum? mode) =>
      this(mode: mode);

  @override
  GeneticSimulationRequest series(String? series) => this(series: series);

  @override
  GeneticSimulationRequest sirePhenotype(String? sirePhenotype) =>
      this(sirePhenotype: sirePhenotype);

  @override
  GeneticSimulationRequest damPhenotype(String? damPhenotype) =>
      this(damPhenotype: damPhenotype);

  @override
  GeneticSimulationRequest sireGenotypeKey(String? sireGenotypeKey) =>
      this(sireGenotypeKey: sireGenotypeKey);

  @override
  GeneticSimulationRequest damGenotypeKey(String? damGenotypeKey) =>
      this(damGenotypeKey: damGenotypeKey);

  @override
  GeneticSimulationRequest sireHamsterId(String? sireHamsterId) =>
      this(sireHamsterId: sireHamsterId);

  @override
  GeneticSimulationRequest damHamsterId(String? damHamsterId) =>
      this(damHamsterId: damHamsterId);

  @override
  GeneticSimulationRequest targetPhenotype(String? targetPhenotype) =>
      this(targetPhenotype: targetPhenotype);

  @override
  GeneticSimulationRequest sire(Map<String, String>? sire) => this(sire: sire);

  @override
  GeneticSimulationRequest dam(Map<String, String>? dam) => this(dam: dam);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeneticSimulationRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeneticSimulationRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  GeneticSimulationRequest call({
    Object? mode = const $CopyWithPlaceholder(),
    Object? series = const $CopyWithPlaceholder(),
    Object? sirePhenotype = const $CopyWithPlaceholder(),
    Object? damPhenotype = const $CopyWithPlaceholder(),
    Object? sireGenotypeKey = const $CopyWithPlaceholder(),
    Object? damGenotypeKey = const $CopyWithPlaceholder(),
    Object? sireHamsterId = const $CopyWithPlaceholder(),
    Object? damHamsterId = const $CopyWithPlaceholder(),
    Object? targetPhenotype = const $CopyWithPlaceholder(),
    Object? sire = const $CopyWithPlaceholder(),
    Object? dam = const $CopyWithPlaceholder(),
  }) {
    return GeneticSimulationRequest(
      mode: mode == const $CopyWithPlaceholder()
          ? _value.mode
          // ignore: cast_nullable_to_non_nullable
          : mode as GeneticSimulationRequestModeEnum?,
      series: series == const $CopyWithPlaceholder()
          ? _value.series
          // ignore: cast_nullable_to_non_nullable
          : series as String?,
      sirePhenotype: sirePhenotype == const $CopyWithPlaceholder()
          ? _value.sirePhenotype
          // ignore: cast_nullable_to_non_nullable
          : sirePhenotype as String?,
      damPhenotype: damPhenotype == const $CopyWithPlaceholder()
          ? _value.damPhenotype
          // ignore: cast_nullable_to_non_nullable
          : damPhenotype as String?,
      sireGenotypeKey: sireGenotypeKey == const $CopyWithPlaceholder()
          ? _value.sireGenotypeKey
          // ignore: cast_nullable_to_non_nullable
          : sireGenotypeKey as String?,
      damGenotypeKey: damGenotypeKey == const $CopyWithPlaceholder()
          ? _value.damGenotypeKey
          // ignore: cast_nullable_to_non_nullable
          : damGenotypeKey as String?,
      sireHamsterId: sireHamsterId == const $CopyWithPlaceholder()
          ? _value.sireHamsterId
          // ignore: cast_nullable_to_non_nullable
          : sireHamsterId as String?,
      damHamsterId: damHamsterId == const $CopyWithPlaceholder()
          ? _value.damHamsterId
          // ignore: cast_nullable_to_non_nullable
          : damHamsterId as String?,
      targetPhenotype: targetPhenotype == const $CopyWithPlaceholder()
          ? _value.targetPhenotype
          // ignore: cast_nullable_to_non_nullable
          : targetPhenotype as String?,
      sire: sire == const $CopyWithPlaceholder()
          ? _value.sire
          // ignore: cast_nullable_to_non_nullable
          : sire as Map<String, String>?,
      dam: dam == const $CopyWithPlaceholder()
          ? _value.dam
          // ignore: cast_nullable_to_non_nullable
          : dam as Map<String, String>?,
    );
  }
}

extension $GeneticSimulationRequestCopyWith on GeneticSimulationRequest {
  /// Returns a callable class that can be used as follows: `instanceOfGeneticSimulationRequest.copyWith(...)` or like so:`instanceOfGeneticSimulationRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GeneticSimulationRequestCWProxy get copyWith =>
      _$GeneticSimulationRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneticSimulationRequest _$GeneticSimulationRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'GeneticSimulationRequest',
  json,
  ($checkedConvert) {
    final val = GeneticSimulationRequest(
      mode: $checkedConvert(
        'mode',
        (v) =>
            $enumDecodeNullable(_$GeneticSimulationRequestModeEnumEnumMap, v),
      ),
      series: $checkedConvert('series', (v) => v as String?),
      sirePhenotype: $checkedConvert('sire_phenotype', (v) => v as String?),
      damPhenotype: $checkedConvert('dam_phenotype', (v) => v as String?),
      sireGenotypeKey: $checkedConvert(
        'sire_genotype_key',
        (v) => v as String?,
      ),
      damGenotypeKey: $checkedConvert('dam_genotype_key', (v) => v as String?),
      sireHamsterId: $checkedConvert('sire_hamster_id', (v) => v as String?),
      damHamsterId: $checkedConvert('dam_hamster_id', (v) => v as String?),
      targetPhenotype: $checkedConvert('target_phenotype', (v) => v as String?),
      sire: $checkedConvert(
        'sire',
        (v) => (v as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, e as String),
        ),
      ),
      dam: $checkedConvert(
        'dam',
        (v) => (v as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, e as String),
        ),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'sirePhenotype': 'sire_phenotype',
    'damPhenotype': 'dam_phenotype',
    'sireGenotypeKey': 'sire_genotype_key',
    'damGenotypeKey': 'dam_genotype_key',
    'sireHamsterId': 'sire_hamster_id',
    'damHamsterId': 'dam_hamster_id',
    'targetPhenotype': 'target_phenotype',
  },
);

Map<String, dynamic> _$GeneticSimulationRequestToJson(
  GeneticSimulationRequest instance,
) => <String, dynamic>{
  'mode': ?_$GeneticSimulationRequestModeEnumEnumMap[instance.mode],
  'series': ?instance.series,
  'sire_phenotype': ?instance.sirePhenotype,
  'dam_phenotype': ?instance.damPhenotype,
  'sire_genotype_key': ?instance.sireGenotypeKey,
  'dam_genotype_key': ?instance.damGenotypeKey,
  'sire_hamster_id': ?instance.sireHamsterId,
  'dam_hamster_id': ?instance.damHamsterId,
  'target_phenotype': ?instance.targetPhenotype,
  'sire': ?instance.sire,
  'dam': ?instance.dam,
};

const _$GeneticSimulationRequestModeEnumEnumMap = {
  GeneticSimulationRequestModeEnum.phenotypeTable: 'phenotype_table',
  GeneticSimulationRequestModeEnum.mendel: 'mendel',
};
