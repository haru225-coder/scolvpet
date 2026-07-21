//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_chat_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantChatRequest {
  /// Returns a new [AssistantChatRequest] instance.
  AssistantChatRequest({

     this.sessionId,

    required  this.message,

     this.preferLlm = true,
  });

  @JsonKey(

    name: r'session_id',
    required: false,
    includeIfNull: false,
  )


  final String? sessionId;



  @JsonKey(

    name: r'message',
    required: true,
    includeIfNull: false,
  )


  final String message;



  @JsonKey(
    defaultValue: true,
    name: r'prefer_llm',
    required: false,
    includeIfNull: false,
  )


  final bool? preferLlm;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantChatRequest &&
      other.sessionId == sessionId &&
      other.message == message &&
      other.preferLlm == preferLlm;

    @override
    int get hashCode =>
        (sessionId == null ? 0 : sessionId.hashCode) +
        message.hashCode +
        preferLlm.hashCode;

  factory AssistantChatRequest.fromJson(Map<String, dynamic> json) => _$AssistantChatRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantChatRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
