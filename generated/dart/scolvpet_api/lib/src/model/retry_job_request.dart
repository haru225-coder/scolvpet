//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'retry_job_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RetryJobRequest {
  /// Returns a new [RetryJobRequest] instance.
  RetryJobRequest({

    required  this.reason,
  });

  @JsonKey(
    
    name: r'reason',
    required: true,
    includeIfNull: false,
  )


  final String reason;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RetryJobRequest &&
      other.reason == reason;

    @override
    int get hashCode =>
        reason.hashCode;

  factory RetryJobRequest.fromJson(Map<String, dynamic> json) => _$RetryJobRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RetryJobRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

