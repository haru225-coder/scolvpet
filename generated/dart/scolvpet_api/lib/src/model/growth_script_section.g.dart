// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_script_section.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GrowthScriptSectionCWProxy {
  GrowthScriptSection order(int order);

  GrowthScriptSection durationSeconds(int durationSeconds);

  GrowthScriptSection shot(String shot);

  GrowthScriptSection voiceover(String voiceover);

  GrowthScriptSection overlay(String overlay);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrowthScriptSection(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrowthScriptSection(...).copyWith(id: 12, name: "My name")
  /// ````
  GrowthScriptSection call({
    int order,
    int durationSeconds,
    String shot,
    String voiceover,
    String overlay,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGrowthScriptSection.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGrowthScriptSection.copyWith.fieldName(...)`
class _$GrowthScriptSectionCWProxyImpl implements _$GrowthScriptSectionCWProxy {
  const _$GrowthScriptSectionCWProxyImpl(this._value);

  final GrowthScriptSection _value;

  @override
  GrowthScriptSection order(int order) => this(order: order);

  @override
  GrowthScriptSection durationSeconds(int durationSeconds) =>
      this(durationSeconds: durationSeconds);

  @override
  GrowthScriptSection shot(String shot) => this(shot: shot);

  @override
  GrowthScriptSection voiceover(String voiceover) => this(voiceover: voiceover);

  @override
  GrowthScriptSection overlay(String overlay) => this(overlay: overlay);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrowthScriptSection(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrowthScriptSection(...).copyWith(id: 12, name: "My name")
  /// ````
  GrowthScriptSection call({
    Object? order = const $CopyWithPlaceholder(),
    Object? durationSeconds = const $CopyWithPlaceholder(),
    Object? shot = const $CopyWithPlaceholder(),
    Object? voiceover = const $CopyWithPlaceholder(),
    Object? overlay = const $CopyWithPlaceholder(),
  }) {
    return GrowthScriptSection(
      order: order == const $CopyWithPlaceholder()
          ? _value.order
          // ignore: cast_nullable_to_non_nullable
          : order as int,
      durationSeconds: durationSeconds == const $CopyWithPlaceholder()
          ? _value.durationSeconds
          // ignore: cast_nullable_to_non_nullable
          : durationSeconds as int,
      shot: shot == const $CopyWithPlaceholder()
          ? _value.shot
          // ignore: cast_nullable_to_non_nullable
          : shot as String,
      voiceover: voiceover == const $CopyWithPlaceholder()
          ? _value.voiceover
          // ignore: cast_nullable_to_non_nullable
          : voiceover as String,
      overlay: overlay == const $CopyWithPlaceholder()
          ? _value.overlay
          // ignore: cast_nullable_to_non_nullable
          : overlay as String,
    );
  }
}

extension $GrowthScriptSectionCopyWith on GrowthScriptSection {
  /// Returns a callable class that can be used as follows: `instanceOfGrowthScriptSection.copyWith(...)` or like so:`instanceOfGrowthScriptSection.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GrowthScriptSectionCWProxy get copyWith =>
      _$GrowthScriptSectionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrowthScriptSection _$GrowthScriptSectionFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'GrowthScriptSection',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'order',
            'duration_seconds',
            'shot',
            'voiceover',
            'overlay',
          ],
        );
        final val = GrowthScriptSection(
          order: $checkedConvert('order', (v) => (v as num).toInt()),
          durationSeconds: $checkedConvert(
            'duration_seconds',
            (v) => (v as num).toInt(),
          ),
          shot: $checkedConvert('shot', (v) => v as String),
          voiceover: $checkedConvert('voiceover', (v) => v as String),
          overlay: $checkedConvert('overlay', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {'durationSeconds': 'duration_seconds'},
    );

Map<String, dynamic> _$GrowthScriptSectionToJson(
  GrowthScriptSection instance,
) => <String, dynamic>{
  'order': instance.order,
  'duration_seconds': instance.durationSeconds,
  'shot': instance.shot,
  'voiceover': instance.voiceover,
  'overlay': instance.overlay,
};
