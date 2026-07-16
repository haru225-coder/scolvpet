// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'care_task_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CareTaskResponseCWProxy {
  CareTaskResponse data(CareTask data);

  CareTaskResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CareTaskResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CareTaskResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CareTaskResponse call({CareTask data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCareTaskResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCareTaskResponse.copyWith.fieldName(...)`
class _$CareTaskResponseCWProxyImpl implements _$CareTaskResponseCWProxy {
  const _$CareTaskResponseCWProxyImpl(this._value);

  final CareTaskResponse _value;

  @override
  CareTaskResponse data(CareTask data) => this(data: data);

  @override
  CareTaskResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CareTaskResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CareTaskResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CareTaskResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return CareTaskResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as CareTask,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $CareTaskResponseCopyWith on CareTaskResponse {
  /// Returns a callable class that can be used as follows: `instanceOfCareTaskResponse.copyWith(...)` or like so:`instanceOfCareTaskResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CareTaskResponseCWProxy get copyWith => _$CareTaskResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CareTaskResponse _$CareTaskResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CareTaskResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = CareTaskResponse(
        data: $checkedConvert(
          'data',
          (v) => CareTask.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CareTaskResponseToJson(CareTaskResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
