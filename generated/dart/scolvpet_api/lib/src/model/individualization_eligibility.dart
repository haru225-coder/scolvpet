//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/individualization_eligibility_blocker.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'individualization_eligibility.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class IndividualizationEligibility {
  /// Returns a new [IndividualizationEligibility] instance.
  IndividualizationEligibility({

    required  this.litterId,

    required  this.litterVersion,

    required  this.eligibleSetToken,

    required  this.eligiblePupIdentityIds,

    required  this.eligibleCount,

    required  this.blockers,

    required  this.canIndividualize,

    required  this.computedAt,
  });

  @JsonKey(

    name: r'litter_id',
    required: true,
    includeIfNull: false,
  )


  final String litterId;



          // minimum: 1
  @JsonKey(

    name: r'litter_version',
    required: true,
    includeIfNull: false,
  )


  final int litterVersion;



      /// 绑定 litter version、完整 eligible 身份集合和关键守卫事实的不透明令牌
  @JsonKey(

    name: r'eligible_set_token',
    required: true,
    includeIfNull: false,
  )


  final String eligibleSetToken;



  @JsonKey(

    name: r'eligible_pup_identity_ids',
    required: true,
    includeIfNull: false,
  )


  final Set<String> eligiblePupIdentityIds;



          // minimum: 0
  @JsonKey(

    name: r'eligible_count',
    required: true,
    includeIfNull: false,
  )


  final int eligibleCount;



  @JsonKey(

    name: r'blockers',
    required: true,
    includeIfNull: false,
  )


  final List<IndividualizationEligibilityBlocker> blockers;



  @JsonKey(

    name: r'can_individualize',
    required: true,
    includeIfNull: false,
  )


  final bool canIndividualize;



  @JsonKey(

    name: r'computed_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime computedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is IndividualizationEligibility &&
      other.litterId == litterId &&
      other.litterVersion == litterVersion &&
      other.eligibleSetToken == eligibleSetToken &&
      other.eligiblePupIdentityIds == eligiblePupIdentityIds &&
      other.eligibleCount == eligibleCount &&
      other.blockers == blockers &&
      other.canIndividualize == canIndividualize &&
      other.computedAt == computedAt;

    @override
    int get hashCode =>
        litterId.hashCode +
        litterVersion.hashCode +
        eligibleSetToken.hashCode +
        eligiblePupIdentityIds.hashCode +
        eligibleCount.hashCode +
        blockers.hashCode +
        canIndividualize.hashCode +
        computedAt.hashCode;

  factory IndividualizationEligibility.fromJson(Map<String, dynamic> json) => _$IndividualizationEligibilityFromJson(json);

  Map<String, dynamic> toJson() => _$IndividualizationEligibilityToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
