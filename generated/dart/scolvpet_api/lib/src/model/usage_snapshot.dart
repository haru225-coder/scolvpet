//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/usage_metric.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'usage_snapshot.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UsageSnapshot {
  /// Returns a new [UsageSnapshot] instance.
  UsageSnapshot({

    required  this.id,

    required  this.periodStart,

    required  this.periodEnd,

    required  this.metrics,

    required  this.createdAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'period_start',
    required: true,
    includeIfNull: false,
  )


  final DateTime periodStart;



  @JsonKey(
    
    name: r'period_end',
    required: true,
    includeIfNull: false,
  )


  final DateTime periodEnd;



      /// 六项固定指标各出现一次
  @JsonKey(
    
    name: r'metrics',
    required: true,
    includeIfNull: false,
  )


  final List<UsageMetric> metrics;



  @JsonKey(
    
    name: r'created_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UsageSnapshot &&
      other.id == id &&
      other.periodStart == periodStart &&
      other.periodEnd == periodEnd &&
      other.metrics == metrics &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        periodStart.hashCode +
        periodEnd.hashCode +
        metrics.hashCode +
        createdAt.hashCode;

  factory UsageSnapshot.fromJson(Map<String, dynamic> json) => _$UsageSnapshotFromJson(json);

  Map<String, dynamic> toJson() => _$UsageSnapshotToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

