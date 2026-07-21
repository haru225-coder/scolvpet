//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/assistant_message.dart';
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_message_list_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantMessageListResponse {
  /// Returns a new [AssistantMessageListResponse] instance.
  AssistantMessageListResponse({

    required  this.data,

     this.page,

    required  this.meta,
  });

  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final List<AssistantMessage> data;



  @JsonKey(

    name: r'page',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? page;



  @JsonKey(

    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantMessageListResponse &&
      other.data == data &&
      other.page == page &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        page.hashCode +
        meta.hashCode;

  factory AssistantMessageListResponse.fromJson(Map<String, dynamic> json) => _$AssistantMessageListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantMessageListResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
