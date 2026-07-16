// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enclosure_stay_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EnclosureStayResponseCWProxy {
  EnclosureStayResponse data(EnclosureStay data);

  EnclosureStayResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureStayResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureStayResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureStayResponse call({EnclosureStay data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEnclosureStayResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEnclosureStayResponse.copyWith.fieldName(...)`
class _$EnclosureStayResponseCWProxyImpl
    implements _$EnclosureStayResponseCWProxy {
  const _$EnclosureStayResponseCWProxyImpl(this._value);

  final EnclosureStayResponse _value;

  @override
  EnclosureStayResponse data(EnclosureStay data) => this(data: data);

  @override
  EnclosureStayResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureStayResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureStayResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureStayResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return EnclosureStayResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as EnclosureStay,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $EnclosureStayResponseCopyWith on EnclosureStayResponse {
  /// Returns a callable class that can be used as follows: `instanceOfEnclosureStayResponse.copyWith(...)` or like so:`instanceOfEnclosureStayResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EnclosureStayResponseCWProxy get copyWith =>
      _$EnclosureStayResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnclosureStayResponse _$EnclosureStayResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('EnclosureStayResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = EnclosureStayResponse(
    data: $checkedConvert(
      'data',
      (v) => EnclosureStay.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$EnclosureStayResponseToJson(
  EnclosureStayResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
