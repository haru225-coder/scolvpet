//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_message.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantMessage {
  /// Returns a new [AssistantMessage] instance.
  AssistantMessage({

    required  this.id,

    required  this.ownerId,

    required  this.sessionId,

    required  this.role,

    required  this.content,

     this.mode,

     this.factsJson,

    required  this.createdAt,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(

    name: r'owner_id',
    required: true,
    includeIfNull: false,
  )


  final String ownerId;



  @JsonKey(

    name: r'session_id',
    required: true,
    includeIfNull: false,
  )


  final String sessionId;



  @JsonKey(

    name: r'role',
    required: true,
    includeIfNull: false,
  )


  final AssistantMessageRoleEnum role;



  @JsonKey(

    name: r'content',
    required: true,
    includeIfNull: false,
  )


  final String content;



  @JsonKey(

    name: r'mode',
    required: false,
    includeIfNull: false,
  )


  final AssistantMessageModeEnum? mode;



  @JsonKey(

    name: r'facts_json',
    required: false,
    includeIfNull: false,
  )


  final List<Object>? factsJson;



  @JsonKey(

    name: r'created_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantMessage &&
      other.id == id &&
      other.ownerId == ownerId &&
      other.sessionId == sessionId &&
      other.role == role &&
      other.content == content &&
      other.mode == mode &&
      other.factsJson == factsJson &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        ownerId.hashCode +
        sessionId.hashCode +
        role.hashCode +
        content.hashCode +
        (mode == null ? 0 : mode.hashCode) +
        factsJson.hashCode +
        createdAt.hashCode;

  factory AssistantMessage.fromJson(Map<String, dynamic> json) => _$AssistantMessageFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantMessageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum AssistantMessageRoleEnum {
@JsonValue(r'user')
user(r'user'),
@JsonValue(r'assistant')
assistant(r'assistant'),
@JsonValue(r'system')
system(r'system');

const AssistantMessageRoleEnum(this.value);

final String value;

@override
String toString() => value;
}



enum AssistantMessageModeEnum {
@JsonValue(r'rules')
rules(r'rules'),
@JsonValue(r'llm')
llm(r'llm');

const AssistantMessageModeEnum(this.value);

final String value;

@override
String toString() => value;
}
