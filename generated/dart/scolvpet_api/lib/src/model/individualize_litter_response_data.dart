//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/reconciliation.dart';
import 'package:scolvpet_api/src/model/individualize_mapping.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'individualize_litter_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class IndividualizeLitterResponseData {
  /// Returns a new [IndividualizeLitterResponseData] instance.
  IndividualizeLitterResponseData({

    required  this.litterId,

    required  this.evaluatedEligibleSetToken,

    required  this.evaluatedEligibleCount,

    required  this.mappings,

    required  this.createdLitterMemberCount,

    required  this.createdParentageCount,

    required  this.reconciliation,

    required  this.litterVersion,
  });

  @JsonKey(

    name: r'litter_id',
    required: true,
    includeIfNull: false,
  )


  final String litterId;



      /// 服务端执行时重算并接受的 eligible set token
  @JsonKey(

    name: r'evaluated_eligible_set_token',
    required: true,
    includeIfNull: false,
  )


  final String evaluatedEligibleSetToken;



          // minimum: 1
  @JsonKey(

    name: r'evaluated_eligible_count',
    required: true,
    includeIfNull: false,
  )


  final int evaluatedEligibleCount;



  @JsonKey(

    name: r'mappings',
    required: true,
    includeIfNull: false,
  )


  final List<IndividualizeMapping> mappings;



          // minimum: 0
  @JsonKey(

    name: r'created_litter_member_count',
    required: true,
    includeIfNull: false,
  )


  final int createdLitterMemberCount;



          // minimum: 0
  @JsonKey(

    name: r'created_parentage_count',
    required: true,
    includeIfNull: false,
  )


  final int createdParentageCount;



  @JsonKey(

    name: r'reconciliation',
    required: true,
    includeIfNull: false,
  )


  final Reconciliation reconciliation;



          // minimum: 1
  @JsonKey(

    name: r'litter_version',
    required: true,
    includeIfNull: false,
  )


  final int litterVersion;





    @override
    bool operator ==(Object other) => identical(this, other) || other is IndividualizeLitterResponseData &&
      other.litterId == litterId &&
      other.evaluatedEligibleSetToken == evaluatedEligibleSetToken &&
      other.evaluatedEligibleCount == evaluatedEligibleCount &&
      other.mappings == mappings &&
      other.createdLitterMemberCount == createdLitterMemberCount &&
      other.createdParentageCount == createdParentageCount &&
      other.reconciliation == reconciliation &&
      other.litterVersion == litterVersion;

    @override
    int get hashCode =>
        litterId.hashCode +
        evaluatedEligibleSetToken.hashCode +
        evaluatedEligibleCount.hashCode +
        mappings.hashCode +
        createdLitterMemberCount.hashCode +
        createdParentageCount.hashCode +
        reconciliation.hashCode +
        litterVersion.hashCode;

  factory IndividualizeLitterResponseData.fromJson(Map<String, dynamic> json) => _$IndividualizeLitterResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$IndividualizeLitterResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
