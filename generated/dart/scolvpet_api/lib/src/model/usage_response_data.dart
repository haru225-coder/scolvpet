//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/usage_response_data_entitlement.dart';
import 'package:scolvpet_api/src/model/usage_metric.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'usage_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UsageResponseData {
  /// Returns a new [UsageResponseData] instance.
  UsageResponseData({

    required  this.metrics,

    required  this.meteringStatus,

    required  this.entitlement,
  });

      /// active_hamsters、active_litters、enclosures、media_bytes、video_minutes、backup_bytes 各一项
  @JsonKey(

    name: r'metrics',
    required: true,
    includeIfNull: false,
  )


  final List<UsageMetric> metrics;



      /// updating/delayed 只影响展示，不阻止业务写入
  @JsonKey(

    name: r'metering_status',
    required: true,
    includeIfNull: false,
  )


  final UsageResponseDataMeteringStatusEnum meteringStatus;



  @JsonKey(

    name: r'entitlement',
    required: true,
    includeIfNull: false,
  )


  final UsageResponseDataEntitlement entitlement;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UsageResponseData &&
      other.metrics == metrics &&
      other.meteringStatus == meteringStatus &&
      other.entitlement == entitlement;

    @override
    int get hashCode =>
        metrics.hashCode +
        meteringStatus.hashCode +
        entitlement.hashCode;

  factory UsageResponseData.fromJson(Map<String, dynamic> json) => _$UsageResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$UsageResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// updating/delayed 只影响展示，不阻止业务写入
enum UsageResponseDataMeteringStatusEnum {
    /// updating/delayed 只影响展示，不阻止业务写入
@JsonValue(r'current')
current(r'current'),
    /// updating/delayed 只影响展示，不阻止业务写入
@JsonValue(r'updating')
updating(r'updating'),
    /// updating/delayed 只影响展示，不阻止业务写入
@JsonValue(r'delayed')
delayed(r'delayed');

const UsageResponseDataMeteringStatusEnum(this.value);

final String value;

@override
String toString() => value;
}
