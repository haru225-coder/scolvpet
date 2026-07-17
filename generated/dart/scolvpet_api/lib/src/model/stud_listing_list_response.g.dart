// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stud_listing_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StudListingListResponseCWProxy {
  StudListingListResponse data(List<StudListing> data);

  StudListingListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StudListingListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StudListingListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  StudListingListResponse call({List<StudListing> data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStudListingListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStudListingListResponse.copyWith.fieldName(...)`
class _$StudListingListResponseCWProxyImpl
    implements _$StudListingListResponseCWProxy {
  const _$StudListingListResponseCWProxyImpl(this._value);

  final StudListingListResponse _value;

  @override
  StudListingListResponse data(List<StudListing> data) => this(data: data);

  @override
  StudListingListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StudListingListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StudListingListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  StudListingListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return StudListingListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<StudListing>,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $StudListingListResponseCopyWith on StudListingListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfStudListingListResponse.copyWith(...)` or like so:`instanceOfStudListingListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StudListingListResponseCWProxy get copyWith =>
      _$StudListingListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudListingListResponse _$StudListingListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('StudListingListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = StudListingListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => StudListing.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$StudListingListResponseToJson(
  StudListingListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'meta': instance.meta.toJson(),
};
