// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wean_litter_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeanLitterResponseCWProxy {
  WeanLitterResponse data(WeanLitterResponseData data);

  WeanLitterResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeanLitterResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeanLitterResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WeanLitterResponse call({WeanLitterResponseData data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeanLitterResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeanLitterResponse.copyWith.fieldName(...)`
class _$WeanLitterResponseCWProxyImpl implements _$WeanLitterResponseCWProxy {
  const _$WeanLitterResponseCWProxyImpl(this._value);

  final WeanLitterResponse _value;

  @override
  WeanLitterResponse data(WeanLitterResponseData data) => this(data: data);

  @override
  WeanLitterResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeanLitterResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeanLitterResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WeanLitterResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return WeanLitterResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as WeanLitterResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $WeanLitterResponseCopyWith on WeanLitterResponse {
  /// Returns a callable class that can be used as follows: `instanceOfWeanLitterResponse.copyWith(...)` or like so:`instanceOfWeanLitterResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeanLitterResponseCWProxy get copyWith =>
      _$WeanLitterResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeanLitterResponse _$WeanLitterResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WeanLitterResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = WeanLitterResponse(
        data: $checkedConvert(
          'data',
          (v) => WeanLitterResponseData.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$WeanLitterResponseToJson(WeanLitterResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
