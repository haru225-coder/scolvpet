// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_device_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PushDeviceResponseCWProxy {
  PushDeviceResponse data(PushDevice data);

  PushDeviceResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PushDeviceResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PushDeviceResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PushDeviceResponse call({PushDevice data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPushDeviceResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPushDeviceResponse.copyWith.fieldName(...)`
class _$PushDeviceResponseCWProxyImpl implements _$PushDeviceResponseCWProxy {
  const _$PushDeviceResponseCWProxyImpl(this._value);

  final PushDeviceResponse _value;

  @override
  PushDeviceResponse data(PushDevice data) => this(data: data);

  @override
  PushDeviceResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PushDeviceResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PushDeviceResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PushDeviceResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return PushDeviceResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as PushDevice,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $PushDeviceResponseCopyWith on PushDeviceResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPushDeviceResponse.copyWith(...)` or like so:`instanceOfPushDeviceResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PushDeviceResponseCWProxy get copyWith =>
      _$PushDeviceResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushDeviceResponse _$PushDeviceResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PushDeviceResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = PushDeviceResponse(
        data: $checkedConvert(
          'data',
          (v) => PushDevice.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PushDeviceResponseToJson(PushDeviceResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
