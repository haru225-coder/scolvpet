// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stud_deal_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StudDealResponseCWProxy {
  StudDealResponse data(StudDeal data);

  StudDealResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StudDealResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StudDealResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  StudDealResponse call({StudDeal data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStudDealResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStudDealResponse.copyWith.fieldName(...)`
class _$StudDealResponseCWProxyImpl implements _$StudDealResponseCWProxy {
  const _$StudDealResponseCWProxyImpl(this._value);

  final StudDealResponse _value;

  @override
  StudDealResponse data(StudDeal data) => this(data: data);

  @override
  StudDealResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StudDealResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StudDealResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  StudDealResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return StudDealResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as StudDeal,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $StudDealResponseCopyWith on StudDealResponse {
  /// Returns a callable class that can be used as follows: `instanceOfStudDealResponse.copyWith(...)` or like so:`instanceOfStudDealResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StudDealResponseCWProxy get copyWith => _$StudDealResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudDealResponse _$StudDealResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('StudDealResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = StudDealResponse(
        data: $checkedConvert(
          'data',
          (v) => StudDeal.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$StudDealResponseToJson(StudDealResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
