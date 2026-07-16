// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'litter_parent_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LitterParentResponseCWProxy {
  LitterParentResponse data(LitterParent data);

  LitterParentResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LitterParentResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LitterParentResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  LitterParentResponse call({LitterParent data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLitterParentResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLitterParentResponse.copyWith.fieldName(...)`
class _$LitterParentResponseCWProxyImpl
    implements _$LitterParentResponseCWProxy {
  const _$LitterParentResponseCWProxyImpl(this._value);

  final LitterParentResponse _value;

  @override
  LitterParentResponse data(LitterParent data) => this(data: data);

  @override
  LitterParentResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LitterParentResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LitterParentResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  LitterParentResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return LitterParentResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as LitterParent,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $LitterParentResponseCopyWith on LitterParentResponse {
  /// Returns a callable class that can be used as follows: `instanceOfLitterParentResponse.copyWith(...)` or like so:`instanceOfLitterParentResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LitterParentResponseCWProxy get copyWith =>
      _$LitterParentResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LitterParentResponse _$LitterParentResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('LitterParentResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = LitterParentResponse(
    data: $checkedConvert(
      'data',
      (v) => LitterParent.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$LitterParentResponseToJson(
  LitterParentResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
