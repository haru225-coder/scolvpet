//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'entitlement_check_result.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EntitlementCheckResult {
  /// Returns a new [EntitlementCheckResult] instance.
  EntitlementCheckResult({

    required  this.allowed,

    required  this.enforcement,

    required  this.planCode,

     this.reason,

     this.feature,

     this.metric,

     this.used,

     this.limit,
  });

  @JsonKey(

    name: r'allowed',
    required: true,
    includeIfNull: false,
  )


  final bool allowed;



  @JsonKey(

    name: r'enforcement',
    required: true,
    includeIfNull: false,
  )


  final String enforcement;



  @JsonKey(

    name: r'plan_code',
    required: true,
    includeIfNull: false,
  )


  final String planCode;



  @JsonKey(

    name: r'reason',
    required: false,
    includeIfNull: false,
  )


  final String? reason;



  @JsonKey(

    name: r'feature',
    required: false,
    includeIfNull: false,
  )


  final String? feature;



  @JsonKey(

    name: r'metric',
    required: false,
    includeIfNull: false,
  )


  final String? metric;



  @JsonKey(

    name: r'used',
    required: false,
    includeIfNull: false,
  )


  final num? used;



  @JsonKey(

    name: r'limit',
    required: false,
    includeIfNull: false,
  )


  final num? limit;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EntitlementCheckResult &&
      other.allowed == allowed &&
      other.enforcement == enforcement &&
      other.planCode == planCode &&
      other.reason == reason &&
      other.feature == feature &&
      other.metric == metric &&
      other.used == used &&
      other.limit == limit;

    @override
    int get hashCode =>
        allowed.hashCode +
        enforcement.hashCode +
        planCode.hashCode +
        (reason == null ? 0 : reason.hashCode) +
        (feature == null ? 0 : feature.hashCode) +
        (metric == null ? 0 : metric.hashCode) +
        (used == null ? 0 : used.hashCode) +
        (limit == null ? 0 : limit.hashCode);

  factory EntitlementCheckResult.fromJson(Map<String, dynamic> json) => _$EntitlementCheckResultFromJson(json);

  Map<String, dynamic> toJson() => _$EntitlementCheckResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
