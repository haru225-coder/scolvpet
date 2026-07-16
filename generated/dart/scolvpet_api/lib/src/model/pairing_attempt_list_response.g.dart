// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_attempt_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PairingAttemptListResponseCWProxy {
  PairingAttemptListResponse data(List<PairingAttempt> data);

  PairingAttemptListResponse page(PageInfo page);

  PairingAttemptListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PairingAttemptListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PairingAttemptListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PairingAttemptListResponse call({
    List<PairingAttempt> data,
    PageInfo page,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPairingAttemptListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPairingAttemptListResponse.copyWith.fieldName(...)`
class _$PairingAttemptListResponseCWProxyImpl
    implements _$PairingAttemptListResponseCWProxy {
  const _$PairingAttemptListResponseCWProxyImpl(this._value);

  final PairingAttemptListResponse _value;

  @override
  PairingAttemptListResponse data(List<PairingAttempt> data) =>
      this(data: data);

  @override
  PairingAttemptListResponse page(PageInfo page) => this(page: page);

  @override
  PairingAttemptListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PairingAttemptListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PairingAttemptListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PairingAttemptListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return PairingAttemptListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<PairingAttempt>,
      page: page == const $CopyWithPlaceholder()
          ? _value.page
          // ignore: cast_nullable_to_non_nullable
          : page as PageInfo,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $PairingAttemptListResponseCopyWith on PairingAttemptListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPairingAttemptListResponse.copyWith(...)` or like so:`instanceOfPairingAttemptListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PairingAttemptListResponseCWProxy get copyWith =>
      _$PairingAttemptListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingAttemptListResponse _$PairingAttemptListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PairingAttemptListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'page', 'meta']);
  final val = PairingAttemptListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => PairingAttempt.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    page: $checkedConvert(
      'page',
      (v) => PageInfo.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$PairingAttemptListResponseToJson(
  PairingAttemptListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'page': instance.page.toJson(),
  'meta': instance.meta.toJson(),
};
