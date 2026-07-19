//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/growth_script_section.dart';
import 'package:scolvpet_api/src/model/growth_public_fact.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'growth_script.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GrowthScript {
  /// Returns a new [GrowthScript] instance.
  GrowthScript({

    required  this.title,

    required  this.hook,

    required  this.coverText,

    required  this.sections,

    required  this.caption,

    required  this.hashtags,

    required  this.cta,

    required  this.facts,
  });

  @JsonKey(

    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(

    name: r'hook',
    required: true,
    includeIfNull: false,
  )


  final String hook;



  @JsonKey(

    name: r'cover_text',
    required: true,
    includeIfNull: false,
  )


  final String coverText;



  @JsonKey(

    name: r'sections',
    required: true,
    includeIfNull: false,
  )


  final List<GrowthScriptSection> sections;



  @JsonKey(

    name: r'caption',
    required: true,
    includeIfNull: false,
  )


  final String caption;



  @JsonKey(

    name: r'hashtags',
    required: true,
    includeIfNull: false,
  )


  final List<String> hashtags;



  @JsonKey(

    name: r'cta',
    required: true,
    includeIfNull: false,
  )


  final String cta;



  @JsonKey(

    name: r'facts',
    required: true,
    includeIfNull: false,
  )


  final List<GrowthPublicFact> facts;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GrowthScript &&
      other.title == title &&
      other.hook == hook &&
      other.coverText == coverText &&
      other.sections == sections &&
      other.caption == caption &&
      other.hashtags == hashtags &&
      other.cta == cta &&
      other.facts == facts;

    @override
    int get hashCode =>
        title.hashCode +
        hook.hashCode +
        coverText.hashCode +
        sections.hashCode +
        caption.hashCode +
        hashtags.hashCode +
        cta.hashCode +
        facts.hashCode;

  factory GrowthScript.fromJson(Map<String, dynamic> json) => _$GrowthScriptFromJson(json);

  Map<String, dynamic> toJson() => _$GrowthScriptToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
