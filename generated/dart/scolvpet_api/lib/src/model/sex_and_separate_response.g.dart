// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sex_and_separate_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SexAndSeparateResponseCWProxy {
  SexAndSeparateResponse data(SexAndSeparateResponseData data);

  SexAndSeparateResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SexAndSeparateResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SexAndSeparateResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SexAndSeparateResponse call({
    SexAndSeparateResponseData data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSexAndSeparateResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSexAndSeparateResponse.copyWith.fieldName(...)`
class _$SexAndSeparateResponseCWProxyImpl
    implements _$SexAndSeparateResponseCWProxy {
  const _$SexAndSeparateResponseCWProxyImpl(this._value);

  final SexAndSeparateResponse _value;

  @override
  SexAndSeparateResponse data(SexAndSeparateResponseData data) =>
      this(data: data);

  @override
  SexAndSeparateResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SexAndSeparateResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SexAndSeparateResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SexAndSeparateResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return SexAndSeparateResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as SexAndSeparateResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $SexAndSeparateResponseCopyWith on SexAndSeparateResponse {
  /// Returns a callable class that can be used as follows: `instanceOfSexAndSeparateResponse.copyWith(...)` or like so:`instanceOfSexAndSeparateResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SexAndSeparateResponseCWProxy get copyWith =>
      _$SexAndSeparateResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SexAndSeparateResponse _$SexAndSeparateResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SexAndSeparateResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = SexAndSeparateResponse(
    data: $checkedConvert(
      'data',
      (v) => SexAndSeparateResponseData.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$SexAndSeparateResponseToJson(
  SexAndSeparateResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
