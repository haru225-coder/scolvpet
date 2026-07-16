// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enclosure_update_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EnclosureUpdateRequestCWProxy {
  EnclosureUpdateRequest code(String? code);

  EnclosureUpdateRequest rackCode(String? rackCode);

  EnclosureUpdateRequest levelCode(String? levelCode);

  EnclosureUpdateRequest dimensions(EnclosureDimensions? dimensions);

  EnclosureUpdateRequest capacity(int? capacity);

  EnclosureUpdateRequest equipment(List<String>? equipment);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureUpdateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureUpdateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureUpdateRequest call({
    String? code,
    String? rackCode,
    String? levelCode,
    EnclosureDimensions? dimensions,
    int? capacity,
    List<String>? equipment,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEnclosureUpdateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEnclosureUpdateRequest.copyWith.fieldName(...)`
class _$EnclosureUpdateRequestCWProxyImpl
    implements _$EnclosureUpdateRequestCWProxy {
  const _$EnclosureUpdateRequestCWProxyImpl(this._value);

  final EnclosureUpdateRequest _value;

  @override
  EnclosureUpdateRequest code(String? code) => this(code: code);

  @override
  EnclosureUpdateRequest rackCode(String? rackCode) => this(rackCode: rackCode);

  @override
  EnclosureUpdateRequest levelCode(String? levelCode) =>
      this(levelCode: levelCode);

  @override
  EnclosureUpdateRequest dimensions(EnclosureDimensions? dimensions) =>
      this(dimensions: dimensions);

  @override
  EnclosureUpdateRequest capacity(int? capacity) => this(capacity: capacity);

  @override
  EnclosureUpdateRequest equipment(List<String>? equipment) =>
      this(equipment: equipment);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureUpdateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureUpdateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureUpdateRequest call({
    Object? code = const $CopyWithPlaceholder(),
    Object? rackCode = const $CopyWithPlaceholder(),
    Object? levelCode = const $CopyWithPlaceholder(),
    Object? dimensions = const $CopyWithPlaceholder(),
    Object? capacity = const $CopyWithPlaceholder(),
    Object? equipment = const $CopyWithPlaceholder(),
  }) {
    return EnclosureUpdateRequest(
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String?,
      rackCode: rackCode == const $CopyWithPlaceholder()
          ? _value.rackCode
          // ignore: cast_nullable_to_non_nullable
          : rackCode as String?,
      levelCode: levelCode == const $CopyWithPlaceholder()
          ? _value.levelCode
          // ignore: cast_nullable_to_non_nullable
          : levelCode as String?,
      dimensions: dimensions == const $CopyWithPlaceholder()
          ? _value.dimensions
          // ignore: cast_nullable_to_non_nullable
          : dimensions as EnclosureDimensions?,
      capacity: capacity == const $CopyWithPlaceholder()
          ? _value.capacity
          // ignore: cast_nullable_to_non_nullable
          : capacity as int?,
      equipment: equipment == const $CopyWithPlaceholder()
          ? _value.equipment
          // ignore: cast_nullable_to_non_nullable
          : equipment as List<String>?,
    );
  }
}

extension $EnclosureUpdateRequestCopyWith on EnclosureUpdateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfEnclosureUpdateRequest.copyWith(...)` or like so:`instanceOfEnclosureUpdateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EnclosureUpdateRequestCWProxy get copyWith =>
      _$EnclosureUpdateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnclosureUpdateRequest _$EnclosureUpdateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'EnclosureUpdateRequest',
  json,
  ($checkedConvert) {
    final val = EnclosureUpdateRequest(
      code: $checkedConvert('code', (v) => v as String?),
      rackCode: $checkedConvert('rack_code', (v) => v as String?),
      levelCode: $checkedConvert('level_code', (v) => v as String?),
      dimensions: $checkedConvert(
        'dimensions',
        (v) => v == null
            ? null
            : EnclosureDimensions.fromJson(v as Map<String, dynamic>),
      ),
      capacity: $checkedConvert('capacity', (v) => (v as num?)?.toInt()),
      equipment: $checkedConvert(
        'equipment',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {'rackCode': 'rack_code', 'levelCode': 'level_code'},
);

Map<String, dynamic> _$EnclosureUpdateRequestToJson(
  EnclosureUpdateRequest instance,
) => <String, dynamic>{
  'code': ?instance.code,
  'rack_code': ?instance.rackCode,
  'level_code': ?instance.levelCode,
  'dimensions': ?instance.dimensions?.toJson(),
  'capacity': ?instance.capacity,
  'equipment': ?instance.equipment,
};
