// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breeding_plan_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BreedingPlanResponseCWProxy {
  BreedingPlanResponse data(BreedingPlan data);

  BreedingPlanResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BreedingPlanResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BreedingPlanResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  BreedingPlanResponse call({BreedingPlan data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBreedingPlanResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBreedingPlanResponse.copyWith.fieldName(...)`
class _$BreedingPlanResponseCWProxyImpl
    implements _$BreedingPlanResponseCWProxy {
  const _$BreedingPlanResponseCWProxyImpl(this._value);

  final BreedingPlanResponse _value;

  @override
  BreedingPlanResponse data(BreedingPlan data) => this(data: data);

  @override
  BreedingPlanResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BreedingPlanResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BreedingPlanResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  BreedingPlanResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return BreedingPlanResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as BreedingPlan,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $BreedingPlanResponseCopyWith on BreedingPlanResponse {
  /// Returns a callable class that can be used as follows: `instanceOfBreedingPlanResponse.copyWith(...)` or like so:`instanceOfBreedingPlanResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BreedingPlanResponseCWProxy get copyWith =>
      _$BreedingPlanResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BreedingPlanResponse _$BreedingPlanResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('BreedingPlanResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = BreedingPlanResponse(
    data: $checkedConvert(
      'data',
      (v) => BreedingPlan.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$BreedingPlanResponseToJson(
  BreedingPlanResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
