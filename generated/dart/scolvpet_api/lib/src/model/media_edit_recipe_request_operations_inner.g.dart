// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_edit_recipe_request_operations_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MediaEditRecipeRequestOperationsInnerCWProxy {
  MediaEditRecipeRequestOperationsInner type(
    MediaEditRecipeRequestOperationsInnerTypeEnum type,
  );

  MediaEditRecipeRequestOperationsInner parameters(
    Map<String, Object> parameters,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaEditRecipeRequestOperationsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaEditRecipeRequestOperationsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaEditRecipeRequestOperationsInner call({
    MediaEditRecipeRequestOperationsInnerTypeEnum type,
    Map<String, Object> parameters,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMediaEditRecipeRequestOperationsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMediaEditRecipeRequestOperationsInner.copyWith.fieldName(...)`
class _$MediaEditRecipeRequestOperationsInnerCWProxyImpl
    implements _$MediaEditRecipeRequestOperationsInnerCWProxy {
  const _$MediaEditRecipeRequestOperationsInnerCWProxyImpl(this._value);

  final MediaEditRecipeRequestOperationsInner _value;

  @override
  MediaEditRecipeRequestOperationsInner type(
    MediaEditRecipeRequestOperationsInnerTypeEnum type,
  ) => this(type: type);

  @override
  MediaEditRecipeRequestOperationsInner parameters(
    Map<String, Object> parameters,
  ) => this(parameters: parameters);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaEditRecipeRequestOperationsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaEditRecipeRequestOperationsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaEditRecipeRequestOperationsInner call({
    Object? type = const $CopyWithPlaceholder(),
    Object? parameters = const $CopyWithPlaceholder(),
  }) {
    return MediaEditRecipeRequestOperationsInner(
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as MediaEditRecipeRequestOperationsInnerTypeEnum,
      parameters: parameters == const $CopyWithPlaceholder()
          ? _value.parameters
          // ignore: cast_nullable_to_non_nullable
          : parameters as Map<String, Object>,
    );
  }
}

extension $MediaEditRecipeRequestOperationsInnerCopyWith
    on MediaEditRecipeRequestOperationsInner {
  /// Returns a callable class that can be used as follows: `instanceOfMediaEditRecipeRequestOperationsInner.copyWith(...)` or like so:`instanceOfMediaEditRecipeRequestOperationsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MediaEditRecipeRequestOperationsInnerCWProxy get copyWith =>
      _$MediaEditRecipeRequestOperationsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaEditRecipeRequestOperationsInner
_$MediaEditRecipeRequestOperationsInnerFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MediaEditRecipeRequestOperationsInner', json, (
      $checkedConvert,
    ) {
      $checkKeys(json, requiredKeys: const ['type', 'parameters']);
      final val = MediaEditRecipeRequestOperationsInner(
        type: $checkedConvert(
          'type',
          (v) => $enumDecode(
            _$MediaEditRecipeRequestOperationsInnerTypeEnumEnumMap,
            v,
          ),
        ),
        parameters: $checkedConvert(
          'parameters',
          (v) => (v as Map<String, dynamic>).map(
            (k, e) => MapEntry(k, e as Object),
          ),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MediaEditRecipeRequestOperationsInnerToJson(
  MediaEditRecipeRequestOperationsInner instance,
) => <String, dynamic>{
  'type':
      _$MediaEditRecipeRequestOperationsInnerTypeEnumEnumMap[instance.type]!,
  'parameters': instance.parameters,
};

const _$MediaEditRecipeRequestOperationsInnerTypeEnumEnumMap = {
  MediaEditRecipeRequestOperationsInnerTypeEnum.crop: 'crop',
  MediaEditRecipeRequestOperationsInnerTypeEnum.rotate: 'rotate',
  MediaEditRecipeRequestOperationsInnerTypeEnum.filter: 'filter',
  MediaEditRecipeRequestOperationsInnerTypeEnum.annotation: 'annotation',
};
