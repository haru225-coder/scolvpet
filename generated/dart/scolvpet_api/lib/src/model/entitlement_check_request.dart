//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'entitlement_check_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EntitlementCheckRequest {
  /// Returns a new [EntitlementCheckRequest] instance.
  EntitlementCheckRequest({

     this.feature,

     this.metric,
  });

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





    @override
    bool operator ==(Object other) => identical(this, other) || other is EntitlementCheckRequest &&
      other.feature == feature &&
      other.metric == metric;

    @override
    int get hashCode =>
        feature.hashCode +
        metric.hashCode;

  factory EntitlementCheckRequest.fromJson(Map<String, dynamic> json) => _$EntitlementCheckRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EntitlementCheckRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

