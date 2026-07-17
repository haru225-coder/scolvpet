// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stud_listing_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StudListingResponseCWProxy {
  StudListingResponse data(StudListing data);

  StudListingResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StudListingResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StudListingResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  StudListingResponse call({StudListing data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStudListingResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStudListingResponse.copyWith.fieldName(...)`
class _$StudListingResponseCWProxyImpl implements _$StudListingResponseCWProxy {
  const _$StudListingResponseCWProxyImpl(this._value);

  final StudListingResponse _value;

  @override
  StudListingResponse data(StudListing data) => this(data: data);

  @override
  StudListingResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StudListingResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StudListingResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  StudListingResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return StudListingResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as StudListing,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $StudListingResponseCopyWith on StudListingResponse {
  /// Returns a callable class that can be used as follows: `instanceOfStudListingResponse.copyWith(...)` or like so:`instanceOfStudListingResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StudListingResponseCWProxy get copyWith =>
      _$StudListingResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudListingResponse _$StudListingResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('StudListingResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = StudListingResponse(
        data: $checkedConvert(
          'data',
          (v) => StudListing.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$StudListingResponseToJson(
  StudListingResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
