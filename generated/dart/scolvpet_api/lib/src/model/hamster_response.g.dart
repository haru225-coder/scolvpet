// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hamster_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HamsterResponseCWProxy {
  HamsterResponse data(Hamster data);

  HamsterResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HamsterResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HamsterResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  HamsterResponse call({Hamster data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHamsterResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHamsterResponse.copyWith.fieldName(...)`
class _$HamsterResponseCWProxyImpl implements _$HamsterResponseCWProxy {
  const _$HamsterResponseCWProxyImpl(this._value);

  final HamsterResponse _value;

  @override
  HamsterResponse data(Hamster data) => this(data: data);

  @override
  HamsterResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HamsterResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HamsterResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  HamsterResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return HamsterResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as Hamster,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $HamsterResponseCopyWith on HamsterResponse {
  /// Returns a callable class that can be used as follows: `instanceOfHamsterResponse.copyWith(...)` or like so:`instanceOfHamsterResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HamsterResponseCWProxy get copyWith => _$HamsterResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HamsterResponse _$HamsterResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('HamsterResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = HamsterResponse(
        data: $checkedConvert(
          'data',
          (v) => Hamster.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$HamsterResponseToJson(HamsterResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
