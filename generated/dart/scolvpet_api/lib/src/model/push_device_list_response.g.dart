// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_device_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PushDeviceListResponseCWProxy {
  PushDeviceListResponse data(List<PushDevice> data);

  PushDeviceListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PushDeviceListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PushDeviceListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PushDeviceListResponse call({List<PushDevice> data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPushDeviceListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPushDeviceListResponse.copyWith.fieldName(...)`
class _$PushDeviceListResponseCWProxyImpl
    implements _$PushDeviceListResponseCWProxy {
  const _$PushDeviceListResponseCWProxyImpl(this._value);

  final PushDeviceListResponse _value;

  @override
  PushDeviceListResponse data(List<PushDevice> data) => this(data: data);

  @override
  PushDeviceListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PushDeviceListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PushDeviceListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PushDeviceListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return PushDeviceListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<PushDevice>,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $PushDeviceListResponseCopyWith on PushDeviceListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPushDeviceListResponse.copyWith(...)` or like so:`instanceOfPushDeviceListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PushDeviceListResponseCWProxy get copyWith =>
      _$PushDeviceListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushDeviceListResponse _$PushDeviceListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PushDeviceListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = PushDeviceListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => PushDevice.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$PushDeviceListResponseToJson(
  PushDeviceListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'meta': instance.meta.toJson(),
};
