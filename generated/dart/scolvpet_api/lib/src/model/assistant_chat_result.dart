//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/assistant_chat_action.dart';
import 'package:scolvpet_api/src/model/assistant_fact.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_chat_result.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantChatResult {
  /// Returns a new [AssistantChatResult] instance.
  AssistantChatResult({

    required  this.sessionId,

    required  this.messageId,

    required  this.answer,

    required  this.intent,

    required  this.mode,

    required  this.facts,

    required  this.actions,

    required  this.disclaimer,
  });

  @JsonKey(

    name: r'session_id',
    required: true,
    includeIfNull: false,
  )


  final String sessionId;



  @JsonKey(

    name: r'message_id',
    required: true,
    includeIfNull: false,
  )


  final String messageId;



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


  final AssistantChatResultModeEnum mode;



  @JsonKey(

    name: r'facts',
    required: true,
    includeIfNull: false,
  )


  final List<AssistantFact> facts;



  @JsonKey(

    name: r'actions',
    required: true,
    includeIfNull: false,
  )


  final List<AssistantChatAction> actions;



  @JsonKey(

    name: r'disclaimer',
    required: true,
    includeIfNull: false,
  )


  final String disclaimer;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantChatResult &&
      other.sessionId == sessionId &&
      other.messageId == messageId &&
      other.answer == answer &&
      other.intent == intent &&
      other.mode == mode &&
      other.facts == facts &&
      other.actions == actions &&
      other.disclaimer == disclaimer;

    @override
    int get hashCode =>
        sessionId.hashCode +
        messageId.hashCode +
        answer.hashCode +
        intent.hashCode +
        mode.hashCode +
        facts.hashCode +
        actions.hashCode +
        disclaimer.hashCode;

  factory AssistantChatResult.fromJson(Map<String, dynamic> json) => _$AssistantChatResultFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantChatResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum AssistantChatResultModeEnum {
@JsonValue(r'rules')
rules(r'rules'),
@JsonValue(r'llm')
llm(r'llm');

const AssistantChatResultModeEnum(this.value);

final String value;

@override
String toString() => value;
}
