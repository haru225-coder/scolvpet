// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_edit_recipe_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MediaEditRecipeResponseCWProxy {
  MediaEditRecipeResponse data(MediaEditRecipeResponseData data);

  MediaEditRecipeResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaEditRecipeResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaEditRecipeResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaEditRecipeResponse call({
    MediaEditRecipeResponseData data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMediaEditRecipeResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMediaEditRecipeResponse.copyWith.fieldName(...)`
class _$MediaEditRecipeResponseCWProxyImpl
    implements _$MediaEditRecipeResponseCWProxy {
  const _$MediaEditRecipeResponseCWProxyImpl(this._value);

  final MediaEditRecipeResponse _value;

  @override
  MediaEditRecipeResponse data(MediaEditRecipeResponseData data) =>
      this(data: data);

  @override
  MediaEditRecipeResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaEditRecipeResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaEditRecipeResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaEditRecipeResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return MediaEditRecipeResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as MediaEditRecipeResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $MediaEditRecipeResponseCopyWith on MediaEditRecipeResponse {
  /// Returns a callable class that can be used as follows: `instanceOfMediaEditRecipeResponse.copyWith(...)` or like so:`instanceOfMediaEditRecipeResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MediaEditRecipeResponseCWProxy get copyWith =>
      _$MediaEditRecipeResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaEditRecipeResponse _$MediaEditRecipeResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MediaEditRecipeResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = MediaEditRecipeResponse(
    data: $checkedConvert(
      'data',
      (v) => MediaEditRecipeResponseData.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$MediaEditRecipeResponseToJson(
  MediaEditRecipeResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
