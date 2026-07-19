//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'growth_opportunity.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GrowthOpportunity {
  /// Returns a new [GrowthOpportunity] instance.
  GrowthOpportunity({

    required  this.kind,

    required  this.hamsterId,

    required  this.title,

    required  this.reason,

    required  this.priority,

    required  this.suggestion,

     this.publicName,
  });

  @JsonKey(

    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final String kind;



  @JsonKey(

    name: r'hamster_id',
    required: true,
    includeIfNull: false,
  )


  final String hamsterId;



  @JsonKey(

    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(

    name: r'reason',
    required: true,
    includeIfNull: false,
  )


  final String reason;



  @JsonKey(

    name: r'priority',
    required: true,
    includeIfNull: false,
  )


  final int priority;



  @JsonKey(

    name: r'suggestion',
    required: true,
    includeIfNull: false,
  )


  final String suggestion;



  @JsonKey(

    name: r'public_name',
    required: false,
    includeIfNull: false,
  )


  final String? publicName;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GrowthOpportunity &&
      other.kind == kind &&
      other.hamsterId == hamsterId &&
      other.title == title &&
      other.reason == reason &&
      other.priority == priority &&
      other.suggestion == suggestion &&
      other.publicName == publicName;

    @override
    int get hashCode =>
        kind.hashCode +
        hamsterId.hashCode +
        title.hashCode +
        reason.hashCode +
        priority.hashCode +
        suggestion.hashCode +
        publicName.hashCode;

  factory GrowthOpportunity.fromJson(Map<String, dynamic> json) => _$GrowthOpportunityFromJson(json);

  Map<String, dynamic> toJson() => _$GrowthOpportunityToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
