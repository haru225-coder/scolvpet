// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_record_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeightRecordResponseCWProxy {
  WeightRecordResponse data(WeightRecord data);

  WeightRecordResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightRecordResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightRecordResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightRecordResponse call({WeightRecord data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeightRecordResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeightRecordResponse.copyWith.fieldName(...)`
class _$WeightRecordResponseCWProxyImpl
    implements _$WeightRecordResponseCWProxy {
  const _$WeightRecordResponseCWProxyImpl(this._value);

  final WeightRecordResponse _value;

  @override
  WeightRecordResponse data(WeightRecord data) => this(data: data);

  @override
  WeightRecordResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightRecordResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightRecordResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightRecordResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return WeightRecordResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as WeightRecord,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $WeightRecordResponseCopyWith on WeightRecordResponse {
  /// Returns a callable class that can be used as follows: `instanceOfWeightRecordResponse.copyWith(...)` or like so:`instanceOfWeightRecordResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeightRecordResponseCWProxy get copyWith =>
      _$WeightRecordResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightRecordResponse _$WeightRecordResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WeightRecordResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = WeightRecordResponse(
    data: $checkedConvert(
      'data',
      (v) => WeightRecord.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$WeightRecordResponseToJson(
  WeightRecordResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
