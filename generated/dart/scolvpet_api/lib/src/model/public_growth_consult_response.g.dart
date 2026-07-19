// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_growth_consult_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublicGrowthConsultResponseCWProxy {
  PublicGrowthConsultResponse data(PublicGrowthConsultResponseData data);

  PublicGrowthConsultResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicGrowthConsultResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicGrowthConsultResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicGrowthConsultResponse call({
    PublicGrowthConsultResponseData data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublicGrowthConsultResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublicGrowthConsultResponse.copyWith.fieldName(...)`
class _$PublicGrowthConsultResponseCWProxyImpl
    implements _$PublicGrowthConsultResponseCWProxy {
  const _$PublicGrowthConsultResponseCWProxyImpl(this._value);

  final PublicGrowthConsultResponse _value;

  @override
  PublicGrowthConsultResponse data(PublicGrowthConsultResponseData data) =>
      this(data: data);

  @override
  PublicGrowthConsultResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicGrowthConsultResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicGrowthConsultResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicGrowthConsultResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return PublicGrowthConsultResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as PublicGrowthConsultResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $PublicGrowthConsultResponseCopyWith on PublicGrowthConsultResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPublicGrowthConsultResponse.copyWith(...)` or like so:`instanceOfPublicGrowthConsultResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublicGrowthConsultResponseCWProxy get copyWith =>
      _$PublicGrowthConsultResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicGrowthConsultResponse _$PublicGrowthConsultResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PublicGrowthConsultResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = PublicGrowthConsultResponse(
    data: $checkedConvert(
      'data',
      (v) =>
          PublicGrowthConsultResponseData.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$PublicGrowthConsultResponseToJson(
  PublicGrowthConsultResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
