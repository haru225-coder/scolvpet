//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'entitlement_limit.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EntitlementLimit {
  /// Returns a new [EntitlementLimit] instance.
  EntitlementLimit({

    required  this.code,

    required  this.metric,

    required  this.title,

     this.limit,

    required  this.used,

     this.remaining,

    required  this.over,

    required  this.unit,
  });

  @JsonKey(

    name: r'code',
    required: true,
    includeIfNull: false,
  )


  final String code;



  @JsonKey(

    name: r'metric',
    required: true,
    includeIfNull: false,
  )


  final String metric;



  @JsonKey(

    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(

    name: r'limit',
    required: false,
    includeIfNull: false,
  )


  final num? limit;



  @JsonKey(

    name: r'used',
    required: true,
    includeIfNull: false,
  )


  final num used;



  @JsonKey(

    name: r'remaining',
    required: false,
    includeIfNull: false,
  )


  final num? remaining;



  @JsonKey(

    name: r'over',
    required: true,
    includeIfNull: false,
  )


  final bool over;



  @JsonKey(

    name: r'unit',
    required: true,
    includeIfNull: false,
  )


  final String unit;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EntitlementLimit &&
      other.code == code &&
      other.metric == metric &&
      other.title == title &&
      other.limit == limit &&
      other.used == used &&
      other.remaining == remaining &&
      other.over == over &&
      other.unit == unit;

    @override
    int get hashCode =>
        code.hashCode +
        metric.hashCode +
        title.hashCode +
        (limit == null ? 0 : limit.hashCode) +
        used.hashCode +
        (remaining == null ? 0 : remaining.hashCode) +
        over.hashCode +
        unit.hashCode;

  factory EntitlementLimit.fromJson(Map<String, dynamic> json) => _$EntitlementLimitFromJson(json);

  Map<String, dynamic> toJson() => _$EntitlementLimitToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
