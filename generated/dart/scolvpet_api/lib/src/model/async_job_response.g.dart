// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'async_job_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AsyncJobResponseCWProxy {
  AsyncJobResponse data(AsyncJob data);

  AsyncJobResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AsyncJobResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AsyncJobResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AsyncJobResponse call({AsyncJob data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAsyncJobResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAsyncJobResponse.copyWith.fieldName(...)`
class _$AsyncJobResponseCWProxyImpl implements _$AsyncJobResponseCWProxy {
  const _$AsyncJobResponseCWProxyImpl(this._value);

  final AsyncJobResponse _value;

  @override
  AsyncJobResponse data(AsyncJob data) => this(data: data);

  @override
  AsyncJobResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AsyncJobResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AsyncJobResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AsyncJobResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return AsyncJobResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as AsyncJob,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $AsyncJobResponseCopyWith on AsyncJobResponse {
  /// Returns a callable class that can be used as follows: `instanceOfAsyncJobResponse.copyWith(...)` or like so:`instanceOfAsyncJobResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AsyncJobResponseCWProxy get copyWith => _$AsyncJobResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AsyncJobResponse _$AsyncJobResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AsyncJobResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = AsyncJobResponse(
        data: $checkedConvert(
          'data',
          (v) => AsyncJob.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AsyncJobResponseToJson(AsyncJobResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
