//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sandbox_activate_plan_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SandboxActivatePlanRequest {
  /// Returns a new [SandboxActivatePlanRequest] instance.
  SandboxActivatePlanRequest({

     this.planCode = SandboxActivatePlanRequestPlanCodeEnum.pro,
  });

  @JsonKey(
    defaultValue: SandboxActivatePlanRequestPlanCodeEnum.pro,
    name: r'plan_code',
    required: false,
    includeIfNull: false,
  )


  final SandboxActivatePlanRequestPlanCodeEnum? planCode;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SandboxActivatePlanRequest &&
      other.planCode == planCode;

    @override
    int get hashCode =>
        planCode.hashCode;

  factory SandboxActivatePlanRequest.fromJson(Map<String, dynamic> json) => _$SandboxActivatePlanRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SandboxActivatePlanRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum SandboxActivatePlanRequestPlanCodeEnum {
@JsonValue(r'free')
free(r'free'),
@JsonValue(r'pro')
pro(r'pro');

const SandboxActivatePlanRequestPlanCodeEnum(this.value);

final String value;

@override
String toString() => value;
}


