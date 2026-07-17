// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stud_deal_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StudDealListResponseCWProxy {
  StudDealListResponse data(List<StudDeal> data);

  StudDealListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StudDealListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StudDealListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  StudDealListResponse call({List<StudDeal> data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStudDealListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStudDealListResponse.copyWith.fieldName(...)`
class _$StudDealListResponseCWProxyImpl
    implements _$StudDealListResponseCWProxy {
  const _$StudDealListResponseCWProxyImpl(this._value);

  final StudDealListResponse _value;

  @override
  StudDealListResponse data(List<StudDeal> data) => this(data: data);

  @override
  StudDealListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StudDealListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StudDealListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  StudDealListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return StudDealListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<StudDeal>,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $StudDealListResponseCopyWith on StudDealListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfStudDealListResponse.copyWith(...)` or like so:`instanceOfStudDealListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StudDealListResponseCWProxy get copyWith =>
      _$StudDealListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudDealListResponse _$StudDealListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('StudDealListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = StudDealListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => StudDeal.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$StudDealListResponseToJson(
  StudDealListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'meta': instance.meta.toJson(),
};
