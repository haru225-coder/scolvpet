//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/assistant_action_cancel_result.dart';
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_action_cancel_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantActionCancelResponse {
  /// Returns a new [AssistantActionCancelResponse] instance.
  AssistantActionCancelResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final AssistantActionCancelResult data;



  @JsonKey(

    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantActionCancelResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory AssistantActionCancelResponse.fromJson(Map<String, dynamic> json) => _$AssistantActionCancelResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantActionCancelResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
