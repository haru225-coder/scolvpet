// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'miniprogram_config.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MiniprogramConfigCWProxy {
  MiniprogramConfig id(String? id);

  MiniprogramConfig displayName(String displayName);

  MiniprogramConfig appId(String? appId);

  MiniprogramConfig boundPublicSlug(String? boundPublicSlug);

  MiniprogramConfig enabled(bool enabled);

  MiniprogramConfig version(int? version);

  MiniprogramConfig updatedAt(DateTime? updatedAt);

  MiniprogramConfig pipelineNote(String pipelineNote);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MiniprogramConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MiniprogramConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  MiniprogramConfig call({
    String? id,
    String displayName,
    String? appId,
    String? boundPublicSlug,
    bool enabled,
    int? version,
    DateTime? updatedAt,
    String pipelineNote,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMiniprogramConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMiniprogramConfig.copyWith.fieldName(...)`
class _$MiniprogramConfigCWProxyImpl implements _$MiniprogramConfigCWProxy {
  const _$MiniprogramConfigCWProxyImpl(this._value);

  final MiniprogramConfig _value;

  @override
  MiniprogramConfig id(String? id) => this(id: id);

  @override
  MiniprogramConfig displayName(String displayName) =>
      this(displayName: displayName);

  @override
  MiniprogramConfig appId(String? appId) => this(appId: appId);

  @override
  MiniprogramConfig boundPublicSlug(String? boundPublicSlug) =>
      this(boundPublicSlug: boundPublicSlug);

  @override
  MiniprogramConfig enabled(bool enabled) => this(enabled: enabled);

  @override
  MiniprogramConfig version(int? version) => this(version: version);

  @override
  MiniprogramConfig updatedAt(DateTime? updatedAt) =>
      this(updatedAt: updatedAt);

  @override
  MiniprogramConfig pipelineNote(String pipelineNote) =>
      this(pipelineNote: pipelineNote);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MiniprogramConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MiniprogramConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  MiniprogramConfig call({
    Object? id = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
    Object? appId = const $CopyWithPlaceholder(),
    Object? boundPublicSlug = const $CopyWithPlaceholder(),
    Object? enabled = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
    Object? pipelineNote = const $CopyWithPlaceholder(),
  }) {
    return MiniprogramConfig(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String,
      appId: appId == const $CopyWithPlaceholder()
          ? _value.appId
          // ignore: cast_nullable_to_non_nullable
          : appId as String?,
      boundPublicSlug: boundPublicSlug == const $CopyWithPlaceholder()
          ? _value.boundPublicSlug
          // ignore: cast_nullable_to_non_nullable
          : boundPublicSlug as String?,
      enabled: enabled == const $CopyWithPlaceholder()
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as bool,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int?,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime?,
      pipelineNote: pipelineNote == const $CopyWithPlaceholder()
          ? _value.pipelineNote
          // ignore: cast_nullable_to_non_nullable
          : pipelineNote as String,
    );
  }
}

extension $MiniprogramConfigCopyWith on MiniprogramConfig {
  /// Returns a callable class that can be used as follows: `instanceOfMiniprogramConfig.copyWith(...)` or like so:`instanceOfMiniprogramConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MiniprogramConfigCWProxy get copyWith =>
      _$MiniprogramConfigCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MiniprogramConfig _$MiniprogramConfigFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'MiniprogramConfig',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['display_name', 'enabled', 'pipeline_note'],
        );
        final val = MiniprogramConfig(
          id: $checkedConvert('id', (v) => v as String?),
          displayName: $checkedConvert('display_name', (v) => v as String),
          appId: $checkedConvert('app_id', (v) => v as String?),
          boundPublicSlug: $checkedConvert(
            'bound_public_slug',
            (v) => v as String?,
          ),
          enabled: $checkedConvert('enabled', (v) => v as bool),
          version: $checkedConvert('version', (v) => (v as num?)?.toInt()),
          updatedAt: $checkedConvert(
            'updated_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          pipelineNote: $checkedConvert('pipeline_note', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {
        'displayName': 'display_name',
        'appId': 'app_id',
        'boundPublicSlug': 'bound_public_slug',
        'updatedAt': 'updated_at',
        'pipelineNote': 'pipeline_note',
      },
    );

Map<String, dynamic> _$MiniprogramConfigToJson(MiniprogramConfig instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'display_name': instance.displayName,
      'app_id': ?instance.appId,
      'bound_public_slug': ?instance.boundPublicSlug,
      'enabled': instance.enabled,
      'version': ?instance.version,
      'updated_at': ?instance.updatedAt?.toIso8601String(),
      'pipeline_note': instance.pipelineNote,
    };
