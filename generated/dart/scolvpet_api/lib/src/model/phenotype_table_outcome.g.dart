// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phenotype_table_outcome.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PhenotypeTableOutcomeCWProxy {
  PhenotypeTableOutcome phenotype(String phenotype);

  PhenotypeTableOutcome probability(double probability);

  PhenotypeTableOutcome fraction(String? fraction);

  PhenotypeTableOutcome note(String? note);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PhenotypeTableOutcome(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PhenotypeTableOutcome(...).copyWith(id: 12, name: "My name")
  /// ````
  PhenotypeTableOutcome call({
    String phenotype,
    double probability,
    String? fraction,
    String? note,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPhenotypeTableOutcome.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPhenotypeTableOutcome.copyWith.fieldName(...)`
class _$PhenotypeTableOutcomeCWProxyImpl
    implements _$PhenotypeTableOutcomeCWProxy {
  const _$PhenotypeTableOutcomeCWProxyImpl(this._value);

  final PhenotypeTableOutcome _value;

  @override
  PhenotypeTableOutcome phenotype(String phenotype) =>
      this(phenotype: phenotype);

  @override
  PhenotypeTableOutcome probability(double probability) =>
      this(probability: probability);

  @override
  PhenotypeTableOutcome fraction(String? fraction) => this(fraction: fraction);

  @override
  PhenotypeTableOutcome note(String? note) => this(note: note);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PhenotypeTableOutcome(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PhenotypeTableOutcome(...).copyWith(id: 12, name: "My name")
  /// ````
  PhenotypeTableOutcome call({
    Object? phenotype = const $CopyWithPlaceholder(),
    Object? probability = const $CopyWithPlaceholder(),
    Object? fraction = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
  }) {
    return PhenotypeTableOutcome(
      phenotype: phenotype == const $CopyWithPlaceholder()
          ? _value.phenotype
          // ignore: cast_nullable_to_non_nullable
          : phenotype as String,
      probability: probability == const $CopyWithPlaceholder()
          ? _value.probability
          // ignore: cast_nullable_to_non_nullable
          : probability as double,
      fraction: fraction == const $CopyWithPlaceholder()
          ? _value.fraction
          // ignore: cast_nullable_to_non_nullable
          : fraction as String?,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
    );
  }
}

extension $PhenotypeTableOutcomeCopyWith on PhenotypeTableOutcome {
  /// Returns a callable class that can be used as follows: `instanceOfPhenotypeTableOutcome.copyWith(...)` or like so:`instanceOfPhenotypeTableOutcome.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PhenotypeTableOutcomeCWProxy get copyWith =>
      _$PhenotypeTableOutcomeCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhenotypeTableOutcome _$PhenotypeTableOutcomeFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PhenotypeTableOutcome', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['phenotype', 'probability']);
  final val = PhenotypeTableOutcome(
    phenotype: $checkedConvert('phenotype', (v) => v as String),
    probability: $checkedConvert('probability', (v) => (v as num).toDouble()),
    fraction: $checkedConvert('fraction', (v) => v as String?),
    note: $checkedConvert('note', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$PhenotypeTableOutcomeToJson(
  PhenotypeTableOutcome instance,
) => <String, dynamic>{
  'phenotype': instance.phenotype,
  'probability': instance.probability,
  'fraction': ?instance.fraction,
  'note': ?instance.note,
};
