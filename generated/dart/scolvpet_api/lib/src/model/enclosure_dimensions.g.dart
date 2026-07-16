// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enclosure_dimensions.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EnclosureDimensionsCWProxy {
  EnclosureDimensions length(int length);

  EnclosureDimensions width(int width);

  EnclosureDimensions height(int height);

  EnclosureDimensions unit(EnclosureDimensionsUnitEnum? unit);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureDimensions(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureDimensions(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureDimensions call({
    int length,
    int width,
    int height,
    EnclosureDimensionsUnitEnum? unit,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEnclosureDimensions.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEnclosureDimensions.copyWith.fieldName(...)`
class _$EnclosureDimensionsCWProxyImpl implements _$EnclosureDimensionsCWProxy {
  const _$EnclosureDimensionsCWProxyImpl(this._value);

  final EnclosureDimensions _value;

  @override
  EnclosureDimensions length(int length) => this(length: length);

  @override
  EnclosureDimensions width(int width) => this(width: width);

  @override
  EnclosureDimensions height(int height) => this(height: height);

  @override
  EnclosureDimensions unit(EnclosureDimensionsUnitEnum? unit) =>
      this(unit: unit);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureDimensions(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureDimensions(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureDimensions call({
    Object? length = const $CopyWithPlaceholder(),
    Object? width = const $CopyWithPlaceholder(),
    Object? height = const $CopyWithPlaceholder(),
    Object? unit = const $CopyWithPlaceholder(),
  }) {
    return EnclosureDimensions(
      length: length == const $CopyWithPlaceholder()
          ? _value.length
          // ignore: cast_nullable_to_non_nullable
          : length as int,
      width: width == const $CopyWithPlaceholder()
          ? _value.width
          // ignore: cast_nullable_to_non_nullable
          : width as int,
      height: height == const $CopyWithPlaceholder()
          ? _value.height
          // ignore: cast_nullable_to_non_nullable
          : height as int,
      unit: unit == const $CopyWithPlaceholder()
          ? _value.unit
          // ignore: cast_nullable_to_non_nullable
          : unit as EnclosureDimensionsUnitEnum?,
    );
  }
}

extension $EnclosureDimensionsCopyWith on EnclosureDimensions {
  /// Returns a callable class that can be used as follows: `instanceOfEnclosureDimensions.copyWith(...)` or like so:`instanceOfEnclosureDimensions.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EnclosureDimensionsCWProxy get copyWith =>
      _$EnclosureDimensionsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnclosureDimensions _$EnclosureDimensionsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('EnclosureDimensions', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['length', 'width', 'height']);
      final val = EnclosureDimensions(
        length: $checkedConvert('length', (v) => (v as num).toInt()),
        width: $checkedConvert('width', (v) => (v as num).toInt()),
        height: $checkedConvert('height', (v) => (v as num).toInt()),
        unit: $checkedConvert(
          'unit',
          (v) => $enumDecodeNullable(_$EnclosureDimensionsUnitEnumEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$EnclosureDimensionsToJson(
  EnclosureDimensions instance,
) => <String, dynamic>{
  'length': instance.length,
  'width': instance.width,
  'height': instance.height,
  'unit': ?_$EnclosureDimensionsUnitEnumEnumMap[instance.unit],
};

const _$EnclosureDimensionsUnitEnumEnumMap = {
  EnclosureDimensionsUnitEnum.mm: 'mm',
};
