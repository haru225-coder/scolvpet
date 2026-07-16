// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enclosure_cleaning_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EnclosureCleaningResponseCWProxy {
  EnclosureCleaningResponse data(EnclosureCleaning data);

  EnclosureCleaningResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureCleaningResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureCleaningResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureCleaningResponse call({EnclosureCleaning data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEnclosureCleaningResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEnclosureCleaningResponse.copyWith.fieldName(...)`
class _$EnclosureCleaningResponseCWProxyImpl
    implements _$EnclosureCleaningResponseCWProxy {
  const _$EnclosureCleaningResponseCWProxyImpl(this._value);

  final EnclosureCleaningResponse _value;

  @override
  EnclosureCleaningResponse data(EnclosureCleaning data) => this(data: data);

  @override
  EnclosureCleaningResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureCleaningResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureCleaningResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureCleaningResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return EnclosureCleaningResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as EnclosureCleaning,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $EnclosureCleaningResponseCopyWith on EnclosureCleaningResponse {
  /// Returns a callable class that can be used as follows: `instanceOfEnclosureCleaningResponse.copyWith(...)` or like so:`instanceOfEnclosureCleaningResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EnclosureCleaningResponseCWProxy get copyWith =>
      _$EnclosureCleaningResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnclosureCleaningResponse _$EnclosureCleaningResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('EnclosureCleaningResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = EnclosureCleaningResponse(
    data: $checkedConvert(
      'data',
      (v) => EnclosureCleaning.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$EnclosureCleaningResponseToJson(
  EnclosureCleaningResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
