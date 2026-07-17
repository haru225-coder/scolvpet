//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_capabilities.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantCapabilities {
  /// Returns a new [AssistantCapabilities] instance.
  AssistantCapabilities({

    required  this.intents,

    required  this.modeDefault,

    required  this.llmAvailable,

    required  this.disclaimer,
  });

  @JsonKey(
    
    name: r'intents',
    required: true,
    includeIfNull: false,
  )


  final List<String> intents;



  @JsonKey(
    
    name: r'mode_default',
    required: true,
    includeIfNull: false,
  )


  final AssistantCapabilitiesModeDefaultEnum modeDefault;



  @JsonKey(
    
    name: r'llm_available',
    required: true,
    includeIfNull: false,
  )


  final bool llmAvailable;



  @JsonKey(
    
    name: r'disclaimer',
    required: true,
    includeIfNull: false,
  )


  final String disclaimer;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantCapabilities &&
      other.intents == intents &&
      other.modeDefault == modeDefault &&
      other.llmAvailable == llmAvailable &&
      other.disclaimer == disclaimer;

    @override
    int get hashCode =>
        intents.hashCode +
        modeDefault.hashCode +
        llmAvailable.hashCode +
        disclaimer.hashCode;

  factory AssistantCapabilities.fromJson(Map<String, dynamic> json) => _$AssistantCapabilitiesFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantCapabilitiesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum AssistantCapabilitiesModeDefaultEnum {
@JsonValue(r'rules')
rules(r'rules');

const AssistantCapabilitiesModeDefaultEnum(this.value);

final String value;

@override
String toString() => value;
}


