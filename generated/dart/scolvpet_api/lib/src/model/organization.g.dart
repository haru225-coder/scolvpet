// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OrganizationCWProxy {
  Organization id(String id);

  Organization ownerId(String ownerId);

  Organization name(String name);

  Organization mode(OrganizationModeEnum mode);

  Organization timezone(String timezone);

  Organization weightUnit(OrganizationWeightUnitEnum weightUnit);

  Organization version(int version);

  Organization createdAt(DateTime createdAt);

  Organization updatedAt(DateTime updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Organization(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Organization(...).copyWith(id: 12, name: "My name")
  /// ````
  Organization call({
    String id,
    String ownerId,
    String name,
    OrganizationModeEnum mode,
    String timezone,
    OrganizationWeightUnitEnum weightUnit,
    int version,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOrganization.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOrganization.copyWith.fieldName(...)`
class _$OrganizationCWProxyImpl implements _$OrganizationCWProxy {
  const _$OrganizationCWProxyImpl(this._value);

  final Organization _value;

  @override
  Organization id(String id) => this(id: id);

  @override
  Organization ownerId(String ownerId) => this(ownerId: ownerId);

  @override
  Organization name(String name) => this(name: name);

  @override
  Organization mode(OrganizationModeEnum mode) => this(mode: mode);

  @override
  Organization timezone(String timezone) => this(timezone: timezone);

  @override
  Organization weightUnit(OrganizationWeightUnitEnum weightUnit) =>
      this(weightUnit: weightUnit);

  @override
  Organization version(int version) => this(version: version);

  @override
  Organization createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  Organization updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Organization(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Organization(...).copyWith(id: 12, name: "My name")
  /// ````
  Organization call({
    Object? id = const $CopyWithPlaceholder(),
    Object? ownerId = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? mode = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
    Object? weightUnit = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return Organization(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      ownerId: ownerId == const $CopyWithPlaceholder()
          ? _value.ownerId
          // ignore: cast_nullable_to_non_nullable
          : ownerId as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      mode: mode == const $CopyWithPlaceholder()
          ? _value.mode
          // ignore: cast_nullable_to_non_nullable
          : mode as OrganizationModeEnum,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String,
      weightUnit: weightUnit == const $CopyWithPlaceholder()
          ? _value.weightUnit
          // ignore: cast_nullable_to_non_nullable
          : weightUnit as OrganizationWeightUnitEnum,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
    );
  }
}

extension $OrganizationCopyWith on Organization {
  /// Returns a callable class that can be used as follows: `instanceOfOrganization.copyWith(...)` or like so:`instanceOfOrganization.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OrganizationCWProxy get copyWith => _$OrganizationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Organization _$OrganizationFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'Organization',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'owner_id',
            'name',
            'mode',
            'timezone',
            'weight_unit',
            'version',
            'created_at',
            'updated_at',
          ],
        );
        final val = Organization(
          id: $checkedConvert('id', (v) => v as String),
          ownerId: $checkedConvert('owner_id', (v) => v as String),
          name: $checkedConvert('name', (v) => v as String),
          mode: $checkedConvert(
            'mode',
            (v) => $enumDecode(_$OrganizationModeEnumEnumMap, v),
          ),
          timezone: $checkedConvert(
            'timezone',
            (v) => v as String? ?? 'Asia/Shanghai',
          ),
          weightUnit: $checkedConvert(
            'weight_unit',
            (v) => $enumDecode(_$OrganizationWeightUnitEnumEnumMap, v),
          ),
          version: $checkedConvert('version', (v) => (v as num).toInt()),
          createdAt: $checkedConvert(
            'created_at',
            (v) => DateTime.parse(v as String),
          ),
          updatedAt: $checkedConvert(
            'updated_at',
            (v) => DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'ownerId': 'owner_id',
        'weightUnit': 'weight_unit',
        'createdAt': 'created_at',
        'updatedAt': 'updated_at',
      },
    );

Map<String, dynamic> _$OrganizationToJson(Organization instance) =>
    <String, dynamic>{
      'id': instance.id,
      'owner_id': instance.ownerId,
      'name': instance.name,
      'mode': _$OrganizationModeEnumEnumMap[instance.mode]!,
      'timezone': instance.timezone,
      'weight_unit': _$OrganizationWeightUnitEnumEnumMap[instance.weightUnit]!,
      'version': instance.version,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$OrganizationModeEnumEnumMap = {
  OrganizationModeEnum.personal: 'personal',
  OrganizationModeEnum.professional: 'professional',
};

const _$OrganizationWeightUnitEnumEnumMap = {OrganizationWeightUnitEnum.g: 'g'};
