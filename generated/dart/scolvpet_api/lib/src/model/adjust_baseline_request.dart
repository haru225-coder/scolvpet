//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'adjust_baseline_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdjustBaselineRequest {
  /// Returns a new [AdjustBaselineRequest] instance.
  AdjustBaselineRequest({

    required  this.newBaselineAt,

    required  this.reason,

    required  this.timezone,
  });

  @JsonKey(

    name: r'new_baseline_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime newBaselineAt;



  @JsonKey(

    name: r'reason',
    required: true,
    includeIfNull: false,
  )


  final String reason;



  @JsonKey(

    name: r'timezone',
    required: true,
    includeIfNull: false,
  )


  final String timezone;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AdjustBaselineRequest &&
      other.newBaselineAt == newBaselineAt &&
      other.reason == reason &&
      other.timezone == timezone;

    @override
    int get hashCode =>
        newBaselineAt.hashCode +
        reason.hashCode +
        timezone.hashCode;

  factory AdjustBaselineRequest.fromJson(Map<String, dynamic> json) => _$AdjustBaselineRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AdjustBaselineRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
