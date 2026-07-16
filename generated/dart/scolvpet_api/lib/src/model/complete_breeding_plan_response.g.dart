// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_breeding_plan_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CompleteBreedingPlanResponseCWProxy {
  CompleteBreedingPlanResponse data(CompleteBreedingPlanResponseData data);

  CompleteBreedingPlanResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CompleteBreedingPlanResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CompleteBreedingPlanResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CompleteBreedingPlanResponse call({
    CompleteBreedingPlanResponseData data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCompleteBreedingPlanResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCompleteBreedingPlanResponse.copyWith.fieldName(...)`
class _$CompleteBreedingPlanResponseCWProxyImpl
    implements _$CompleteBreedingPlanResponseCWProxy {
  const _$CompleteBreedingPlanResponseCWProxyImpl(this._value);

  final CompleteBreedingPlanResponse _value;

  @override
  CompleteBreedingPlanResponse data(CompleteBreedingPlanResponseData data) =>
      this(data: data);

  @override
  CompleteBreedingPlanResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CompleteBreedingPlanResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CompleteBreedingPlanResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CompleteBreedingPlanResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return CompleteBreedingPlanResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as CompleteBreedingPlanResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $CompleteBreedingPlanResponseCopyWith
    on CompleteBreedingPlanResponse {
  /// Returns a callable class that can be used as follows: `instanceOfCompleteBreedingPlanResponse.copyWith(...)` or like so:`instanceOfCompleteBreedingPlanResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CompleteBreedingPlanResponseCWProxy get copyWith =>
      _$CompleteBreedingPlanResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompleteBreedingPlanResponse _$CompleteBreedingPlanResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CompleteBreedingPlanResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = CompleteBreedingPlanResponse(
    data: $checkedConvert(
      'data',
      (v) =>
          CompleteBreedingPlanResponseData.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$CompleteBreedingPlanResponseToJson(
  CompleteBreedingPlanResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
