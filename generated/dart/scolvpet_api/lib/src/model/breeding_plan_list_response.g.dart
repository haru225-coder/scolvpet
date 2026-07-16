// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breeding_plan_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BreedingPlanListResponseCWProxy {
  BreedingPlanListResponse data(List<BreedingPlan> data);

  BreedingPlanListResponse page(PageInfo page);

  BreedingPlanListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BreedingPlanListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BreedingPlanListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  BreedingPlanListResponse call({
    List<BreedingPlan> data,
    PageInfo page,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBreedingPlanListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBreedingPlanListResponse.copyWith.fieldName(...)`
class _$BreedingPlanListResponseCWProxyImpl
    implements _$BreedingPlanListResponseCWProxy {
  const _$BreedingPlanListResponseCWProxyImpl(this._value);

  final BreedingPlanListResponse _value;

  @override
  BreedingPlanListResponse data(List<BreedingPlan> data) => this(data: data);

  @override
  BreedingPlanListResponse page(PageInfo page) => this(page: page);

  @override
  BreedingPlanListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BreedingPlanListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BreedingPlanListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  BreedingPlanListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return BreedingPlanListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<BreedingPlan>,
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

extension $BreedingPlanListResponseCopyWith on BreedingPlanListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfBreedingPlanListResponse.copyWith(...)` or like so:`instanceOfBreedingPlanListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BreedingPlanListResponseCWProxy get copyWith =>
      _$BreedingPlanListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BreedingPlanListResponse _$BreedingPlanListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('BreedingPlanListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'page', 'meta']);
  final val = BreedingPlanListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => BreedingPlan.fromJson(e as Map<String, dynamic>))
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

Map<String, dynamic> _$BreedingPlanListResponseToJson(
  BreedingPlanListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'page': instance.page.toJson(),
  'meta': instance.meta.toJson(),
};
