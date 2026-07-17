// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement_catalog_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EntitlementCatalogResponseCWProxy {
  EntitlementCatalogResponse data(List<PlanCatalogEntry> data);

  EntitlementCatalogResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EntitlementCatalogResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EntitlementCatalogResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  EntitlementCatalogResponse call({
    List<PlanCatalogEntry> data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEntitlementCatalogResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEntitlementCatalogResponse.copyWith.fieldName(...)`
class _$EntitlementCatalogResponseCWProxyImpl
    implements _$EntitlementCatalogResponseCWProxy {
  const _$EntitlementCatalogResponseCWProxyImpl(this._value);

  final EntitlementCatalogResponse _value;

  @override
  EntitlementCatalogResponse data(List<PlanCatalogEntry> data) =>
      this(data: data);

  @override
  EntitlementCatalogResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EntitlementCatalogResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EntitlementCatalogResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  EntitlementCatalogResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return EntitlementCatalogResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<PlanCatalogEntry>,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $EntitlementCatalogResponseCopyWith on EntitlementCatalogResponse {
  /// Returns a callable class that can be used as follows: `instanceOfEntitlementCatalogResponse.copyWith(...)` or like so:`instanceOfEntitlementCatalogResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EntitlementCatalogResponseCWProxy get copyWith =>
      _$EntitlementCatalogResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntitlementCatalogResponse _$EntitlementCatalogResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('EntitlementCatalogResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = EntitlementCatalogResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => PlanCatalogEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$EntitlementCatalogResponseToJson(
  EntitlementCatalogResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'meta': instance.meta.toJson(),
};
