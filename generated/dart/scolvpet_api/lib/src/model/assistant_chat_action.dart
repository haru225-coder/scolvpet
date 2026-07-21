//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_chat_action.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantChatAction {
  /// Returns a new [AssistantChatAction] instance.
  AssistantChatAction({

     this.actionId,

    required  this.type,

    required  this.label,

    required  this.summary,

    required  this.requiresConfirmation,

    required  this.payload,
  });

  @JsonKey(

    name: r'action_id',
    required: false,
    includeIfNull: false,
  )


  final String? actionId;



  @JsonKey(

    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final String type;



  @JsonKey(

    name: r'label',
    required: true,
    includeIfNull: false,
  )


  final String label;



  @JsonKey(

    name: r'summary',
    required: true,
    includeIfNull: false,
  )


  final String summary;



  @JsonKey(

    name: r'requires_confirmation',
    required: true,
    includeIfNull: false,
  )


  final bool requiresConfirmation;



  @JsonKey(

    name: r'payload',
    required: true,
    includeIfNull: false,
  )


  final Map<String, Object> payload;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantChatAction &&
      other.actionId == actionId &&
      other.type == type &&
      other.label == label &&
      other.summary == summary &&
      other.requiresConfirmation == requiresConfirmation &&
      other.payload == payload;

    @override
    int get hashCode =>
        (actionId == null ? 0 : actionId.hashCode) +
        type.hashCode +
        label.hashCode +
        summary.hashCode +
        requiresConfirmation.hashCode +
        payload.hashCode;

  factory AssistantChatAction.fromJson(Map<String, dynamic> json) => _$AssistantChatActionFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantChatActionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
