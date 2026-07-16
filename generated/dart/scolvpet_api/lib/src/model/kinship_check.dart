//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'kinship_check.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class KinshipCheck {
  /// Returns a new [KinshipCheck] instance.
  KinshipCheck({

    required  this.checkedAt,

    required  this.commonAncestorCount,

    required  this.riskLevel,

     this.coefficient,

    required  this.ruleVersion,

     this.warnings,
  });

  @JsonKey(
    
    name: r'checked_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime checkedAt;



          // minimum: 0
  @JsonKey(
    
    name: r'common_ancestor_count',
    required: true,
    includeIfNull: false,
  )


  final int commonAncestorCount;



  @JsonKey(
    
    name: r'risk_level',
    required: true,
    includeIfNull: false,
  )


  final KinshipCheckRiskLevelEnum riskLevel;



          // minimum: 0
          // maximum: 1
  @JsonKey(
    
    name: r'coefficient',
    required: false,
    includeIfNull: false,
  )


  final num? coefficient;



  @JsonKey(
    
    name: r'rule_version',
    required: true,
    includeIfNull: false,
  )


  final String ruleVersion;



  @JsonKey(
    
    name: r'warnings',
    required: false,
    includeIfNull: false,
  )


  final List<String>? warnings;





    @override
    bool operator ==(Object other) => identical(this, other) || other is KinshipCheck &&
      other.checkedAt == checkedAt &&
      other.commonAncestorCount == commonAncestorCount &&
      other.riskLevel == riskLevel &&
      other.coefficient == coefficient &&
      other.ruleVersion == ruleVersion &&
      other.warnings == warnings;

    @override
    int get hashCode =>
        checkedAt.hashCode +
        commonAncestorCount.hashCode +
        riskLevel.hashCode +
        (coefficient == null ? 0 : coefficient.hashCode) +
        ruleVersion.hashCode +
        warnings.hashCode;

  factory KinshipCheck.fromJson(Map<String, dynamic> json) => _$KinshipCheckFromJson(json);

  Map<String, dynamic> toJson() => _$KinshipCheckToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum KinshipCheckRiskLevelEnum {
@JsonValue(r'none')
none(r'none'),
@JsonValue(r'low')
low(r'low'),
@JsonValue(r'medium')
medium(r'medium'),
@JsonValue(r'high')
high(r'high'),
@JsonValue(r'blocked')
blocked(r'blocked');

const KinshipCheckRiskLevelEnum(this.value);

final String value;

@override
String toString() => value;
}


