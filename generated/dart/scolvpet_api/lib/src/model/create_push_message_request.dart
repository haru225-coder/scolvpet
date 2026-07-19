//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_push_message_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreatePushMessageRequest {
  /// Returns a new [CreatePushMessageRequest] instance.
  CreatePushMessageRequest({

    required  this.title,

    required  this.body,

     this.data,

     this.targetDeviceId,
  });

  @JsonKey(

    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(

    name: r'body',
    required: true,
    includeIfNull: false,
  )


  final String body;



  @JsonKey(

    name: r'data',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? data;



  @JsonKey(

    name: r'target_device_id',
    required: false,
    includeIfNull: false,
  )


  final String? targetDeviceId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreatePushMessageRequest &&
      other.title == title &&
      other.body == body &&
      other.data == data &&
      other.targetDeviceId == targetDeviceId;

    @override
    int get hashCode =>
        title.hashCode +
        body.hashCode +
        data.hashCode +
        (targetDeviceId == null ? 0 : targetDeviceId.hashCode);

  factory CreatePushMessageRequest.fromJson(Map<String, dynamic> json) => _$CreatePushMessageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePushMessageRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
