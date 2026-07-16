// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_edit_recipe_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MediaEditRecipeResponseDataCWProxy {
  MediaEditRecipeResponseData sourceMediaId(String sourceMediaId);

  MediaEditRecipeResponseData recipeId(String recipeId);

  MediaEditRecipeResponseData job(AsyncJob job);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaEditRecipeResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaEditRecipeResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaEditRecipeResponseData call({
    String sourceMediaId,
    String recipeId,
    AsyncJob job,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMediaEditRecipeResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMediaEditRecipeResponseData.copyWith.fieldName(...)`
class _$MediaEditRecipeResponseDataCWProxyImpl
    implements _$MediaEditRecipeResponseDataCWProxy {
  const _$MediaEditRecipeResponseDataCWProxyImpl(this._value);

  final MediaEditRecipeResponseData _value;

  @override
  MediaEditRecipeResponseData sourceMediaId(String sourceMediaId) =>
      this(sourceMediaId: sourceMediaId);

  @override
  MediaEditRecipeResponseData recipeId(String recipeId) =>
      this(recipeId: recipeId);

  @override
  MediaEditRecipeResponseData job(AsyncJob job) => this(job: job);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaEditRecipeResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaEditRecipeResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaEditRecipeResponseData call({
    Object? sourceMediaId = const $CopyWithPlaceholder(),
    Object? recipeId = const $CopyWithPlaceholder(),
    Object? job = const $CopyWithPlaceholder(),
  }) {
    return MediaEditRecipeResponseData(
      sourceMediaId: sourceMediaId == const $CopyWithPlaceholder()
          ? _value.sourceMediaId
          // ignore: cast_nullable_to_non_nullable
          : sourceMediaId as String,
      recipeId: recipeId == const $CopyWithPlaceholder()
          ? _value.recipeId
          // ignore: cast_nullable_to_non_nullable
          : recipeId as String,
      job: job == const $CopyWithPlaceholder()
          ? _value.job
          // ignore: cast_nullable_to_non_nullable
          : job as AsyncJob,
    );
  }
}

extension $MediaEditRecipeResponseDataCopyWith on MediaEditRecipeResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfMediaEditRecipeResponseData.copyWith(...)` or like so:`instanceOfMediaEditRecipeResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MediaEditRecipeResponseDataCWProxy get copyWith =>
      _$MediaEditRecipeResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaEditRecipeResponseData _$MediaEditRecipeResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'MediaEditRecipeResponseData',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['source_media_id', 'recipe_id', 'job'],
    );
    final val = MediaEditRecipeResponseData(
      sourceMediaId: $checkedConvert('source_media_id', (v) => v as String),
      recipeId: $checkedConvert('recipe_id', (v) => v as String),
      job: $checkedConvert(
        'job',
        (v) => AsyncJob.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'sourceMediaId': 'source_media_id',
    'recipeId': 'recipe_id',
  },
);

Map<String, dynamic> _$MediaEditRecipeResponseDataToJson(
  MediaEditRecipeResponseData instance,
) => <String, dynamic>{
  'source_media_id': instance.sourceMediaId,
  'recipe_id': instance.recipeId,
  'job': instance.job.toJson(),
};
