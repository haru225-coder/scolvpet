// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genetic_simulation_result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GeneticSimulationResultCWProxy {
  GeneticSimulationResult sire(Map<String, String> sire);

  GeneticSimulationResult dam(Map<String, String> dam);

  GeneticSimulationResult outcomes(List<GeneticOutcome> outcomes);

  GeneticSimulationResult notes(String notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeneticSimulationResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeneticSimulationResult(...).copyWith(id: 12, name: "My name")
  /// ````
  GeneticSimulationResult call({
    Map<String, String> sire,
    Map<String, String> dam,
    List<GeneticOutcome> outcomes,
    String notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGeneticSimulationResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGeneticSimulationResult.copyWith.fieldName(...)`
class _$GeneticSimulationResultCWProxyImpl
    implements _$GeneticSimulationResultCWProxy {
  const _$GeneticSimulationResultCWProxyImpl(this._value);

  final GeneticSimulationResult _value;

  @override
  GeneticSimulationResult sire(Map<String, String> sire) => this(sire: sire);

  @override
  GeneticSimulationResult dam(Map<String, String> dam) => this(dam: dam);

  @override
  GeneticSimulationResult outcomes(List<GeneticOutcome> outcomes) =>
      this(outcomes: outcomes);

  @override
  GeneticSimulationResult notes(String notes) => this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeneticSimulationResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeneticSimulationResult(...).copyWith(id: 12, name: "My name")
  /// ````
  GeneticSimulationResult call({
    Object? sire = const $CopyWithPlaceholder(),
    Object? dam = const $CopyWithPlaceholder(),
    Object? outcomes = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return GeneticSimulationResult(
      sire: sire == const $CopyWithPlaceholder()
          ? _value.sire
          // ignore: cast_nullable_to_non_nullable
          : sire as Map<String, String>,
      dam: dam == const $CopyWithPlaceholder()
          ? _value.dam
          // ignore: cast_nullable_to_non_nullable
          : dam as Map<String, String>,
      outcomes: outcomes == const $CopyWithPlaceholder()
          ? _value.outcomes
          // ignore: cast_nullable_to_non_nullable
          : outcomes as List<GeneticOutcome>,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String,
    );
  }
}

extension $GeneticSimulationResultCopyWith on GeneticSimulationResult {
  /// Returns a callable class that can be used as follows: `instanceOfGeneticSimulationResult.copyWith(...)` or like so:`instanceOfGeneticSimulationResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GeneticSimulationResultCWProxy get copyWith =>
      _$GeneticSimulationResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneticSimulationResult _$GeneticSimulationResultFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('GeneticSimulationResult', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['sire', 'dam', 'outcomes', 'notes']);
  final val = GeneticSimulationResult(
    sire: $checkedConvert('sire', (v) => Map<String, String>.from(v as Map)),
    dam: $checkedConvert('dam', (v) => Map<String, String>.from(v as Map)),
    outcomes: $checkedConvert(
      'outcomes',
      (v) => (v as List<dynamic>)
          .map((e) => GeneticOutcome.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    notes: $checkedConvert('notes', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$GeneticSimulationResultToJson(
  GeneticSimulationResult instance,
) => <String, dynamic>{
  'sire': instance.sire,
  'dam': instance.dam,
  'outcomes': instance.outcomes.map((e) => e.toJson()).toList(),
  'notes': instance.notes,
};
