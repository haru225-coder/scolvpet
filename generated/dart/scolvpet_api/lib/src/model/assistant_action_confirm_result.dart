//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_action_confirm_result.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantActionConfirmResult {
  /// Returns a new [AssistantActionConfirmResult] instance.
  AssistantActionConfirmResult({

    required  this.actionId,

    required  this.type,

    required  this.status,

    required  this.result,
  });

  @JsonKey(

    name: r'action_id',
    required: true,
    includeIfNull: false,
  )


  final String actionId;



  @JsonKey(

    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final String type;



  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final AssistantActionConfirmResultStatusEnum status;



  @JsonKey(

    name: r'result',
    required: true,
    includeIfNull: false,
  )


  final Map<String, Object> result;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantActionConfirmResult &&
      other.actionId == actionId &&
      other.type == type &&
      other.status == status &&
      other.result == result;

    @override
    int get hashCode =>
        actionId.hashCode +
        type.hashCode +
        status.hashCode +
        result.hashCode;

  factory AssistantActionConfirmResult.fromJson(Map<String, dynamic> json) => _$AssistantActionConfirmResultFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantActionConfirmResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum AssistantActionConfirmResultStatusEnum {
@JsonValue(r'executed')
executed(r'executed');

const AssistantActionConfirmResultStatusEnum(this.value);

final String value;

@override
String toString() => value;
}
