// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'species_rule_version_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SpeciesRuleVersionListResponseCWProxy {
  SpeciesRuleVersionListResponse data(List<SpeciesRuleVersion> data);

  SpeciesRuleVersionListResponse page(PageInfo page);

  SpeciesRuleVersionListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SpeciesRuleVersionListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SpeciesRuleVersionListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SpeciesRuleVersionListResponse call({
    List<SpeciesRuleVersion> data,
    PageInfo page,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSpeciesRuleVersionListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSpeciesRuleVersionListResponse.copyWith.fieldName(...)`
class _$SpeciesRuleVersionListResponseCWProxyImpl
    implements _$SpeciesRuleVersionListResponseCWProxy {
  const _$SpeciesRuleVersionListResponseCWProxyImpl(this._value);

  final SpeciesRuleVersionListResponse _value;

  @override
  SpeciesRuleVersionListResponse data(List<SpeciesRuleVersion> data) =>
      this(data: data);

  @override
  SpeciesRuleVersionListResponse page(PageInfo page) => this(page: page);

  @override
  SpeciesRuleVersionListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SpeciesRuleVersionListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SpeciesRuleVersionListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SpeciesRuleVersionListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return SpeciesRuleVersionListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<SpeciesRuleVersion>,
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

extension $SpeciesRuleVersionListResponseCopyWith
    on SpeciesRuleVersionListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfSpeciesRuleVersionListResponse.copyWith(...)` or like so:`instanceOfSpeciesRuleVersionListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SpeciesRuleVersionListResponseCWProxy get copyWith =>
      _$SpeciesRuleVersionListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpeciesRuleVersionListResponse _$SpeciesRuleVersionListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SpeciesRuleVersionListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'page', 'meta']);
  final val = SpeciesRuleVersionListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => SpeciesRuleVersion.fromJson(e as Map<String, dynamic>))
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

Map<String, dynamic> _$SpeciesRuleVersionListResponseToJson(
  SpeciesRuleVersionListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'page': instance.page.toJson(),
  'meta': instance.meta.toJson(),
};
