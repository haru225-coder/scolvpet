// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publish_breeding_plan_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublishBreedingPlanResponseDataCWProxy {
  PublishBreedingPlanResponseData breedingPlan(BreedingPlan breedingPlan);

  PublishBreedingPlanResponseData createdTasks(List<CareTask> createdTasks);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublishBreedingPlanResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublishBreedingPlanResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  PublishBreedingPlanResponseData call({
    BreedingPlan breedingPlan,
    List<CareTask> createdTasks,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublishBreedingPlanResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublishBreedingPlanResponseData.copyWith.fieldName(...)`
class _$PublishBreedingPlanResponseDataCWProxyImpl
    implements _$PublishBreedingPlanResponseDataCWProxy {
  const _$PublishBreedingPlanResponseDataCWProxyImpl(this._value);

  final PublishBreedingPlanResponseData _value;

  @override
  PublishBreedingPlanResponseData breedingPlan(BreedingPlan breedingPlan) =>
      this(breedingPlan: breedingPlan);

  @override
  PublishBreedingPlanResponseData createdTasks(List<CareTask> createdTasks) =>
      this(createdTasks: createdTasks);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublishBreedingPlanResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublishBreedingPlanResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  PublishBreedingPlanResponseData call({
    Object? breedingPlan = const $CopyWithPlaceholder(),
    Object? createdTasks = const $CopyWithPlaceholder(),
  }) {
    return PublishBreedingPlanResponseData(
      breedingPlan: breedingPlan == const $CopyWithPlaceholder()
          ? _value.breedingPlan
          // ignore: cast_nullable_to_non_nullable
          : breedingPlan as BreedingPlan,
      createdTasks: createdTasks == const $CopyWithPlaceholder()
          ? _value.createdTasks
          // ignore: cast_nullable_to_non_nullable
          : createdTasks as List<CareTask>,
    );
  }
}

extension $PublishBreedingPlanResponseDataCopyWith
    on PublishBreedingPlanResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfPublishBreedingPlanResponseData.copyWith(...)` or like so:`instanceOfPublishBreedingPlanResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublishBreedingPlanResponseDataCWProxy get copyWith =>
      _$PublishBreedingPlanResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublishBreedingPlanResponseData _$PublishBreedingPlanResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PublishBreedingPlanResponseData',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['breeding_plan', 'created_tasks']);
    final val = PublishBreedingPlanResponseData(
      breedingPlan: $checkedConvert(
        'breeding_plan',
        (v) => BreedingPlan.fromJson(v as Map<String, dynamic>),
      ),
      createdTasks: $checkedConvert(
        'created_tasks',
        (v) => (v as List<dynamic>)
            .map((e) => CareTask.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'breedingPlan': 'breeding_plan',
    'createdTasks': 'created_tasks',
  },
);

Map<String, dynamic> _$PublishBreedingPlanResponseDataToJson(
  PublishBreedingPlanResponseData instance,
) => <String, dynamic>{
  'breeding_plan': instance.breedingPlan.toJson(),
  'created_tasks': instance.createdTasks.map((e) => e.toJson()).toList(),
};
