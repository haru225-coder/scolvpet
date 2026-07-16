// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enclosure_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EnclosureResponseCWProxy {
  EnclosureResponse data(Enclosure data);

  EnclosureResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureResponse call({Enclosure data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEnclosureResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEnclosureResponse.copyWith.fieldName(...)`
class _$EnclosureResponseCWProxyImpl implements _$EnclosureResponseCWProxy {
  const _$EnclosureResponseCWProxyImpl(this._value);

  final EnclosureResponse _value;

  @override
  EnclosureResponse data(Enclosure data) => this(data: data);

  @override
  EnclosureResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return EnclosureResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as Enclosure,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $EnclosureResponseCopyWith on EnclosureResponse {
  /// Returns a callable class that can be used as follows: `instanceOfEnclosureResponse.copyWith(...)` or like so:`instanceOfEnclosureResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EnclosureResponseCWProxy get copyWith =>
      _$EnclosureResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnclosureResponse _$EnclosureResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('EnclosureResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = EnclosureResponse(
        data: $checkedConvert(
          'data',
          (v) => Enclosure.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$EnclosureResponseToJson(EnclosureResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
