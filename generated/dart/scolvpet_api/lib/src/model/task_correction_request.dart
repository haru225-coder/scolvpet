//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task_correction_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TaskCorrectionRequest {
  /// Returns a new [TaskCorrectionRequest] instance.
  TaskCorrectionRequest({

    required  this.reason,
  });

      /// 取消或撤销的原因，必填。留空返回 422。
  @JsonKey(

    name: r'reason',
    required: true,
    includeIfNull: false,
  )


  final String reason;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TaskCorrectionRequest &&
      other.reason == reason;

    @override
    int get hashCode =>
        reason.hashCode;

  factory TaskCorrectionRequest.fromJson(Map<String, dynamic> json) => _$TaskCorrectionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TaskCorrectionRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
