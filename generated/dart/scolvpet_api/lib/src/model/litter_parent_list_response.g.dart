// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'litter_parent_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LitterParentListResponseCWProxy {
  LitterParentListResponse data(List<LitterParent> data);

  LitterParentListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LitterParentListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LitterParentListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  LitterParentListResponse call({List<LitterParent> data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLitterParentListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLitterParentListResponse.copyWith.fieldName(...)`
class _$LitterParentListResponseCWProxyImpl
    implements _$LitterParentListResponseCWProxy {
  const _$LitterParentListResponseCWProxyImpl(this._value);

  final LitterParentListResponse _value;

  @override
  LitterParentListResponse data(List<LitterParent> data) => this(data: data);

  @override
  LitterParentListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LitterParentListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LitterParentListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  LitterParentListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return LitterParentListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<LitterParent>,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $LitterParentListResponseCopyWith on LitterParentListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfLitterParentListResponse.copyWith(...)` or like so:`instanceOfLitterParentListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LitterParentListResponseCWProxy get copyWith =>
      _$LitterParentListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LitterParentListResponse _$LitterParentListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('LitterParentListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = LitterParentListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => LitterParent.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$LitterParentListResponseToJson(
  LitterParentListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'meta': instance.meta.toJson(),
};
