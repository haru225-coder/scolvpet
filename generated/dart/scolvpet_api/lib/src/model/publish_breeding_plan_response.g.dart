// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publish_breeding_plan_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublishBreedingPlanResponseCWProxy {
  PublishBreedingPlanResponse data(PublishBreedingPlanResponseData data);

  PublishBreedingPlanResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublishBreedingPlanResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublishBreedingPlanResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PublishBreedingPlanResponse call({
    PublishBreedingPlanResponseData data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublishBreedingPlanResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublishBreedingPlanResponse.copyWith.fieldName(...)`
class _$PublishBreedingPlanResponseCWProxyImpl
    implements _$PublishBreedingPlanResponseCWProxy {
  const _$PublishBreedingPlanResponseCWProxyImpl(this._value);

  final PublishBreedingPlanResponse _value;

  @override
  PublishBreedingPlanResponse data(PublishBreedingPlanResponseData data) =>
      this(data: data);

  @override
  PublishBreedingPlanResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublishBreedingPlanResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublishBreedingPlanResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PublishBreedingPlanResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return PublishBreedingPlanResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as PublishBreedingPlanResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $PublishBreedingPlanResponseCopyWith on PublishBreedingPlanResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPublishBreedingPlanResponse.copyWith(...)` or like so:`instanceOfPublishBreedingPlanResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublishBreedingPlanResponseCWProxy get copyWith =>
      _$PublishBreedingPlanResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublishBreedingPlanResponse _$PublishBreedingPlanResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PublishBreedingPlanResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = PublishBreedingPlanResponse(
    data: $checkedConvert(
      'data',
      (v) =>
          PublishBreedingPlanResponseData.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$PublishBreedingPlanResponseToJson(
  PublishBreedingPlanResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
