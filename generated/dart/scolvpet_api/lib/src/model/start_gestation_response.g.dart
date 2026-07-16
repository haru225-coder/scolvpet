// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_gestation_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StartGestationResponseCWProxy {
  StartGestationResponse data(StartGestationResponseData data);

  StartGestationResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StartGestationResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StartGestationResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  StartGestationResponse call({
    StartGestationResponseData data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStartGestationResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStartGestationResponse.copyWith.fieldName(...)`
class _$StartGestationResponseCWProxyImpl
    implements _$StartGestationResponseCWProxy {
  const _$StartGestationResponseCWProxyImpl(this._value);

  final StartGestationResponse _value;

  @override
  StartGestationResponse data(StartGestationResponseData data) =>
      this(data: data);

  @override
  StartGestationResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StartGestationResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StartGestationResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  StartGestationResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return StartGestationResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as StartGestationResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $StartGestationResponseCopyWith on StartGestationResponse {
  /// Returns a callable class that can be used as follows: `instanceOfStartGestationResponse.copyWith(...)` or like so:`instanceOfStartGestationResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StartGestationResponseCWProxy get copyWith =>
      _$StartGestationResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartGestationResponse _$StartGestationResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('StartGestationResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = StartGestationResponse(
    data: $checkedConvert(
      'data',
      (v) => StartGestationResponseData.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$StartGestationResponseToJson(
  StartGestationResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
