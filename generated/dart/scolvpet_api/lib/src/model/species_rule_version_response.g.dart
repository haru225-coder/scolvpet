// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'species_rule_version_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SpeciesRuleVersionResponseCWProxy {
  SpeciesRuleVersionResponse data(SpeciesRuleVersion data);

  SpeciesRuleVersionResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SpeciesRuleVersionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SpeciesRuleVersionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SpeciesRuleVersionResponse call({SpeciesRuleVersion data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSpeciesRuleVersionResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSpeciesRuleVersionResponse.copyWith.fieldName(...)`
class _$SpeciesRuleVersionResponseCWProxyImpl
    implements _$SpeciesRuleVersionResponseCWProxy {
  const _$SpeciesRuleVersionResponseCWProxyImpl(this._value);

  final SpeciesRuleVersionResponse _value;

  @override
  SpeciesRuleVersionResponse data(SpeciesRuleVersion data) => this(data: data);

  @override
  SpeciesRuleVersionResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SpeciesRuleVersionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SpeciesRuleVersionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SpeciesRuleVersionResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return SpeciesRuleVersionResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as SpeciesRuleVersion,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $SpeciesRuleVersionResponseCopyWith on SpeciesRuleVersionResponse {
  /// Returns a callable class that can be used as follows: `instanceOfSpeciesRuleVersionResponse.copyWith(...)` or like so:`instanceOfSpeciesRuleVersionResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SpeciesRuleVersionResponseCWProxy get copyWith =>
      _$SpeciesRuleVersionResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpeciesRuleVersionResponse _$SpeciesRuleVersionResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SpeciesRuleVersionResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = SpeciesRuleVersionResponse(
    data: $checkedConvert(
      'data',
      (v) => SpeciesRuleVersion.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$SpeciesRuleVersionResponseToJson(
  SpeciesRuleVersionResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
