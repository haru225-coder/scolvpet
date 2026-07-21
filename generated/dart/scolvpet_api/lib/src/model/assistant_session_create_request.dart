//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_session_create_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantSessionCreateRequest {
  /// Returns a new [AssistantSessionCreateRequest] instance.
  AssistantSessionCreateRequest({

     this.title,
  });

  @JsonKey(

    name: r'title',
    required: false,
    includeIfNull: false,
  )


  final String? title;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantSessionCreateRequest &&
      other.title == title;

    @override
    int get hashCode =>
        title.hashCode;

  factory AssistantSessionCreateRequest.fromJson(Map<String, dynamic> json) => _$AssistantSessionCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantSessionCreateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
