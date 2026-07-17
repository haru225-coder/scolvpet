// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genetic_simulation_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GeneticSimulationRequestCWProxy {
  GeneticSimulationRequest sire(Map<String, String> sire);

  GeneticSimulationRequest dam(Map<String, String> dam);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeneticSimulationRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeneticSimulationRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  GeneticSimulationRequest call({
    Map<String, String> sire,
    Map<String, String> dam,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGeneticSimulationRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGeneticSimulationRequest.copyWith.fieldName(...)`
class _$GeneticSimulationRequestCWProxyImpl
    implements _$GeneticSimulationRequestCWProxy {
  const _$GeneticSimulationRequestCWProxyImpl(this._value);

  final GeneticSimulationRequest _value;

  @override
  GeneticSimulationRequest sire(Map<String, String> sire) => this(sire: sire);

  @override
  GeneticSimulationRequest dam(Map<String, String> dam) => this(dam: dam);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeneticSimulationRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeneticSimulationRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  GeneticSimulationRequest call({
    Object? sire = const $CopyWithPlaceholder(),
    Object? dam = const $CopyWithPlaceholder(),
  }) {
    return GeneticSimulationRequest(
      sire: sire == const $CopyWithPlaceholder()
          ? _value.sire
          // ignore: cast_nullable_to_non_nullable
          : sire as Map<String, String>,
      dam: dam == const $CopyWithPlaceholder()
          ? _value.dam
          // ignore: cast_nullable_to_non_nullable
          : dam as Map<String, String>,
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
) => $checkedCreate('GeneticSimulationRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['sire', 'dam']);
  final val = GeneticSimulationRequest(
    sire: $checkedConvert('sire', (v) => Map<String, String>.from(v as Map)),
    dam: $checkedConvert('dam', (v) => Map<String, String>.from(v as Map)),
  );
  return val;
});

Map<String, dynamic> _$GeneticSimulationRequestToJson(
  GeneticSimulationRequest instance,
) => <String, dynamic>{'sire': instance.sire, 'dam': instance.dam};
