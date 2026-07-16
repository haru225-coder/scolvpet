// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adjust_baseline_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdjustBaselineRequestCWProxy {
  AdjustBaselineRequest newBaselineAt(DateTime newBaselineAt);

  AdjustBaselineRequest reason(String reason);

  AdjustBaselineRequest timezone(String timezone);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdjustBaselineRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdjustBaselineRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AdjustBaselineRequest call({
    DateTime newBaselineAt,
    String reason,
    String timezone,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAdjustBaselineRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAdjustBaselineRequest.copyWith.fieldName(...)`
class _$AdjustBaselineRequestCWProxyImpl
    implements _$AdjustBaselineRequestCWProxy {
  const _$AdjustBaselineRequestCWProxyImpl(this._value);

  final AdjustBaselineRequest _value;

  @override
  AdjustBaselineRequest newBaselineAt(DateTime newBaselineAt) =>
      this(newBaselineAt: newBaselineAt);

  @override
  AdjustBaselineRequest reason(String reason) => this(reason: reason);

  @override
  AdjustBaselineRequest timezone(String timezone) => this(timezone: timezone);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdjustBaselineRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdjustBaselineRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AdjustBaselineRequest call({
    Object? newBaselineAt = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
  }) {
    return AdjustBaselineRequest(
      newBaselineAt: newBaselineAt == const $CopyWithPlaceholder()
          ? _value.newBaselineAt
          // ignore: cast_nullable_to_non_nullable
          : newBaselineAt as DateTime,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String,
    );
  }
}

extension $AdjustBaselineRequestCopyWith on AdjustBaselineRequest {
  /// Returns a callable class that can be used as follows: `instanceOfAdjustBaselineRequest.copyWith(...)` or like so:`instanceOfAdjustBaselineRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AdjustBaselineRequestCWProxy get copyWith =>
      _$AdjustBaselineRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdjustBaselineRequest _$AdjustBaselineRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AdjustBaselineRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['new_baseline_at', 'reason', 'timezone'],
    );
    final val = AdjustBaselineRequest(
      newBaselineAt: $checkedConvert(
        'new_baseline_at',
        (v) => DateTime.parse(v as String),
      ),
      reason: $checkedConvert('reason', (v) => v as String),
      timezone: $checkedConvert('timezone', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {'newBaselineAt': 'new_baseline_at'},
);

Map<String, dynamic> _$AdjustBaselineRequestToJson(
  AdjustBaselineRequest instance,
) => <String, dynamic>{
  'new_baseline_at': instance.newBaselineAt.toIso8601String(),
  'reason': instance.reason,
  'timezone': instance.timezone,
};
