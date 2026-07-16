// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'litter_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LitterResponseCWProxy {
  LitterResponse data(LitterResponseData data);

  LitterResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LitterResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LitterResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  LitterResponse call({LitterResponseData data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLitterResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLitterResponse.copyWith.fieldName(...)`
class _$LitterResponseCWProxyImpl implements _$LitterResponseCWProxy {
  const _$LitterResponseCWProxyImpl(this._value);

  final LitterResponse _value;

  @override
  LitterResponse data(LitterResponseData data) => this(data: data);

  @override
  LitterResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LitterResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LitterResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  LitterResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return LitterResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as LitterResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $LitterResponseCopyWith on LitterResponse {
  /// Returns a callable class that can be used as follows: `instanceOfLitterResponse.copyWith(...)` or like so:`instanceOfLitterResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LitterResponseCWProxy get copyWith => _$LitterResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LitterResponse _$LitterResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LitterResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = LitterResponse(
        data: $checkedConvert(
          'data',
          (v) => LitterResponseData.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$LitterResponseToJson(LitterResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
