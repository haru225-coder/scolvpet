// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_correction_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TaskCorrectionRequestCWProxy {
  TaskCorrectionRequest reason(String reason);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TaskCorrectionRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TaskCorrectionRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  TaskCorrectionRequest call({String reason});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTaskCorrectionRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTaskCorrectionRequest.copyWith.fieldName(...)`
class _$TaskCorrectionRequestCWProxyImpl
    implements _$TaskCorrectionRequestCWProxy {
  const _$TaskCorrectionRequestCWProxyImpl(this._value);

  final TaskCorrectionRequest _value;

  @override
  TaskCorrectionRequest reason(String reason) => this(reason: reason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TaskCorrectionRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TaskCorrectionRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  TaskCorrectionRequest call({Object? reason = const $CopyWithPlaceholder()}) {
    return TaskCorrectionRequest(
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
    );
  }
}

extension $TaskCorrectionRequestCopyWith on TaskCorrectionRequest {
  /// Returns a callable class that can be used as follows: `instanceOfTaskCorrectionRequest.copyWith(...)` or like so:`instanceOfTaskCorrectionRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TaskCorrectionRequestCWProxy get copyWith =>
      _$TaskCorrectionRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskCorrectionRequest _$TaskCorrectionRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('TaskCorrectionRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['reason']);
  final val = TaskCorrectionRequest(
    reason: $checkedConvert('reason', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$TaskCorrectionRequestToJson(
  TaskCorrectionRequest instance,
) => <String, dynamic>{'reason': instance.reason};
