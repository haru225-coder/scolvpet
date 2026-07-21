//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/assistant_session.dart';
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_session_list_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantSessionListResponse {
  /// Returns a new [AssistantSessionListResponse] instance.
  AssistantSessionListResponse({

    required  this.data,

     this.page,

    required  this.meta,
  });

  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final List<AssistantSession> data;



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
    bool operator ==(Object other) => identical(this, other) || other is AssistantSessionListResponse &&
      other.data == data &&
      other.page == page &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        page.hashCode +
        meta.hashCode;

  factory AssistantSessionListResponse.fromJson(Map<String, dynamic> json) => _$AssistantSessionListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantSessionListResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
