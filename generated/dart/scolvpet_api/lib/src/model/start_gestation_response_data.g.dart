// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_gestation_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StartGestationResponseDataCWProxy {
  StartGestationResponseData breedingPlan(BreedingPlan breedingPlan);

  StartGestationResponseData createdReminders(List<Reminder> createdReminders);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StartGestationResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StartGestationResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  StartGestationResponseData call({
    BreedingPlan breedingPlan,
    List<Reminder> createdReminders,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStartGestationResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStartGestationResponseData.copyWith.fieldName(...)`
class _$StartGestationResponseDataCWProxyImpl
    implements _$StartGestationResponseDataCWProxy {
  const _$StartGestationResponseDataCWProxyImpl(this._value);

  final StartGestationResponseData _value;

  @override
  StartGestationResponseData breedingPlan(BreedingPlan breedingPlan) =>
      this(breedingPlan: breedingPlan);

  @override
  StartGestationResponseData createdReminders(
    List<Reminder> createdReminders,
  ) => this(createdReminders: createdReminders);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StartGestationResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StartGestationResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  StartGestationResponseData call({
    Object? breedingPlan = const $CopyWithPlaceholder(),
    Object? createdReminders = const $CopyWithPlaceholder(),
  }) {
    return StartGestationResponseData(
      breedingPlan: breedingPlan == const $CopyWithPlaceholder()
          ? _value.breedingPlan
          // ignore: cast_nullable_to_non_nullable
          : breedingPlan as BreedingPlan,
      createdReminders: createdReminders == const $CopyWithPlaceholder()
          ? _value.createdReminders
          // ignore: cast_nullable_to_non_nullable
          : createdReminders as List<Reminder>,
    );
  }
}

extension $StartGestationResponseDataCopyWith on StartGestationResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfStartGestationResponseData.copyWith(...)` or like so:`instanceOfStartGestationResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StartGestationResponseDataCWProxy get copyWith =>
      _$StartGestationResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartGestationResponseData _$StartGestationResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'StartGestationResponseData',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['breeding_plan', 'created_reminders'],
    );
    final val = StartGestationResponseData(
      breedingPlan: $checkedConvert(
        'breeding_plan',
        (v) => BreedingPlan.fromJson(v as Map<String, dynamic>),
      ),
      createdReminders: $checkedConvert(
        'created_reminders',
        (v) => (v as List<dynamic>)
            .map((e) => Reminder.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'breedingPlan': 'breeding_plan',
    'createdReminders': 'created_reminders',
  },
);

Map<String, dynamic> _$StartGestationResponseDataToJson(
  StartGestationResponseData instance,
) => <String, dynamic>{
  'breeding_plan': instance.breedingPlan.toJson(),
  'created_reminders': instance.createdReminders
      .map((e) => e.toJson())
      .toList(),
};
