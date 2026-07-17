//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_ask_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantAskRequest {
  /// Returns a new [AssistantAskRequest] instance.
  AssistantAskRequest({

    required  this.question,

     this.preferLlm = false,
  });

  @JsonKey(
    
    name: r'question',
    required: true,
    includeIfNull: false,
  )


  final String question;



  @JsonKey(
    defaultValue: false,
    name: r'prefer_llm',
    required: false,
    includeIfNull: false,
  )


  final bool? preferLlm;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantAskRequest &&
      other.question == question &&
      other.preferLlm == preferLlm;

    @override
    int get hashCode =>
        question.hashCode +
        preferLlm.hashCode;

  factory AssistantAskRequest.fromJson(Map<String, dynamic> json) => _$AssistantAskRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantAskRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

