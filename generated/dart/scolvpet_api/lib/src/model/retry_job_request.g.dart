// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'retry_job_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RetryJobRequestCWProxy {
  RetryJobRequest reason(String reason);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RetryJobRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RetryJobRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RetryJobRequest call({String reason});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRetryJobRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRetryJobRequest.copyWith.fieldName(...)`
class _$RetryJobRequestCWProxyImpl implements _$RetryJobRequestCWProxy {
  const _$RetryJobRequestCWProxyImpl(this._value);

  final RetryJobRequest _value;

  @override
  RetryJobRequest reason(String reason) => this(reason: reason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RetryJobRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RetryJobRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RetryJobRequest call({Object? reason = const $CopyWithPlaceholder()}) {
    return RetryJobRequest(
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
    );
  }
}

extension $RetryJobRequestCopyWith on RetryJobRequest {
  /// Returns a callable class that can be used as follows: `instanceOfRetryJobRequest.copyWith(...)` or like so:`instanceOfRetryJobRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RetryJobRequestCWProxy get copyWith => _$RetryJobRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RetryJobRequest _$RetryJobRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RetryJobRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['reason']);
      final val = RetryJobRequest(
        reason: $checkedConvert('reason', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$RetryJobRequestToJson(RetryJobRequest instance) =>
    <String, dynamic>{'reason': instance.reason};
