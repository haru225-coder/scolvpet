// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enclosure_create_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EnclosureCreateRequestCWProxy {
  EnclosureCreateRequest code(String code);

  EnclosureCreateRequest rackCode(String? rackCode);

  EnclosureCreateRequest levelCode(String? levelCode);

  EnclosureCreateRequest dimensions(EnclosureDimensions? dimensions);

  EnclosureCreateRequest capacity(int? capacity);

  EnclosureCreateRequest equipment(List<String>? equipment);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureCreateRequest call({
    String code,
    String? rackCode,
    String? levelCode,
    EnclosureDimensions? dimensions,
    int? capacity,
    List<String>? equipment,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEnclosureCreateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEnclosureCreateRequest.copyWith.fieldName(...)`
class _$EnclosureCreateRequestCWProxyImpl
    implements _$EnclosureCreateRequestCWProxy {
  const _$EnclosureCreateRequestCWProxyImpl(this._value);

  final EnclosureCreateRequest _value;

  @override
  EnclosureCreateRequest code(String code) => this(code: code);

  @override
  EnclosureCreateRequest rackCode(String? rackCode) => this(rackCode: rackCode);

  @override
  EnclosureCreateRequest levelCode(String? levelCode) =>
      this(levelCode: levelCode);

  @override
  EnclosureCreateRequest dimensions(EnclosureDimensions? dimensions) =>
      this(dimensions: dimensions);

  @override
  EnclosureCreateRequest capacity(int? capacity) => this(capacity: capacity);

  @override
  EnclosureCreateRequest equipment(List<String>? equipment) =>
      this(equipment: equipment);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureCreateRequest call({
    Object? code = const $CopyWithPlaceholder(),
    Object? rackCode = const $CopyWithPlaceholder(),
    Object? levelCode = const $CopyWithPlaceholder(),
    Object? dimensions = const $CopyWithPlaceholder(),
    Object? capacity = const $CopyWithPlaceholder(),
    Object? equipment = const $CopyWithPlaceholder(),
  }) {
    return EnclosureCreateRequest(
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
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

extension $EnclosureCreateRequestCopyWith on EnclosureCreateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfEnclosureCreateRequest.copyWith(...)` or like so:`instanceOfEnclosureCreateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EnclosureCreateRequestCWProxy get copyWith =>
      _$EnclosureCreateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnclosureCreateRequest _$EnclosureCreateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'EnclosureCreateRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['code']);
    final val = EnclosureCreateRequest(
      code: $checkedConvert('code', (v) => v as String),
      rackCode: $checkedConvert('rack_code', (v) => v as String?),
      levelCode: $checkedConvert('level_code', (v) => v as String?),
      dimensions: $checkedConvert(
        'dimensions',
        (v) => v == null
            ? null
            : EnclosureDimensions.fromJson(v as Map<String, dynamic>),
      ),
      capacity: $checkedConvert('capacity', (v) => (v as num?)?.toInt() ?? 1),
      equipment: $checkedConvert(
        'equipment',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {'rackCode': 'rack_code', 'levelCode': 'level_code'},
);

Map<String, dynamic> _$EnclosureCreateRequestToJson(
  EnclosureCreateRequest instance,
) => <String, dynamic>{
  'code': instance.code,
  'rack_code': ?instance.rackCode,
  'level_code': ?instance.levelCode,
  'dimensions': ?instance.dimensions?.toJson(),
  'capacity': ?instance.capacity,
  'equipment': ?instance.equipment,
};
