// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement_snapshot_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EntitlementSnapshotResponseCWProxy {
  EntitlementSnapshotResponse data(EntitlementSnapshot data);

  EntitlementSnapshotResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EntitlementSnapshotResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EntitlementSnapshotResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  EntitlementSnapshotResponse call({
    EntitlementSnapshot data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEntitlementSnapshotResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEntitlementSnapshotResponse.copyWith.fieldName(...)`
class _$EntitlementSnapshotResponseCWProxyImpl
    implements _$EntitlementSnapshotResponseCWProxy {
  const _$EntitlementSnapshotResponseCWProxyImpl(this._value);

  final EntitlementSnapshotResponse _value;

  @override
  EntitlementSnapshotResponse data(EntitlementSnapshot data) =>
      this(data: data);

  @override
  EntitlementSnapshotResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EntitlementSnapshotResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EntitlementSnapshotResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  EntitlementSnapshotResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return EntitlementSnapshotResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as EntitlementSnapshot,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $EntitlementSnapshotResponseCopyWith on EntitlementSnapshotResponse {
  /// Returns a callable class that can be used as follows: `instanceOfEntitlementSnapshotResponse.copyWith(...)` or like so:`instanceOfEntitlementSnapshotResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EntitlementSnapshotResponseCWProxy get copyWith =>
      _$EntitlementSnapshotResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntitlementSnapshotResponse _$EntitlementSnapshotResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('EntitlementSnapshotResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = EntitlementSnapshotResponse(
    data: $checkedConvert(
      'data',
      (v) => EntitlementSnapshot.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$EntitlementSnapshotResponseToJson(
  EntitlementSnapshotResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
