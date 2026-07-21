//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_action_cancel_result.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantActionCancelResult {
  /// Returns a new [AssistantActionCancelResult] instance.
  AssistantActionCancelResult({

    required  this.actionId,

    required  this.status,
  });

  @JsonKey(

    name: r'action_id',
    required: true,
    includeIfNull: false,
  )


  final String actionId;



  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final AssistantActionCancelResultStatusEnum status;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantActionCancelResult &&
      other.actionId == actionId &&
      other.status == status;

    @override
    int get hashCode =>
        actionId.hashCode +
        status.hashCode;

  factory AssistantActionCancelResult.fromJson(Map<String, dynamic> json) => _$AssistantActionCancelResultFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantActionCancelResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum AssistantActionCancelResultStatusEnum {
@JsonValue(r'cancelled')
cancelled(r'cancelled');

const AssistantActionCancelResultStatusEnum(this.value);

final String value;

@override
String toString() => value;
}
