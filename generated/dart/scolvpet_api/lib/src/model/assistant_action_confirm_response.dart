//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/assistant_action_confirm_result.dart';
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_action_confirm_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantActionConfirmResponse {
  /// Returns a new [AssistantActionConfirmResponse] instance.
  AssistantActionConfirmResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final AssistantActionConfirmResult data;



  @JsonKey(

    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantActionConfirmResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory AssistantActionConfirmResponse.fromJson(Map<String, dynamic> json) => _$AssistantActionConfirmResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantActionConfirmResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
