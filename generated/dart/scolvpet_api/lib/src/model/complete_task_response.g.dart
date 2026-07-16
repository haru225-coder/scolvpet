// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_task_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CompleteTaskResponseCWProxy {
  CompleteTaskResponse data(CompleteTaskResponseData data);

  CompleteTaskResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CompleteTaskResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CompleteTaskResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CompleteTaskResponse call({CompleteTaskResponseData data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCompleteTaskResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCompleteTaskResponse.copyWith.fieldName(...)`
class _$CompleteTaskResponseCWProxyImpl
    implements _$CompleteTaskResponseCWProxy {
  const _$CompleteTaskResponseCWProxyImpl(this._value);

  final CompleteTaskResponse _value;

  @override
  CompleteTaskResponse data(CompleteTaskResponseData data) => this(data: data);

  @override
  CompleteTaskResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CompleteTaskResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CompleteTaskResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CompleteTaskResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return CompleteTaskResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as CompleteTaskResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $CompleteTaskResponseCopyWith on CompleteTaskResponse {
  /// Returns a callable class that can be used as follows: `instanceOfCompleteTaskResponse.copyWith(...)` or like so:`instanceOfCompleteTaskResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CompleteTaskResponseCWProxy get copyWith =>
      _$CompleteTaskResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompleteTaskResponse _$CompleteTaskResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CompleteTaskResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = CompleteTaskResponse(
    data: $checkedConvert(
      'data',
      (v) => CompleteTaskResponseData.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$CompleteTaskResponseToJson(
  CompleteTaskResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
