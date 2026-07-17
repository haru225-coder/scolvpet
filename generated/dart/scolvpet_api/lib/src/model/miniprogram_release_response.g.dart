// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'miniprogram_release_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MiniprogramReleaseResponseCWProxy {
  MiniprogramReleaseResponse data(MiniprogramRelease data);

  MiniprogramReleaseResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MiniprogramReleaseResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MiniprogramReleaseResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MiniprogramReleaseResponse call({MiniprogramRelease data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMiniprogramReleaseResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMiniprogramReleaseResponse.copyWith.fieldName(...)`
class _$MiniprogramReleaseResponseCWProxyImpl
    implements _$MiniprogramReleaseResponseCWProxy {
  const _$MiniprogramReleaseResponseCWProxyImpl(this._value);

  final MiniprogramReleaseResponse _value;

  @override
  MiniprogramReleaseResponse data(MiniprogramRelease data) => this(data: data);

  @override
  MiniprogramReleaseResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MiniprogramReleaseResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MiniprogramReleaseResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MiniprogramReleaseResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return MiniprogramReleaseResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as MiniprogramRelease,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $MiniprogramReleaseResponseCopyWith on MiniprogramReleaseResponse {
  /// Returns a callable class that can be used as follows: `instanceOfMiniprogramReleaseResponse.copyWith(...)` or like so:`instanceOfMiniprogramReleaseResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MiniprogramReleaseResponseCWProxy get copyWith =>
      _$MiniprogramReleaseResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MiniprogramReleaseResponse _$MiniprogramReleaseResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MiniprogramReleaseResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = MiniprogramReleaseResponse(
    data: $checkedConvert(
      'data',
      (v) => MiniprogramRelease.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$MiniprogramReleaseResponseToJson(
  MiniprogramReleaseResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
