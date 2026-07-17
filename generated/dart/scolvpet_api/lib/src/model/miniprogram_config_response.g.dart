// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'miniprogram_config_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MiniprogramConfigResponseCWProxy {
  MiniprogramConfigResponse data(MiniprogramConfig data);

  MiniprogramConfigResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MiniprogramConfigResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MiniprogramConfigResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MiniprogramConfigResponse call({MiniprogramConfig data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMiniprogramConfigResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMiniprogramConfigResponse.copyWith.fieldName(...)`
class _$MiniprogramConfigResponseCWProxyImpl
    implements _$MiniprogramConfigResponseCWProxy {
  const _$MiniprogramConfigResponseCWProxyImpl(this._value);

  final MiniprogramConfigResponse _value;

  @override
  MiniprogramConfigResponse data(MiniprogramConfig data) => this(data: data);

  @override
  MiniprogramConfigResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MiniprogramConfigResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MiniprogramConfigResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MiniprogramConfigResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return MiniprogramConfigResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as MiniprogramConfig,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $MiniprogramConfigResponseCopyWith on MiniprogramConfigResponse {
  /// Returns a callable class that can be used as follows: `instanceOfMiniprogramConfigResponse.copyWith(...)` or like so:`instanceOfMiniprogramConfigResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MiniprogramConfigResponseCWProxy get copyWith =>
      _$MiniprogramConfigResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MiniprogramConfigResponse _$MiniprogramConfigResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MiniprogramConfigResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = MiniprogramConfigResponse(
    data: $checkedConvert(
      'data',
      (v) => MiniprogramConfig.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$MiniprogramConfigResponseToJson(
  MiniprogramConfigResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
