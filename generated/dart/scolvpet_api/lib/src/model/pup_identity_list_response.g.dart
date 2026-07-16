// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pup_identity_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PupIdentityListResponseCWProxy {
  PupIdentityListResponse data(List<PupIdentity> data);

  PupIdentityListResponse page(PageInfo page);

  PupIdentityListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PupIdentityListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PupIdentityListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PupIdentityListResponse call({
    List<PupIdentity> data,
    PageInfo page,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPupIdentityListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPupIdentityListResponse.copyWith.fieldName(...)`
class _$PupIdentityListResponseCWProxyImpl
    implements _$PupIdentityListResponseCWProxy {
  const _$PupIdentityListResponseCWProxyImpl(this._value);

  final PupIdentityListResponse _value;

  @override
  PupIdentityListResponse data(List<PupIdentity> data) => this(data: data);

  @override
  PupIdentityListResponse page(PageInfo page) => this(page: page);

  @override
  PupIdentityListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PupIdentityListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PupIdentityListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PupIdentityListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return PupIdentityListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<PupIdentity>,
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

extension $PupIdentityListResponseCopyWith on PupIdentityListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPupIdentityListResponse.copyWith(...)` or like so:`instanceOfPupIdentityListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PupIdentityListResponseCWProxy get copyWith =>
      _$PupIdentityListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PupIdentityListResponse _$PupIdentityListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PupIdentityListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'page', 'meta']);
  final val = PupIdentityListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => PupIdentity.fromJson(e as Map<String, dynamic>))
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

Map<String, dynamic> _$PupIdentityListResponseToJson(
  PupIdentityListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'page': instance.page.toJson(),
  'meta': instance.meta.toJson(),
};
