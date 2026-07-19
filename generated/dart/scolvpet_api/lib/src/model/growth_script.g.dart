// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_script.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GrowthScriptCWProxy {
  GrowthScript title(String title);

  GrowthScript hook(String hook);

  GrowthScript coverText(String coverText);

  GrowthScript sections(List<GrowthScriptSection> sections);

  GrowthScript caption(String caption);

  GrowthScript hashtags(List<String> hashtags);

  GrowthScript cta(String cta);

  GrowthScript facts(List<GrowthPublicFact> facts);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrowthScript(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrowthScript(...).copyWith(id: 12, name: "My name")
  /// ````
  GrowthScript call({
    String title,
    String hook,
    String coverText,
    List<GrowthScriptSection> sections,
    String caption,
    List<String> hashtags,
    String cta,
    List<GrowthPublicFact> facts,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGrowthScript.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGrowthScript.copyWith.fieldName(...)`
class _$GrowthScriptCWProxyImpl implements _$GrowthScriptCWProxy {
  const _$GrowthScriptCWProxyImpl(this._value);

  final GrowthScript _value;

  @override
  GrowthScript title(String title) => this(title: title);

  @override
  GrowthScript hook(String hook) => this(hook: hook);

  @override
  GrowthScript coverText(String coverText) => this(coverText: coverText);

  @override
  GrowthScript sections(List<GrowthScriptSection> sections) =>
      this(sections: sections);

  @override
  GrowthScript caption(String caption) => this(caption: caption);

  @override
  GrowthScript hashtags(List<String> hashtags) => this(hashtags: hashtags);

  @override
  GrowthScript cta(String cta) => this(cta: cta);

  @override
  GrowthScript facts(List<GrowthPublicFact> facts) => this(facts: facts);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrowthScript(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrowthScript(...).copyWith(id: 12, name: "My name")
  /// ````
  GrowthScript call({
    Object? title = const $CopyWithPlaceholder(),
    Object? hook = const $CopyWithPlaceholder(),
    Object? coverText = const $CopyWithPlaceholder(),
    Object? sections = const $CopyWithPlaceholder(),
    Object? caption = const $CopyWithPlaceholder(),
    Object? hashtags = const $CopyWithPlaceholder(),
    Object? cta = const $CopyWithPlaceholder(),
    Object? facts = const $CopyWithPlaceholder(),
  }) {
    return GrowthScript(
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      hook: hook == const $CopyWithPlaceholder()
          ? _value.hook
          // ignore: cast_nullable_to_non_nullable
          : hook as String,
      coverText: coverText == const $CopyWithPlaceholder()
          ? _value.coverText
          // ignore: cast_nullable_to_non_nullable
          : coverText as String,
      sections: sections == const $CopyWithPlaceholder()
          ? _value.sections
          // ignore: cast_nullable_to_non_nullable
          : sections as List<GrowthScriptSection>,
      caption: caption == const $CopyWithPlaceholder()
          ? _value.caption
          // ignore: cast_nullable_to_non_nullable
          : caption as String,
      hashtags: hashtags == const $CopyWithPlaceholder()
          ? _value.hashtags
          // ignore: cast_nullable_to_non_nullable
          : hashtags as List<String>,
      cta: cta == const $CopyWithPlaceholder()
          ? _value.cta
          // ignore: cast_nullable_to_non_nullable
          : cta as String,
      facts: facts == const $CopyWithPlaceholder()
          ? _value.facts
          // ignore: cast_nullable_to_non_nullable
          : facts as List<GrowthPublicFact>,
    );
  }
}

extension $GrowthScriptCopyWith on GrowthScript {
  /// Returns a callable class that can be used as follows: `instanceOfGrowthScript.copyWith(...)` or like so:`instanceOfGrowthScript.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GrowthScriptCWProxy get copyWith => _$GrowthScriptCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrowthScript _$GrowthScriptFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GrowthScript', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'title',
          'hook',
          'cover_text',
          'sections',
          'caption',
          'hashtags',
          'cta',
          'facts',
        ],
      );
      final val = GrowthScript(
        title: $checkedConvert('title', (v) => v as String),
        hook: $checkedConvert('hook', (v) => v as String),
        coverText: $checkedConvert('cover_text', (v) => v as String),
        sections: $checkedConvert(
          'sections',
          (v) => (v as List<dynamic>)
              .map(
                (e) => GrowthScriptSection.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
        caption: $checkedConvert('caption', (v) => v as String),
        hashtags: $checkedConvert(
          'hashtags',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        cta: $checkedConvert('cta', (v) => v as String),
        facts: $checkedConvert(
          'facts',
          (v) => (v as List<dynamic>)
              .map((e) => GrowthPublicFact.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'coverText': 'cover_text'});

Map<String, dynamic> _$GrowthScriptToJson(GrowthScript instance) =>
    <String, dynamic>{
      'title': instance.title,
      'hook': instance.hook,
      'cover_text': instance.coverText,
      'sections': instance.sections.map((e) => e.toJson()).toList(),
      'caption': instance.caption,
      'hashtags': instance.hashtags,
      'cta': instance.cta,
      'facts': instance.facts.map((e) => e.toJson()).toList(),
    };
