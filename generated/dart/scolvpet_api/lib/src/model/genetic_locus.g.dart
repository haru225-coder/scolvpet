// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genetic_locus.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GeneticLocusCWProxy {
  GeneticLocus code(String code);

  GeneticLocus name(String name);

  GeneticLocus dominantAllele(String dominantAllele);

  GeneticLocus recessiveAllele(String recessiveAllele);

  GeneticLocus dominantLabel(String dominantLabel);

  GeneticLocus recessiveLabel(String recessiveLabel);

  GeneticLocus description(String? description);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeneticLocus(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeneticLocus(...).copyWith(id: 12, name: "My name")
  /// ````
  GeneticLocus call({
    String code,
    String name,
    String dominantAllele,
    String recessiveAllele,
    String dominantLabel,
    String recessiveLabel,
    String? description,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGeneticLocus.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGeneticLocus.copyWith.fieldName(...)`
class _$GeneticLocusCWProxyImpl implements _$GeneticLocusCWProxy {
  const _$GeneticLocusCWProxyImpl(this._value);

  final GeneticLocus _value;

  @override
  GeneticLocus code(String code) => this(code: code);

  @override
  GeneticLocus name(String name) => this(name: name);

  @override
  GeneticLocus dominantAllele(String dominantAllele) =>
      this(dominantAllele: dominantAllele);

  @override
  GeneticLocus recessiveAllele(String recessiveAllele) =>
      this(recessiveAllele: recessiveAllele);

  @override
  GeneticLocus dominantLabel(String dominantLabel) =>
      this(dominantLabel: dominantLabel);

  @override
  GeneticLocus recessiveLabel(String recessiveLabel) =>
      this(recessiveLabel: recessiveLabel);

  @override
  GeneticLocus description(String? description) =>
      this(description: description);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeneticLocus(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeneticLocus(...).copyWith(id: 12, name: "My name")
  /// ````
  GeneticLocus call({
    Object? code = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? dominantAllele = const $CopyWithPlaceholder(),
    Object? recessiveAllele = const $CopyWithPlaceholder(),
    Object? dominantLabel = const $CopyWithPlaceholder(),
    Object? recessiveLabel = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
  }) {
    return GeneticLocus(
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      dominantAllele: dominantAllele == const $CopyWithPlaceholder()
          ? _value.dominantAllele
          // ignore: cast_nullable_to_non_nullable
          : dominantAllele as String,
      recessiveAllele: recessiveAllele == const $CopyWithPlaceholder()
          ? _value.recessiveAllele
          // ignore: cast_nullable_to_non_nullable
          : recessiveAllele as String,
      dominantLabel: dominantLabel == const $CopyWithPlaceholder()
          ? _value.dominantLabel
          // ignore: cast_nullable_to_non_nullable
          : dominantLabel as String,
      recessiveLabel: recessiveLabel == const $CopyWithPlaceholder()
          ? _value.recessiveLabel
          // ignore: cast_nullable_to_non_nullable
          : recessiveLabel as String,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
    );
  }
}

extension $GeneticLocusCopyWith on GeneticLocus {
  /// Returns a callable class that can be used as follows: `instanceOfGeneticLocus.copyWith(...)` or like so:`instanceOfGeneticLocus.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GeneticLocusCWProxy get copyWith => _$GeneticLocusCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneticLocus _$GeneticLocusFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'GeneticLocus',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'code',
        'name',
        'dominant_allele',
        'recessive_allele',
        'dominant_label',
        'recessive_label',
      ],
    );
    final val = GeneticLocus(
      code: $checkedConvert('code', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      dominantAllele: $checkedConvert('dominant_allele', (v) => v as String),
      recessiveAllele: $checkedConvert('recessive_allele', (v) => v as String),
      dominantLabel: $checkedConvert('dominant_label', (v) => v as String),
      recessiveLabel: $checkedConvert('recessive_label', (v) => v as String),
      description: $checkedConvert('description', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'dominantAllele': 'dominant_allele',
    'recessiveAllele': 'recessive_allele',
    'dominantLabel': 'dominant_label',
    'recessiveLabel': 'recessive_label',
  },
);

Map<String, dynamic> _$GeneticLocusToJson(GeneticLocus instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'dominant_allele': instance.dominantAllele,
      'recessive_allele': instance.recessiveAllele,
      'dominant_label': instance.dominantLabel,
      'recessive_label': instance.recessiveLabel,
      'description': ?instance.description,
    };
