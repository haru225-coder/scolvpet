// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'litter_member_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LitterMemberListResponseCWProxy {
  LitterMemberListResponse data(List<LitterMember> data);

  LitterMemberListResponse page(PageInfo page);

  LitterMemberListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LitterMemberListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LitterMemberListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  LitterMemberListResponse call({
    List<LitterMember> data,
    PageInfo page,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLitterMemberListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLitterMemberListResponse.copyWith.fieldName(...)`
class _$LitterMemberListResponseCWProxyImpl
    implements _$LitterMemberListResponseCWProxy {
  const _$LitterMemberListResponseCWProxyImpl(this._value);

  final LitterMemberListResponse _value;

  @override
  LitterMemberListResponse data(List<LitterMember> data) => this(data: data);

  @override
  LitterMemberListResponse page(PageInfo page) => this(page: page);

  @override
  LitterMemberListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LitterMemberListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LitterMemberListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  LitterMemberListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return LitterMemberListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<LitterMember>,
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

extension $LitterMemberListResponseCopyWith on LitterMemberListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfLitterMemberListResponse.copyWith(...)` or like so:`instanceOfLitterMemberListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LitterMemberListResponseCWProxy get copyWith =>
      _$LitterMemberListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LitterMemberListResponse _$LitterMemberListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('LitterMemberListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'page', 'meta']);
  final val = LitterMemberListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => LitterMember.fromJson(e as Map<String, dynamic>))
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

Map<String, dynamic> _$LitterMemberListResponseToJson(
  LitterMemberListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'page': instance.page.toJson(),
  'meta': instance.meta.toJson(),
};
