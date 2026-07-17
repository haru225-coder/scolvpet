//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/assistant_fact.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_answer.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantAnswer {
  /// Returns a new [AssistantAnswer] instance.
  AssistantAnswer({

    required  this.answer,

    required  this.intent,

    required  this.mode,

    required  this.facts,

    required  this.disclaimer,
  });

  @JsonKey(
    
    name: r'answer',
    required: true,
    includeIfNull: false,
  )


  final String answer;



  @JsonKey(
    
    name: r'intent',
    required: true,
    includeIfNull: false,
  )


  final String intent;



  @JsonKey(
    
    name: r'mode',
    required: true,
    includeIfNull: false,
  )


  final AssistantAnswerModeEnum mode;



  @JsonKey(
    
    name: r'facts',
    required: true,
    includeIfNull: false,
  )


  final List<AssistantFact> facts;



  @JsonKey(
    
    name: r'disclaimer',
    required: true,
    includeIfNull: false,
  )


  final String disclaimer;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantAnswer &&
      other.answer == answer &&
      other.intent == intent &&
      other.mode == mode &&
      other.facts == facts &&
      other.disclaimer == disclaimer;

    @override
    int get hashCode =>
        answer.hashCode +
        intent.hashCode +
        mode.hashCode +
        facts.hashCode +
        disclaimer.hashCode;

  factory AssistantAnswer.fromJson(Map<String, dynamic> json) => _$AssistantAnswerFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantAnswerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum AssistantAnswerModeEnum {
@JsonValue(r'rules')
rules(r'rules'),
@JsonValue(r'llm')
llm(r'llm');

const AssistantAnswerModeEnum(this.value);

final String value;

@override
String toString() => value;
}


