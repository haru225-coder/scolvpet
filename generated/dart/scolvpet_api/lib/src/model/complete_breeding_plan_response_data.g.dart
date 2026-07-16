// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_breeding_plan_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CompleteBreedingPlanResponseDataCWProxy {
  CompleteBreedingPlanResponseData breedingPlan(BreedingPlan breedingPlan);

  CompleteBreedingPlanResponseData reconciliation(
    Reconciliation reconciliation,
  );

  CompleteBreedingPlanResponseData completedAt(DateTime completedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CompleteBreedingPlanResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CompleteBreedingPlanResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  CompleteBreedingPlanResponseData call({
    BreedingPlan breedingPlan,
    Reconciliation reconciliation,
    DateTime completedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCompleteBreedingPlanResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCompleteBreedingPlanResponseData.copyWith.fieldName(...)`
class _$CompleteBreedingPlanResponseDataCWProxyImpl
    implements _$CompleteBreedingPlanResponseDataCWProxy {
  const _$CompleteBreedingPlanResponseDataCWProxyImpl(this._value);

  final CompleteBreedingPlanResponseData _value;

  @override
  CompleteBreedingPlanResponseData breedingPlan(BreedingPlan breedingPlan) =>
      this(breedingPlan: breedingPlan);

  @override
  CompleteBreedingPlanResponseData reconciliation(
    Reconciliation reconciliation,
  ) => this(reconciliation: reconciliation);

  @override
  CompleteBreedingPlanResponseData completedAt(DateTime completedAt) =>
      this(completedAt: completedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CompleteBreedingPlanResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CompleteBreedingPlanResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  CompleteBreedingPlanResponseData call({
    Object? breedingPlan = const $CopyWithPlaceholder(),
    Object? reconciliation = const $CopyWithPlaceholder(),
    Object? completedAt = const $CopyWithPlaceholder(),
  }) {
    return CompleteBreedingPlanResponseData(
      breedingPlan: breedingPlan == const $CopyWithPlaceholder()
          ? _value.breedingPlan
          // ignore: cast_nullable_to_non_nullable
          : breedingPlan as BreedingPlan,
      reconciliation: reconciliation == const $CopyWithPlaceholder()
          ? _value.reconciliation
          // ignore: cast_nullable_to_non_nullable
          : reconciliation as Reconciliation,
      completedAt: completedAt == const $CopyWithPlaceholder()
          ? _value.completedAt
          // ignore: cast_nullable_to_non_nullable
          : completedAt as DateTime,
    );
  }
}

extension $CompleteBreedingPlanResponseDataCopyWith
    on CompleteBreedingPlanResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfCompleteBreedingPlanResponseData.copyWith(...)` or like so:`instanceOfCompleteBreedingPlanResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CompleteBreedingPlanResponseDataCWProxy get copyWith =>
      _$CompleteBreedingPlanResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompleteBreedingPlanResponseData _$CompleteBreedingPlanResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CompleteBreedingPlanResponseData',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['breeding_plan', 'reconciliation', 'completed_at'],
    );
    final val = CompleteBreedingPlanResponseData(
      breedingPlan: $checkedConvert(
        'breeding_plan',
        (v) => BreedingPlan.fromJson(v as Map<String, dynamic>),
      ),
      reconciliation: $checkedConvert(
        'reconciliation',
        (v) => Reconciliation.fromJson(v as Map<String, dynamic>),
      ),
      completedAt: $checkedConvert(
        'completed_at',
        (v) => DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'breedingPlan': 'breeding_plan',
    'completedAt': 'completed_at',
  },
);

Map<String, dynamic> _$CompleteBreedingPlanResponseDataToJson(
  CompleteBreedingPlanResponseData instance,
) => <String, dynamic>{
  'breeding_plan': instance.breedingPlan.toJson(),
  'reconciliation': instance.reconciliation.toJson(),
  'completed_at': instance.completedAt.toIso8601String(),
};
