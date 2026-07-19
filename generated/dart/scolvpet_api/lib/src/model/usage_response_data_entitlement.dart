//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'usage_response_data_entitlement.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UsageResponseDataEntitlement {
  /// Returns a new [UsageResponseDataEntitlement] instance.
  UsageResponseDataEntitlement({

    required  this.planCode,

    required  this.enforcement,

    required  this.effectiveAt,

     this.expiresAt,
  });

  @JsonKey(

    name: r'plan_code',
    required: true,
    includeIfNull: false,
  )


  final String planCode;



      /// MVP 只读计量，不启用付费墙或超量阻断
  @JsonKey(

    name: r'enforcement',
    required: true,
    includeIfNull: false,
  )


  final UsageResponseDataEntitlementEnforcementEnum enforcement;



  @JsonKey(

    name: r'effective_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime effectiveAt;



  @JsonKey(

    name: r'expires_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? expiresAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UsageResponseDataEntitlement &&
      other.planCode == planCode &&
      other.enforcement == enforcement &&
      other.effectiveAt == effectiveAt &&
      other.expiresAt == expiresAt;

    @override
    int get hashCode =>
        planCode.hashCode +
        enforcement.hashCode +
        effectiveAt.hashCode +
        (expiresAt == null ? 0 : expiresAt.hashCode);

  factory UsageResponseDataEntitlement.fromJson(Map<String, dynamic> json) => _$UsageResponseDataEntitlementFromJson(json);

  Map<String, dynamic> toJson() => _$UsageResponseDataEntitlementToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// MVP 只读计量，不启用付费墙或超量阻断
enum UsageResponseDataEntitlementEnforcementEnum {
    /// MVP 只读计量，不启用付费墙或超量阻断
@JsonValue(r'none')
none(r'none');

const UsageResponseDataEntitlementEnforcementEnum(this.value);

final String value;

@override
String toString() => value;
}
