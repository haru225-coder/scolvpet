// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_breeding_plan_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CompleteBreedingPlanRequestCWProxy {
  CompleteBreedingPlanRequest completedAt(DateTime completedAt);

  CompleteBreedingPlanRequest timezone(String timezone);

  CompleteBreedingPlanRequest notes(String? notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CompleteBreedingPlanRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CompleteBreedingPlanRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CompleteBreedingPlanRequest call({
    DateTime completedAt,
    String timezone,
    String? notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCompleteBreedingPlanRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCompleteBreedingPlanRequest.copyWith.fieldName(...)`
class _$CompleteBreedingPlanRequestCWProxyImpl
    implements _$CompleteBreedingPlanRequestCWProxy {
  const _$CompleteBreedingPlanRequestCWProxyImpl(this._value);

  final CompleteBreedingPlanRequest _value;

  @override
  CompleteBreedingPlanRequest completedAt(DateTime completedAt) =>
      this(completedAt: completedAt);

  @override
  CompleteBreedingPlanRequest timezone(String timezone) =>
      this(timezone: timezone);

  @override
  CompleteBreedingPlanRequest notes(String? notes) => this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CompleteBreedingPlanRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CompleteBreedingPlanRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CompleteBreedingPlanRequest call({
    Object? completedAt = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return CompleteBreedingPlanRequest(
      completedAt: completedAt == const $CopyWithPlaceholder()
          ? _value.completedAt
          // ignore: cast_nullable_to_non_nullable
          : completedAt as DateTime,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
    );
  }
}

extension $CompleteBreedingPlanRequestCopyWith on CompleteBreedingPlanRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCompleteBreedingPlanRequest.copyWith(...)` or like so:`instanceOfCompleteBreedingPlanRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CompleteBreedingPlanRequestCWProxy get copyWith =>
      _$CompleteBreedingPlanRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompleteBreedingPlanRequest _$CompleteBreedingPlanRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CompleteBreedingPlanRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['completed_at', 'timezone']);
    final val = CompleteBreedingPlanRequest(
      completedAt: $checkedConvert(
        'completed_at',
        (v) => DateTime.parse(v as String),
      ),
      timezone: $checkedConvert('timezone', (v) => v as String),
      notes: $checkedConvert('notes', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {'completedAt': 'completed_at'},
);

Map<String, dynamic> _$CompleteBreedingPlanRequestToJson(
  CompleteBreedingPlanRequest instance,
) => <String, dynamic>{
  'completed_at': instance.completedAt.toIso8601String(),
  'timezone': instance.timezone,
  'notes': ?instance.notes,
};
