//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'growth_script_section.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GrowthScriptSection {
  /// Returns a new [GrowthScriptSection] instance.
  GrowthScriptSection({

    required  this.order,

    required  this.durationSeconds,

    required  this.shot,

    required  this.voiceover,

    required  this.overlay,
  });

  @JsonKey(

    name: r'order',
    required: true,
    includeIfNull: false,
  )


  final int order;



  @JsonKey(

    name: r'duration_seconds',
    required: true,
    includeIfNull: false,
  )


  final int durationSeconds;



  @JsonKey(

    name: r'shot',
    required: true,
    includeIfNull: false,
  )


  final String shot;



  @JsonKey(

    name: r'voiceover',
    required: true,
    includeIfNull: false,
  )


  final String voiceover;



  @JsonKey(

    name: r'overlay',
    required: true,
    includeIfNull: false,
  )


  final String overlay;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GrowthScriptSection &&
      other.order == order &&
      other.durationSeconds == durationSeconds &&
      other.shot == shot &&
      other.voiceover == voiceover &&
      other.overlay == overlay;

    @override
    int get hashCode =>
        order.hashCode +
        durationSeconds.hashCode +
        shot.hashCode +
        voiceover.hashCode +
        overlay.hashCode;

  factory GrowthScriptSection.fromJson(Map<String, dynamic> json) => _$GrowthScriptSectionFromJson(json);

  Map<String, dynamic> toJson() => _$GrowthScriptSectionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
