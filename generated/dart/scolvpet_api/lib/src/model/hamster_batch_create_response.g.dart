// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hamster_batch_create_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HamsterBatchCreateResponseCWProxy {
  HamsterBatchCreateResponse data(HamsterBatchCreateResponseData data);

  HamsterBatchCreateResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HamsterBatchCreateResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HamsterBatchCreateResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  HamsterBatchCreateResponse call({
    HamsterBatchCreateResponseData data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHamsterBatchCreateResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHamsterBatchCreateResponse.copyWith.fieldName(...)`
class _$HamsterBatchCreateResponseCWProxyImpl
    implements _$HamsterBatchCreateResponseCWProxy {
  const _$HamsterBatchCreateResponseCWProxyImpl(this._value);

  final HamsterBatchCreateResponse _value;

  @override
  HamsterBatchCreateResponse data(HamsterBatchCreateResponseData data) =>
      this(data: data);

  @override
  HamsterBatchCreateResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HamsterBatchCreateResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HamsterBatchCreateResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  HamsterBatchCreateResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return HamsterBatchCreateResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as HamsterBatchCreateResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $HamsterBatchCreateResponseCopyWith on HamsterBatchCreateResponse {
  /// Returns a callable class that can be used as follows: `instanceOfHamsterBatchCreateResponse.copyWith(...)` or like so:`instanceOfHamsterBatchCreateResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HamsterBatchCreateResponseCWProxy get copyWith =>
      _$HamsterBatchCreateResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HamsterBatchCreateResponse _$HamsterBatchCreateResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('HamsterBatchCreateResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = HamsterBatchCreateResponse(
    data: $checkedConvert(
      'data',
      (v) => HamsterBatchCreateResponseData.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$HamsterBatchCreateResponseToJson(
  HamsterBatchCreateResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
