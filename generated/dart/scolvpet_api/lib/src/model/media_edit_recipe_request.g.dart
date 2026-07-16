// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_edit_recipe_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MediaEditRecipeRequestCWProxy {
  MediaEditRecipeRequest operations(
    List<MediaEditRecipeRequestOperationsInner> operations,
  );

  MediaEditRecipeRequest outputFormat(
    MediaEditRecipeRequestOutputFormatEnum? outputFormat,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaEditRecipeRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaEditRecipeRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaEditRecipeRequest call({
    List<MediaEditRecipeRequestOperationsInner> operations,
    MediaEditRecipeRequestOutputFormatEnum? outputFormat,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMediaEditRecipeRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMediaEditRecipeRequest.copyWith.fieldName(...)`
class _$MediaEditRecipeRequestCWProxyImpl
    implements _$MediaEditRecipeRequestCWProxy {
  const _$MediaEditRecipeRequestCWProxyImpl(this._value);

  final MediaEditRecipeRequest _value;

  @override
  MediaEditRecipeRequest operations(
    List<MediaEditRecipeRequestOperationsInner> operations,
  ) => this(operations: operations);

  @override
  MediaEditRecipeRequest outputFormat(
    MediaEditRecipeRequestOutputFormatEnum? outputFormat,
  ) => this(outputFormat: outputFormat);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaEditRecipeRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaEditRecipeRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaEditRecipeRequest call({
    Object? operations = const $CopyWithPlaceholder(),
    Object? outputFormat = const $CopyWithPlaceholder(),
  }) {
    return MediaEditRecipeRequest(
      operations: operations == const $CopyWithPlaceholder()
          ? _value.operations
          // ignore: cast_nullable_to_non_nullable
          : operations as List<MediaEditRecipeRequestOperationsInner>,
      outputFormat: outputFormat == const $CopyWithPlaceholder()
          ? _value.outputFormat
          // ignore: cast_nullable_to_non_nullable
          : outputFormat as MediaEditRecipeRequestOutputFormatEnum?,
    );
  }
}

extension $MediaEditRecipeRequestCopyWith on MediaEditRecipeRequest {
  /// Returns a callable class that can be used as follows: `instanceOfMediaEditRecipeRequest.copyWith(...)` or like so:`instanceOfMediaEditRecipeRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MediaEditRecipeRequestCWProxy get copyWith =>
      _$MediaEditRecipeRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaEditRecipeRequest _$MediaEditRecipeRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'MediaEditRecipeRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['operations']);
    final val = MediaEditRecipeRequest(
      operations: $checkedConvert(
        'operations',
        (v) => (v as List<dynamic>)
            .map(
              (e) => MediaEditRecipeRequestOperationsInner.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList(),
      ),
      outputFormat: $checkedConvert(
        'output_format',
        (v) =>
            $enumDecodeNullable(
              _$MediaEditRecipeRequestOutputFormatEnumEnumMap,
              v,
            ) ??
            MediaEditRecipeRequestOutputFormatEnum.jpeg,
      ),
    );
    return val;
  },
  fieldKeyMap: const {'outputFormat': 'output_format'},
);

Map<String, dynamic> _$MediaEditRecipeRequestToJson(
  MediaEditRecipeRequest instance,
) => <String, dynamic>{
  'operations': instance.operations.map((e) => e.toJson()).toList(),
  'output_format':
      ?_$MediaEditRecipeRequestOutputFormatEnumEnumMap[instance.outputFormat],
};

const _$MediaEditRecipeRequestOutputFormatEnumEnumMap = {
  MediaEditRecipeRequestOutputFormatEnum.jpeg: 'jpeg',
  MediaEditRecipeRequestOutputFormatEnum.png: 'png',
  MediaEditRecipeRequestOutputFormatEnum.webp: 'webp',
};
