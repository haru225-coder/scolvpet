// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_record_batch_create_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeightRecordBatchCreateResponseCWProxy {
  WeightRecordBatchCreateResponse data(
    WeightRecordBatchCreateResponseData data,
  );

  WeightRecordBatchCreateResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightRecordBatchCreateResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightRecordBatchCreateResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightRecordBatchCreateResponse call({
    WeightRecordBatchCreateResponseData data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeightRecordBatchCreateResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeightRecordBatchCreateResponse.copyWith.fieldName(...)`
class _$WeightRecordBatchCreateResponseCWProxyImpl
    implements _$WeightRecordBatchCreateResponseCWProxy {
  const _$WeightRecordBatchCreateResponseCWProxyImpl(this._value);

  final WeightRecordBatchCreateResponse _value;

  @override
  WeightRecordBatchCreateResponse data(
    WeightRecordBatchCreateResponseData data,
  ) => this(data: data);

  @override
  WeightRecordBatchCreateResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightRecordBatchCreateResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightRecordBatchCreateResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightRecordBatchCreateResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return WeightRecordBatchCreateResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as WeightRecordBatchCreateResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $WeightRecordBatchCreateResponseCopyWith
    on WeightRecordBatchCreateResponse {
  /// Returns a callable class that can be used as follows: `instanceOfWeightRecordBatchCreateResponse.copyWith(...)` or like so:`instanceOfWeightRecordBatchCreateResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeightRecordBatchCreateResponseCWProxy get copyWith =>
      _$WeightRecordBatchCreateResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightRecordBatchCreateResponse _$WeightRecordBatchCreateResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WeightRecordBatchCreateResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = WeightRecordBatchCreateResponse(
    data: $checkedConvert(
      'data',
      (v) => WeightRecordBatchCreateResponseData.fromJson(
        v as Map<String, dynamic>,
      ),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$WeightRecordBatchCreateResponseToJson(
  WeightRecordBatchCreateResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
