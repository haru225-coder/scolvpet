//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'usage_metric.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UsageMetric {
  /// Returns a new [UsageMetric] instance.
  UsageMetric({

    required  this.metric,

    required  this.used,

     this.limit,

    required  this.unit,

    required  this.measuredAt,
  });

  @JsonKey(
    
    name: r'metric',
    required: true,
    includeIfNull: false,
  )


  final UsageMetricMetricEnum metric;



          // minimum: 0
  @JsonKey(
    
    name: r'used',
    required: true,
    includeIfNull: false,
  )


  final num used;



          // minimum: 0
  @JsonKey(
    
    name: r'limit',
    required: false,
    includeIfNull: false,
  )


  final num? limit;



  @JsonKey(
    
    name: r'unit',
    required: true,
    includeIfNull: false,
  )


  final UsageMetricUnitEnum unit;



  @JsonKey(
    
    name: r'measured_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime measuredAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UsageMetric &&
      other.metric == metric &&
      other.used == used &&
      other.limit == limit &&
      other.unit == unit &&
      other.measuredAt == measuredAt;

    @override
    int get hashCode =>
        metric.hashCode +
        used.hashCode +
        (limit == null ? 0 : limit.hashCode) +
        unit.hashCode +
        measuredAt.hashCode;

  factory UsageMetric.fromJson(Map<String, dynamic> json) => _$UsageMetricFromJson(json);

  Map<String, dynamic> toJson() => _$UsageMetricToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum UsageMetricMetricEnum {
@JsonValue(r'active_hamsters')
activeHamsters(r'active_hamsters'),
@JsonValue(r'active_litters')
activeLitters(r'active_litters'),
@JsonValue(r'enclosures')
enclosures(r'enclosures'),
@JsonValue(r'media_bytes')
mediaBytes(r'media_bytes'),
@JsonValue(r'video_minutes')
videoMinutes(r'video_minutes'),
@JsonValue(r'backup_bytes')
backupBytes(r'backup_bytes');

const UsageMetricMetricEnum(this.value);

final String value;

@override
String toString() => value;
}



enum UsageMetricUnitEnum {
@JsonValue(r'count')
count(r'count'),
@JsonValue(r'bytes')
bytes(r'bytes'),
@JsonValue(r'minutes')
minutes(r'minutes');

const UsageMetricUnitEnum(this.value);

final String value;

@override
String toString() => value;
}


