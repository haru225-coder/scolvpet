// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adjust_baseline_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdjustBaselineResponseDataCWProxy {
  AdjustBaselineResponseData breedingPlan(BreedingPlan breedingPlan);

  AdjustBaselineResponseData supersededReminderIds(
    List<String> supersededReminderIds,
  );

  AdjustBaselineResponseData createdReminders(List<Reminder> createdReminders);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdjustBaselineResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdjustBaselineResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  AdjustBaselineResponseData call({
    BreedingPlan breedingPlan,
    List<String> supersededReminderIds,
    List<Reminder> createdReminders,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAdjustBaselineResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAdjustBaselineResponseData.copyWith.fieldName(...)`
class _$AdjustBaselineResponseDataCWProxyImpl
    implements _$AdjustBaselineResponseDataCWProxy {
  const _$AdjustBaselineResponseDataCWProxyImpl(this._value);

  final AdjustBaselineResponseData _value;

  @override
  AdjustBaselineResponseData breedingPlan(BreedingPlan breedingPlan) =>
      this(breedingPlan: breedingPlan);

  @override
  AdjustBaselineResponseData supersededReminderIds(
    List<String> supersededReminderIds,
  ) => this(supersededReminderIds: supersededReminderIds);

  @override
  AdjustBaselineResponseData createdReminders(
    List<Reminder> createdReminders,
  ) => this(createdReminders: createdReminders);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdjustBaselineResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdjustBaselineResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  AdjustBaselineResponseData call({
    Object? breedingPlan = const $CopyWithPlaceholder(),
    Object? supersededReminderIds = const $CopyWithPlaceholder(),
    Object? createdReminders = const $CopyWithPlaceholder(),
  }) {
    return AdjustBaselineResponseData(
      breedingPlan: breedingPlan == const $CopyWithPlaceholder()
          ? _value.breedingPlan
          // ignore: cast_nullable_to_non_nullable
          : breedingPlan as BreedingPlan,
      supersededReminderIds:
          supersededReminderIds == const $CopyWithPlaceholder()
          ? _value.supersededReminderIds
          // ignore: cast_nullable_to_non_nullable
          : supersededReminderIds as List<String>,
      createdReminders: createdReminders == const $CopyWithPlaceholder()
          ? _value.createdReminders
          // ignore: cast_nullable_to_non_nullable
          : createdReminders as List<Reminder>,
    );
  }
}

extension $AdjustBaselineResponseDataCopyWith on AdjustBaselineResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfAdjustBaselineResponseData.copyWith(...)` or like so:`instanceOfAdjustBaselineResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AdjustBaselineResponseDataCWProxy get copyWith =>
      _$AdjustBaselineResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdjustBaselineResponseData _$AdjustBaselineResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AdjustBaselineResponseData',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'breeding_plan',
        'superseded_reminder_ids',
        'created_reminders',
      ],
    );
    final val = AdjustBaselineResponseData(
      breedingPlan: $checkedConvert(
        'breeding_plan',
        (v) => BreedingPlan.fromJson(v as Map<String, dynamic>),
      ),
      supersededReminderIds: $checkedConvert(
        'superseded_reminder_ids',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
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
    'supersededReminderIds': 'superseded_reminder_ids',
    'createdReminders': 'created_reminders',
  },
);

Map<String, dynamic> _$AdjustBaselineResponseDataToJson(
  AdjustBaselineResponseData instance,
) => <String, dynamic>{
  'breeding_plan': instance.breedingPlan.toJson(),
  'superseded_reminder_ids': instance.supersededReminderIds,
  'created_reminders': instance.createdReminders
      .map((e) => e.toJson())
      .toList(),
};
