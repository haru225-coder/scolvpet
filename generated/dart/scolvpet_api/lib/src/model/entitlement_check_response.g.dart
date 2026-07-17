// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement_check_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EntitlementCheckResponseCWProxy {
  EntitlementCheckResponse data(EntitlementCheckResult data);

  EntitlementCheckResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EntitlementCheckResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EntitlementCheckResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  EntitlementCheckResponse call({
    EntitlementCheckResult data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEntitlementCheckResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEntitlementCheckResponse.copyWith.fieldName(...)`
class _$EntitlementCheckResponseCWProxyImpl
    implements _$EntitlementCheckResponseCWProxy {
  const _$EntitlementCheckResponseCWProxyImpl(this._value);

  final EntitlementCheckResponse _value;

  @override
  EntitlementCheckResponse data(EntitlementCheckResult data) =>
      this(data: data);

  @override
  EntitlementCheckResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EntitlementCheckResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EntitlementCheckResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  EntitlementCheckResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return EntitlementCheckResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as EntitlementCheckResult,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $EntitlementCheckResponseCopyWith on EntitlementCheckResponse {
  /// Returns a callable class that can be used as follows: `instanceOfEntitlementCheckResponse.copyWith(...)` or like so:`instanceOfEntitlementCheckResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EntitlementCheckResponseCWProxy get copyWith =>
      _$EntitlementCheckResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntitlementCheckResponse _$EntitlementCheckResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('EntitlementCheckResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = EntitlementCheckResponse(
    data: $checkedConvert(
      'data',
      (v) => EntitlementCheckResult.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$EntitlementCheckResponseToJson(
  EntitlementCheckResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
